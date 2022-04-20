//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct MediaAttachmentsView: View {
    
    @StateObject private var viewModel: MediaAttachmentsViewModel
    
    private static let spacing: CGFloat = 2
    
    private static var itemWidth: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return (UIScreen.main.bounds.size.width / 3) - spacing * 3
        } else {
            return 120
        }
    }
    
    private let columns = [GridItem(.adaptive(minimum: itemWidth), spacing: spacing)]
    
    init(channel: ChatChannel) {
        _viewModel = StateObject(
            wrappedValue: MediaAttachmentsViewModel(channel: channel)
        )
    }
    
    var body: some View {
        ZStack {
            if viewModel.loading {
                LoadingView()
            } else if viewModel.mediaItems.isEmpty {
                NoContentView(
                    imageName: "folder",
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
                                        mediaItem: mediaItem,
                                        imageAttachment: imageAttachment,
                                        allImageAttachments: viewModel.allImageAttachments,
                                        itemWidth: Self.itemWidth,
                                        index: index
                                    )
                                } else if let videoAttachment = mediaItem.videoAttachment {
                                    VideoAttachmentContentView(
                                        attachment: videoAttachment,
                                        author: mediaItem.author,
                                        width: Self.itemWidth,
                                        ratio: 1,
                                        cornerRadius: 0
                                    )
                                }
                            }
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

struct ImageAttachmentContentView: View {
    
    @State private var galleryShown = false
    
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
                source: imageAttachment.imageURL,
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
            GalleryView(
                imageAttachments: allImageAttachments,
                author: mediaItem.author,
                isShown: $galleryShown,
                selected: index
            )
        }
    }
}
