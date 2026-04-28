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
/// The view delegates all caching to the configured ``MediaLoader``: when
/// the loader resolves an already-cached image the completion fires
/// without crossing a network, so cached images appear within a frame.
/// The view never shows the ``StreamAsyncImagePhase/loading`` phase once
/// it has rendered an image — subsequent URL updates keep the previously
/// loaded image on screen until the new one arrives. This avoids the
/// loading flicker when, for example, reacting to a message reflows the
/// bubble and SwiftUI re-asks for the same attachment with a freshly
/// signed URL.
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
@MainActor
public struct StreamAsyncImage<Content: View>: View {
    @Injected(\.utils) private var utils

    private let url: URL?
    private let resize: ImageResize?
    private let content: (StreamAsyncImagePhase) -> Content

    @State private var phase: StreamAsyncImagePhase

    /// Creates an async image view.
    ///
    /// - Parameters:
    ///   - url: The image URL, or `nil` for the empty phase.
    ///   - image: An optional pre-loaded image used as the initial render.
    ///     When provided, the view skips the ``StreamAsyncImagePhase/loading``
    ///     phase entirely and renders this image on the first frame. If a
    ///     `url` is also provided, the loader runs in the background and
    ///     swaps in the resolved image once it arrives. Useful when the
    ///     caller already has the bitmap in memory (for example a snapshot
    ///     or a hand-off from a parent view) and wants to avoid the
    ///     placeholder flicker on first appearance.
    ///   - resize: Optional resize applied both server-side (via CDN requester) and client-side.
    ///     Sub-point dimensions are rounded to integer points so layout jitter
    ///     between renders does not produce a different CDN URL or cache key.
    ///   - content: A closure that receives the current phase and returns a view.
    public init(
        url: URL?,
        image: UIImage? = nil,
        resize: ImageResize? = nil,
        @ViewBuilder content: @escaping (StreamAsyncImagePhase) -> Content
    ) {
        self.url = url
        self.resize = Self.normalizedResize(resize)
        self.content = content
        if let image {
            _phase = State(initialValue: .success(StreamAsyncImageResult(
                image: image,
                animatedImageData: nil
            )))
        } else {
            _phase = State(initialValue: .empty)
        }
    }

    /// Creates a view that renders a pre-loaded image without performing
    /// any asynchronous loading.
    ///
    /// Useful for callers that already have the bitmap in memory and want
    /// to plug it into the same content closure used elsewhere with
    /// ``StreamAsyncImage``.
    ///
    /// - Parameters:
    ///   - image: The image to render.
    ///   - content: A closure that receives the current phase and returns a view.
    public init(
        image: UIImage,
        @ViewBuilder content: @escaping (StreamAsyncImagePhase) -> Content
    ) {
        self.init(url: nil, image: image, resize: nil, content: content)
    }

    public var body: some View {
        content(resolvedPhase)
            .compatibility.task(id: taskIdentity) { @MainActor in
                await loadImage()
            }
    }

    // MARK: - Phase Resolution

    /// Resolves the phase used for rendering, allowing the test sync
    /// resolver to short-circuit the async pipeline so snapshot tests
    /// capture the loaded image instead of the empty placeholder.
    private var resolvedPhase: StreamAsyncImagePhase {
        if case .success = phase { return phase }
        if let url, let resolver = StreamAsyncImageTestHooks.syncResolver, let result = resolver(url, resize) {
            return .success(result)
        }
        return phase
    }

    private var taskIdentity: String {
        let urlPart = url?.absoluteString ?? ""
        guard let resize else { return urlPart }
        return "\(urlPart)-\(resize.width)x\(resize.height)-\(resize.mode.value)"
    }

    // MARK: - Loading

    @MainActor
    private func loadImage() async {
        guard let url else {
            // Keep a seeded `UIImage` (set in `init(image:)`) on screen even
            // when no URL was provided.
            if phase.isSuccess { return }
            phase = .empty
            return
        }

        // Only flip to the loading phase if no image has been rendered yet.
        // When the URL changes on a view that already shows an image, we
        // keep the previous image on screen until the loader returns the
        // new one — for cached images that handoff is sub-frame, so the
        // user never sees a placeholder.
        if !phase.isSuccess {
            phase = .loading
        }

        do {
            let loaded = try await utils.mediaLoader.loadImage(
                url: url,
                options: ImageLoadOptions(resize: resize)
            )
            phase = .success(StreamAsyncImageResult(
                image: loaded.image,
                animatedImageData: loaded.animatedImageData
            ))
        } catch {
            guard !(error is CancellationError) else { return }
            // Don't wipe an already-rendered image on a failed reload —
            // keep showing the previous result instead of dropping to
            // `.error`. The view only surfaces an error when nothing has
            // ever loaded successfully.
            if phase.isSuccess { return }
            phase = .error(error)
        }
    }

    // MARK: - Resize Normalization

    /// Rounds the resize dimensions to integer points so sub-point layout
    /// jitter (for example `251.999…` vs `252.0`) maps to the same CDN
    /// URL, the same Nuke processor, and therefore the same cache entry.
    private static func normalizedResize(_ resize: ImageResize?) -> ImageResize? {
        guard var resize else { return nil }
        resize.width = resize.width.rounded()
        resize.height = resize.height.rounded()
        return resize
    }
}

// MARK: - Test Hook

/// Test-only hook used by snapshot tests to resolve image URLs
/// synchronously.
///
/// Snapshot tests capture the view after one synchronous layout pass,
/// before the `.task` modifier has a chance to drive the async
/// ``MediaLoader`` pipeline. Installing a resolver here makes
/// ``StreamAsyncImage``'s initial render use the resolved image
/// directly. In production this is always `nil`.
///
/// Lives on a non-generic namespace because static stored properties
/// are not supported on generic types.
enum StreamAsyncImageTestHooks {
    nonisolated(unsafe) static var syncResolver: ((URL, ImageResize?) -> StreamAsyncImageResult?)?
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

private extension StreamAsyncImagePhase {
    /// `true` when the phase is rendering a successfully loaded image.
    /// Used to keep an already-rendered image on screen across URL
    /// changes and failed reloads instead of dropping back to the
    /// loading or error placeholder.
    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
}

/// The result of a successfully loaded image.
public struct StreamAsyncImageResult {
    /// The loaded image.
    public let image: UIImage
    /// The raw image data for animated rendering. `nil` for static images.
    public let animatedImageData: Data?
}
