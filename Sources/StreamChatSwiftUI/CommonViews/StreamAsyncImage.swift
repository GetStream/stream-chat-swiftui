//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatCommonUI
import SwiftUI

/// A view that loads an image asynchronously and renders content based
/// on the current loading phase.
public struct StreamAsyncImage<ImageContent: View>: View {
    @Injected(\.utils) var utils
    
    let thumbnailSize: CGSize
    let url: URL?
    @ViewBuilder let content: (StreamAsyncImagePhase) -> ImageContent
    @State private var phase = StreamAsyncImagePhase.loading
    
    /// Loads an image from the given URL and builds a view based on the
    /// loading state.
    ///
    /// When `url` is `nil` the phase is set to ``StreamAsyncImagePhase/empty``
    /// immediately without performing a network request.
    ///
    /// - Parameters:
    ///   - url: The URL of the image to load, or `nil` if no image is available.
    ///   - thumbnailSize: The requested thumbnail dimensions used by the image CDN.
    ///   - content: A closure that takes the current loading phase and returns
    ///     the view to display.
    public init(
        url: URL?,
        thumbnailSize: CGSize,
        content: @escaping (StreamAsyncImagePhase) -> ImageContent
    ) {
        self.url = url
        self.thumbnailSize = thumbnailSize
        self.content = content
    }
    
    public var body: some View {
        content(phase)
            .compatibility.task(id: url?.absoluteString ?? "") { @MainActor [imageCDN, imageLoader, url] in
                guard let url else {
                    phase = .empty
                    return
                }
                let images = await imageLoader.loadImages(
                    from: [url].compactMap { $0 },
                    placeholders: [],
                    loadThumbnails: true,
                    thumbnailSize: thumbnailSize,
                    imageCDN: imageCDN
                )
                if let image = images.first {
                    phase = .success(Image(uiImage: image))
                } else {
                    phase = .empty
                }
            }
    }
    
    var imageLoader: ImageLoading { utils.imageLoader }
    var imageCDN: ImageCDN { utils.imageCDN }
}

/// The current loading state for ``StreamAsyncImage``.
public enum StreamAsyncImagePhase: Sendable, Equatable {
    /// A successfully loaded image.
    ///
    /// The associated `Image` value represents the loaded image ready for display.
    case success(Image)
    
    /// The image is currently loading.
    ///
    /// This is the initial phase while the image loader is fetching the image.
    /// Use this state to display a loading placeholder or progress indicator.
    case loading
    
    /// No image is available.
    ///
    /// This phase occurs when the URL is `nil` or the image fails to load.
    /// Use this state to display a placeholder or fallback content.
    case empty
}
