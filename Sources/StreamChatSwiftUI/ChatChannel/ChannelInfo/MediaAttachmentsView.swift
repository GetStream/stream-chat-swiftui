//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import AVFoundation
import StreamChat
import StreamChatCommonUI
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
                                TopLeftView {
                                    factory.makeUserAvatarView(
                                        options: UserAvatarViewOptions(
                                            user: mediaItem.message.author,
                                            size: AvatarSize.small,
                                            showsIndicator: false
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
    @Injected(\.utils) private var utils
    @Injected(\.tokens) private var tokens

    @State private var galleryShown = false
    @State private var videoDuration: TimeInterval?
    @State private var durationTask: Task<Void, Never>?

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
                height: itemWidth,
                showVideoIcon: false
            )
            .frame(width: itemWidth, height: itemWidth)
            .clipped()
            .overlay(
                Group {
                    if mediaItem.isVideo, let d = durationText {
                        VideoMediaBadge(durationText: d)
                            .padding(tokens.spacingXxs)
                    }
                },
                alignment: .bottomLeading
            )
        }
        .onAppear {
            guard mediaItem.isVideo,
                  let url = mediaItem.videoAttachment?.payload.videoURL else { return }
            durationTask = Task {
                let asset = AVURLAsset(url: url)
                await withCheckedContinuation { continuation in
                    asset.loadValuesAsynchronously(forKeys: ["duration"]) {
                        let seconds = asset.duration.seconds
                        if seconds.isFinite && seconds > 0 {
                            Task { @MainActor in videoDuration = seconds }
                        }
                        continuation.resume()
                    }
                }
            }
        }
        .onDisappear {
            durationTask?.cancel()
            durationTask = nil
        }
        .fullScreenCover(isPresented: $galleryShown) {
            factory.makeMediaViewer(
                options: MediaViewerOptions(
                    mediaAttachments: allMediaAttachments,
                    message: mediaItem.message,
                    isShown: $galleryShown,
                    options: .init(selectedIndex: index)
                )
            )
        }
    }

    private var durationText: String? {
        // Prefer extraData duration (available immediately, no network needed)
        if let extraData = mediaItem.videoAttachment?.payload.extraData,
           case let .number(duration) = extraData["duration"] {
            return utils.mediaBadgeDurationFormatter.longFormat(duration)
        }
        // Fall back to AVFoundation-loaded duration
        guard let duration = videoDuration else { return nil }
        return utils.mediaBadgeDurationFormatter.longFormat(duration)
    }
}
