//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatCommonUI
import SwiftUI

/// A view that loads an image asynchronously using the SDK's ``ImageLoader``
/// and CDN requester, then renders content based on the current loading phase.
///
/// This is the single image-loading view for the SwiftUI SDK. It handles:
/// - CDN requester URL transformation (signing, headers, caching keys)
/// - Optional resize parameters for server-side and client-side resizing
/// - Animated image (GIF) data passthrough
/// - Cancellation on disappear
///
/// ```swift
/// StreamAsyncImage(url: imageURL) { phase in
///     switch phase {
///     case .success(let result):
///         Image(uiImage: result.image)
///             .resizable()
///     case .loading:
///         ProgressView()
///     case .empty, .error:
///         Color.gray
///     }
/// }
/// ```
public struct StreamAsyncImage<Content: View>: View {
    @Injected(\.utils) private var utils
    @Injected(\.chatClient) private var chatClient

    private let url: URL?
    private let resize: ImageResize?
    private let content: (StreamAsyncImagePhase) -> Content

    @State private var phase = StreamAsyncImagePhase.loading

    /// Creates an async image view.
    ///
    /// - Parameters:
    ///   - url: The image URL, or `nil` for the empty phase.
    ///   - resize: Optional resize applied both server-side (via CDN requester) and client-side.
    ///   - content: A closure that receives the current phase and returns a view.
    public init(
        url: URL?,
        resize: ImageResize? = nil,
        @ViewBuilder content: @escaping (StreamAsyncImagePhase) -> Content
    ) {
        self.url = url
        self.resize = resize
        self.content = content
    }

    public var body: some View {
        content(phase)
            .onDisappear { phase = .loading }
            .compatibility.task(id: url?.absoluteString ?? "") { @MainActor in
                await loadImage()
            }
    }

    @MainActor
    private func loadImage() async {
        guard let url else {
            phase = .empty
            return
        }

        phase = .loading

        do {
            let result = try await loadWithNuke(url: url, resize: resize)
            phase = .success(result)
        } catch {
            phase = .error(error)
        }
    }

    /// Loads an image through the Nuke pipeline with CDN requester transformations.
    /// This is the only Nuke-coupled code path; replace this method
    /// when migrating away from Nuke.
    @MainActor
    private func loadWithNuke(url: URL, resize: ImageResize?) async throws -> StreamAsyncImageResult {
        let cdnRequester = chatClient.config.cdnRequester
        let cdnResize = resize.map { CDNImageResize(width: $0.width, height: $0.height, resizeMode: $0.mode.value, crop: $0.mode.cropValue) }
        let cdnRequest = try await cdnRequester.imageRequest(for: url, options: .init(resize: cdnResize))

        var urlRequest = URLRequest(url: cdnRequest.url)
        if let headers = cdnRequest.headers {
            for (key, value) in headers {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }

        var processors = [ImageProcessing]()
        if let resize {
            let size = CGSize(width: resize.width, height: resize.height)
            if size != .zero {
                processors.append(ImageProcessors.Resize(size: size))
            }
        }

        let request = ImageRequest(
            urlRequest: urlRequest,
            processors: processors,
            userInfo: cdnRequest.cachingKey.map { [ImageRequest.UserInfoKey.imageIdKey: $0 as Any] }
        )

        return try await withCheckedThrowingContinuation { continuation in
            ImagePipeline.shared.loadImage(with: request) { result in
                switch result {
                case let .success(response):
                    let imageResult = StreamAsyncImageResult(
                        image: response.image,
                        isAnimated: response.container.type == .gif,
                        animatedImageData: response.container.data
                    )
                    continuation.resume(returning: imageResult)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - Convenience Initializers

extension StreamAsyncImage {
    /// Creates an async image view with a thumbnail size for avatar-style loading.
    public init(
        url: URL?,
        thumbnailSize: CGSize,
        @ViewBuilder content: @escaping (StreamAsyncImagePhase) -> Content
    ) {
        self.init(url: url, resize: ImageResize(thumbnailSize), content: content)
    }
}

// MARK: - Phase & Result

/// The current loading state for ``StreamAsyncImage``.
public enum StreamAsyncImagePhase {
    /// The image loaded successfully.
    case success(StreamAsyncImageResult)
    /// The image is currently loading.
    case loading
    /// No image is available (nil URL).
    case empty
    /// The load failed with an error.
    case error(Error)

    /// The loaded image, if available.
    public var image: Image? {
        guard case .success(let result) = self else { return nil }
        return Image(uiImage: result.image)
    }
}

/// The result of a successfully loaded image.
public struct StreamAsyncImageResult {
    /// The loaded image.
    public let image: UIImage
    /// Whether the image is an animated format (e.g. GIF).
    public let isAnimated: Bool
    /// The raw image data for animated rendering. `nil` for static images.
    public let animatedImageData: Data?
}
