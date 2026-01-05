//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View displaying media attachments.
public struct MediaAttachmentsView<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
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
                                if let mediaAttachment = mediaItem.mediaAttachment {
                                    let index = viewModel.allMediaAttachments.firstIndex { $0.id == mediaAttachment.id
                                    } ?? 0
                                    MediaAttachmentContentView(
                                        factory: factory,
                                        mediaItem: mediaItem,
                                        mediaAttachment: mediaAttachment,
                                        allMediaAttachments: viewModel.allMediaAttachments,
                                        itemWidth: Self.itemWidth,
                                        index: index
                                    )
                                }
                            }
                            .overlay(
                                BottomRightView {
                                    factory.makeMessageAvatarView(
                                        for: UserDisplayInfo(
                                            id: mediaItem.message.author.id,
                                            name: mediaItem.message.author.name ?? "",
                                            imageURL: mediaItem.message.author.imageURL,
                                            size: .init(width: 24, height: 24),
                                            extraData: mediaItem.message.author.extraData
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
        .toolbarThemed {
            ToolbarItem(placement: .principal) {
                Text(L10n.ChatInfo.Media.title)
                    .font(fonts.bodyBold)
                    .foregroundColor(Color(colors.navigationBarTitle))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

public struct MediaAttachmentContentView<Factory: ViewFactory>: View {
    @State private var galleryShown = false

    let factory: Factory
    let mediaItem: MediaItem
    let mediaAttachment: MediaAttachment
    let allMediaAttachments: [MediaAttachment]
    let itemWidth: CGFloat
    let index: Int

    public init(
        factory: Factory,
        mediaItem: MediaItem,
        mediaAttachment: MediaAttachment,
        allMediaAttachments: [MediaAttachment],
        itemWidth: CGFloat,
        index: Int
    ) {
        self.factory = factory
        self.mediaItem = mediaItem
        self.mediaAttachment = mediaAttachment
        self.allMediaAttachments = allMediaAttachments
        self.itemWidth = itemWidth
        self.index = index
    }

    public var body: some View {
        Button {
            galleryShown = true
        } label: {
            LazyLoadingImage(
                source: mediaAttachment,
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
                mediaAttachments: allMediaAttachments,
                message: mediaItem.message,
                isShown: $galleryShown,
                options: .init(selectedIndex: index)
            )
        }
    }
}
