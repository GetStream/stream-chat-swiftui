//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatCommonUI
import SwiftUI

/// A view that loads one or more images asynchronously and renders
/// content based on the current loading phase.
public struct StreamAsyncImage<ImageContent: View>: View {
    @Injected(\.utils) var utils
    
    let size: CGFloat
    let urls: [URL]
    @ViewBuilder let content: (StreamAsyncImagePhase) -> ImageContent
    let imageMerger: @MainActor ([UIImage]) async -> UIImage?
    
    private let taskId: String
    @State private var phase = StreamAsyncImagePhase.loading
    
    /// Loads one or more images from the specified URLs and builds views based on
    /// the loading state.
    ///
    /// - Parameters:
    ///   - urls: The URLs of the images to display.
    ///   - size: The width and height of the view.
    ///   - content: A closure that takes the loading phase as input, and returns
    ///     the view to display for the current phase.
    ///   - imageMerger: A closure that combines multiple loaded images into a
    ///     single image. Defaults to returning the first image.
    public init(
        urls: [URL],
        size: CGFloat,
        content: @escaping (StreamAsyncImagePhase) -> ImageContent,
        imageMerger: @escaping @MainActor ([UIImage]) async -> UIImage? = { $0.first }
    ) {
        self.urls = urls
        self.size = size
        self.content = content
        self.imageMerger = imageMerger
        taskId = urls.map(\.absoluteString).joined()
    }
    
    public var body: some View {
        content(phase)
            .frame(width: size, height: size)
            .clipped()
            .compatibility.task(id: taskId) { @MainActor [imageCDN, imageLoader, imageMerger, urls] in
                let images = await imageLoader.loadImages(
                    from: urls,
                    placeholders: [],
                    loadThumbnails: true,
                    thumbnailSize: .avatarThumbnailSize,
                    imageCDN: imageCDN
                )
                if images.count > 1, let image = await imageMerger(images) {
                    phase = .success(Image(uiImage: image))
                } else if let image = images.first {
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
    /// The associated `Image` value represents the loaded image that can be displayed.
    /// For multi-URL scenarios with a merger, this contains the merged result.
    case success(Image)
    
    /// The image is currently loading.
    ///
    /// This phase occurs while the image loader is fetching images from the provided URLs.
    /// Use this state to display a loading placeholder or progress indicator.
    case loading
    
    /// No image is available.
    ///
    /// This phase occurs when all provided URLs fail to load or when the URL array is empty.
    /// Use this state to display a placeholder or fallback content.
    case empty
}
