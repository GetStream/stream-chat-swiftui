//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View displaying media attachments.
public struct MediaAttachmentsView<Factory: ViewFactory>: View {
    
    @Injected(\.images) private var images

    @StateObject private var viewModel: MediaAttachmentsViewModel
        
    let factory: Factory

    private static var itemWidth: CGFloat {
        let spacing: CGFloat = 2
        if UIDevice.current.userInterfaceIdiom == .phone {
            return (UIScreen.main.bounds.size.width / 3) - spacing * 3
        } else {
            return 120
        }
    }

    private let columns = [GridItem(.adaptive(minimum: itemWidth), spacing: 2)]

    public init(factory: Factory = DefaultViewFactory.shared, channel: ChatChannel) {
        _viewModel = StateObject(
            wrappedValue: MediaAttachmentsViewModel(channel: channel)
        )
        self.factory = factory
    }

    init(factory: Factory = DefaultViewFactory.shared, viewModel: MediaAttachmentsViewModel) {
        _viewModel = StateObject(
            wrappedValue: viewModel
        )
        self.factory = factory
    }

    public var body: some View {
        ZStack {
            if viewModel.loading {
                LoadingView()
            } else if viewModel.mediaItems.isEmpty {
                NoContentView(
                    image: images.noMedia,
                    title: L10n.ChatInfo.Media.emptyTitle,
                    description: L10n.ChatInfo.Media.emptyDesc
                )
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(0..<viewModel.mediaItems.count, id: \.self) { mediaItemIndex in
                            let mediaItem = viewModel.mediaItems[mediaItemIndex]
                            ZStack {
                                if !mediaItem.isVideo, let imageAttachment = mediaItem.imageAttachment {
                                    let index = viewModel.allImageAttachments.firstIndex { $0.id == imageAttachment.id } ?? 0
                                    ImageAttachmentContentView(
                                        factory: factory,
                                        mediaItem: mediaItem,
                                        imageAttachment: imageAttachment,
                                        allImageAttachments: viewModel.allImageAttachments,
                                        itemWidth: Self.itemWidth,
                                        index: index
                                    )
                                } else if let videoAttachment = mediaItem.videoAttachment {
                                    VideoAttachmentContentView(
                                        factory: factory,
                                        attachment: videoAttachment,
                                        message: mediaItem.message,
                                        width: Self.itemWidth,
                                        ratio: 1,
                                        cornerRadius: 0
                                    )
                                }
                            }
                            .overlay(
                                BottomRightView {
                                    factory.makeMessageAvatarView(
                                        for: UserDisplayInfo(
                                            id: mediaItem.author.id,
                                            name: mediaItem.author.name ?? "",
                                            imageURL: mediaItem.author.imageURL,
                                            size: .init(width: 24, height: 24)
                                        )
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                Color.white,
                                                lineWidth: 1
                                            )
                                    )
                                    .padding(.all, 8)
                                }
                            )
                            .onAppear {
                                viewModel.onMediaAttachmentAppear(with: mediaItemIndex)
                            }
                        }
                    }
                    .padding(.horizontal, 2)
                    .animation(nil)
                }
            }
        }
        .navigationTitle(L10n.ChatInfo.Media.title)
    }
}

struct ImageAttachmentContentView<Factory: ViewFactory>: View {

    @State private var galleryShown = false

    let factory: Factory
    let mediaItem: MediaItem
    let imageAttachment: ChatMessageImageAttachment
    let allImageAttachments: [ChatMessageImageAttachment]
    let itemWidth: CGFloat
    let index: Int

    var body: some View {
        Button {
            galleryShown = true
        } label: {
            LazyLoadingImage(
                source: MediaAttachment(url: imageAttachment.imageURL, type: .image),
                width: itemWidth,
                height: itemWidth
            )
            .frame(
                width: itemWidth,
                height: itemWidth
            )
            .clipped()
        }
        .fullScreenCover(isPresented: $galleryShown) {
            factory.makeGalleryView(
                mediaAttachments: allImageAttachments.map { MediaAttachment(from: $0) },
                message: mediaItem.message,
                isShown: $galleryShown,
                options: .init(selectedIndex: index)
            )
        }
    }
}
