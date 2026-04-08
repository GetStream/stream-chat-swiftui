//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import AVFoundation
import StreamChat
import SwiftUI

/// View displaying media attachments.
public struct MediaAttachmentsView<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens

    @StateObject private var viewModel: MediaAttachmentsViewModel
        
    let factory: Factory

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
                EmptyContentView(
                    image: images.noMedia,
                    title: L10n.ChatInfo.Media.emptyTitle,
                    description: L10n.ChatInfo.Media.emptyDesc
                )
            } else {
                MediaAttachmentsGridView(
                    factory: factory,
                    attachments: viewModel.allMediaAttachments,
                    mediaItems: viewModel.mediaItems,
                    showAvatars: true,
                    onItemAppear: viewModel.onMediaAttachmentAppear
                )
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

/// View displaying a grid of media attachments using an adaptive column layout.
struct MediaAttachmentsGridView<Factory: ViewFactory>: View {
    @Injected(\.tokens) private var tokens

    let factory: Factory
    let attachments: [MediaAttachment]
    let mediaItems: [MediaItem]?
    let showAvatars: Bool
    let onItemAppear: ((Int) -> Void)?

    private let targetItemWidth: CGFloat = 120

    init(
        factory: Factory = DefaultViewFactory.shared,
        attachments: [MediaAttachment],
        mediaItems: [MediaItem]? = nil,
        showAvatars: Bool = true,
        onItemAppear: ((Int) -> Void)? = nil
    ) {
        self.factory = factory
        self.attachments = attachments
        self.mediaItems = mediaItems
        self.showAvatars = showAvatars
        self.onItemAppear = onItemAppear
    }

    public var body: some View {
        GeometryReader { geometry in
            let spacing = tokens.spacingXxxs
            let columnCount = max(3, Int((geometry.size.width + spacing) / (targetItemWidth + spacing)))
            let totalSpacing = spacing * CGFloat(columnCount - 1)
            let rawWidth = (geometry.size.width - totalSpacing) / CGFloat(columnCount)
            let itemWidth: CGFloat? = rawWidth > 0 ? rawWidth : nil

            ScrollView {
                LazyVGrid(
                    columns: Array(
                        repeating: GridItem(.flexible(), spacing: spacing),
                        count: columnCount
                    ),
                    spacing: spacing
                ) {
                    ForEach(0..<attachments.count, id: \.self) { index in
                        if let itemWidth {
                            cellView(for: index, itemWidth: itemWidth)
                                .onAppear {
                                    onItemAppear?(index)
                                }
                        }
                    }
                }
                .animation(nil)
            }
        }
    }

    @ViewBuilder
    private func cellView(for index: Int, itemWidth: CGFloat) -> some View {
        if let mediaItems, index < mediaItems.count {
            let mediaItem = mediaItems[index]
            ZStack {
                if let mediaAttachment = mediaItem.mediaAttachment {
                    let attachmentIndex = attachments.firstIndex { $0.id == mediaAttachment.id } ?? 0
                    MediaAttachmentContentView(
                        factory: factory,
                        mediaItem: mediaItem,
                        mediaAttachment: mediaAttachment,
                        allMediaAttachments: attachments,
                        itemWidth: itemWidth,
                        index: attachmentIndex
                    )
                }
            }
            .overlay(
                Group {
                    if showAvatars {
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
                                    .stroke(Color.white, lineWidth: 1)
                            )
                            .padding(.all, 8)
                        }
                    }
                }
            )
        } else {
            LazyLoadingImage(
                source: attachments[index],
                width: itemWidth,
                height: itemWidth,
                showVideoIcon: false
            )
            .frame(width: itemWidth, height: itemWidth)
            .clipped()
        }
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
