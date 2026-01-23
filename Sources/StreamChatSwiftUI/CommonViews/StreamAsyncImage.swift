//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatCommonUI
import SwiftUI

public struct StreamAsyncImage<ImageContent: View>: View {
    @Injected(\.utils) var utils
    
    let size: CGFloat
    let urls: [URL]
    @ViewBuilder let content: (StreamAsyncImagePhase) -> ImageContent
    let imageMerger: @MainActor ([UIImage]) async -> UIImage?
    
    private let taskId: String
    @State private var phase = StreamAsyncImagePhase.loading
    
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

public enum StreamAsyncImagePhase: Sendable, Equatable {
    case success(Image)
    case loading
    case empty
}
