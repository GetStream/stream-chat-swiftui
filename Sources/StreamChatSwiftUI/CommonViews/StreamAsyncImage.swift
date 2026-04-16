//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatCommonUI
import SwiftUI

/// A view that loads an image asynchronously using the SDK's ``MediaLoader``
/// and ``CDNRequester``, then renders content based on the current loading phase.
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
    private let url: URL?
    private let resize: ImageResize?
    private let content: (StreamAsyncImagePhase) -> Content

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
        let initialPhase: StreamAsyncImagePhase = {
            guard let url else { return .empty }
            if let cached = NukeImageLoader.cachedResult(url: url, resize: resize) {
                return .success(cached)
            }
            return .loading
        }()
        StreamAsyncImageBody(
            url: url,
            resize: resize,
            initialPhase: initialPhase,
            content: content
        )
    }
}

/// Private inner view that owns the loading state.
///
/// Separated from ``StreamAsyncImage`` so the public struct stays
/// lightweight during scrolling (no `@State`, no DI resolution in `init`).
/// The initial phase is resolved by the outer view via a synchronous Nuke
/// cache lookup. All subsequent loading runs asynchronously through `.task`.
private struct StreamAsyncImageBody<Content: View>: View {
    @Injected(\.utils) private var utils

    let url: URL?
    let resize: ImageResize?
    let initialPhase: StreamAsyncImagePhase
    let content: (StreamAsyncImagePhase) -> Content

    @State private var phase: StreamAsyncImagePhase?

    var body: some View {
        content(phase ?? initialPhase)
            .compatibility.task(id: taskIdentity) { @MainActor in
                await loadImage()
            }
    }

    private var taskIdentity: String {
        let urlPart = url?.absoluteString ?? ""
        guard let resize else { return urlPart }
        return "\(urlPart)-\(resize.width)x\(resize.height)-\(resize.mode.value)"
    }

    @MainActor
    private func loadImage() async {
        phase = nil
        guard let url else {
            phase = .empty
            return
        }

        do {
            let result = try await NukeImageLoader.loadImage(
                url: url,
                resize: resize,
                cdnRequester: utils.cdnRequester,
                onCacheMiss: { phase = .loading }
            )
            phase = .success(result)
        } catch {
            if !(error is CancellationError) {
                phase = .error(error)
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
