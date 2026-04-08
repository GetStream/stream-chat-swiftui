//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import AVKit
import StreamChat
import SwiftUI

/// View used for displaying image attachments in a gallery.
public struct MediaViewer<Factory: ViewFactory>: View {
    @Environment(\.presentationMode) var presentationMode

    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.images) private var images
    @Injected(\.utils) private var utils
    @Injected(\.tokens) private var tokens

    private let viewFactory: Factory
    var mediaAttachments: [MediaAttachment]
    var author: ChatUser
    var message: ChatMessage?
    @Binding var isShown: Bool
    @State private var selected: Int
    @State private var loadedImages = [Int: UIImage]()
    @State private var gridShown = false

    public init(
        viewFactory: Factory = DefaultViewFactory.shared,
        imageAttachments: [ChatMessageImageAttachment],
        author: ChatUser,
        isShown: Binding<Bool>,
        selected: Int,
        message: ChatMessage? = nil
    ) {
        let mediaAttachments = imageAttachments.map { MediaAttachment(from: $0) }
        self.init(
            viewFactory: viewFactory,
            mediaAttachments: mediaAttachments,
            author: author,
            isShown: isShown,
            selected: selected,
            message: message
        )
    }
    
    public init(
        viewFactory: Factory = DefaultViewFactory.shared,
        mediaAttachments: [MediaAttachment],
        author: ChatUser,
        isShown: Binding<Bool>,
        selected: Int,
        message: ChatMessage? = nil
    ) {
        self.viewFactory = viewFactory
        self.mediaAttachments = mediaAttachments
        self.author = author
        _isShown = isShown
        _selected = State(initialValue: selected)
        self.message = message
    }

    public var body: some View {
        GeometryReader { reader in
            VStack {
                viewFactory.makeMediaViewerHeader(
                    options: MediaViewerHeaderOptions(
                        title: author.name ?? "",
                        subtitle: message.map {
                            utils.galleryHeaderViewDateFormatter.format($0.createdAt)
                        } ?? author.onlineText,
                        shown: $isShown
                    )
                )
                
                Divider()

                TabView(selection: $selected) {
                    ForEach(0..<mediaAttachments.count, id: \.self) { index in
                        ZStack {
                            let source = mediaAttachments[index]
                            if source.type == .image {
                                ZoomableScrollView {
                                    VStack {
                                        Spacer()
                                        LazyLoadingImage(
                                            source: source,
                                            width: reader.size.width,
                                            height: reader.size.height,
                                            resize: true,
                                            shouldSetFrame: false,
                                            onImageLoaded: { image in
                                                loadedImages[index] = image
                                            }
                                        )
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: reader.size.width)
                                        Spacer()
                                    }
                                }
                                .tag(index)
                            } else {
                                StreamVideoPlayer(url: source.url)
                                    .tag(index)
                            }
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .background(Color(colors.backgroundCoreApp))
                .gesture(
                    DragGesture().onEnded { value in
                        if value.location.y - value.startLocation.y > 100 {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                )
                
                Divider()

                HStack {
                    ShareButtonView(content: sharingContent)

                    Spacer()

                    Text("\(selected + 1) of \(mediaAttachments.count)")
                        .font(fonts.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(colors.textPrimary.toColor)

                    Spacer()

                    StreamIconButton(role: .primary, style: .ghost, size: .small) {
                        gridShown = true
                    } icon: {
                        Image(uiImage: images.gallery)
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 16, height: 16, alignment: .center)
                            .foregroundColor(Color(colors.textSecondary))
                    }
                }
                .padding(.all, tokens.spacingXl)
                .frame(height: 72)
            }
            .sheet(isPresented: $gridShown) {
                GridMediaView(
                    factory: viewFactory,
                    attachments: mediaAttachments
                )
                .modifier(PresentationDetentsModifier(sheetSizes: [.medium, .large]))
            }
        }
    }

    private var sharingContent: [UIImage] {
        if let image = loadedImages[selected] {
            [image]
        } else {
            []
        }
    }
}

struct GridMediaView<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    let factory: Factory
    let attachments: [MediaAttachment]

    var body: some View {
        VStack(spacing: tokens.spacingLg) {
            Text(L10n.ChatInfo.Media.title)
                .font(fonts.bodyBold)
                .foregroundColor(Color(colors.navigationBarTitle))

            MediaAttachmentsGridView(
                factory: factory,
                attachments: attachments,
                showAvatars: false
            )
        }
        .padding(.horizontal, tokens.spacingSm)
        .padding(.vertical, tokens.spacing2xl)
        .background(colors.backgroundCoreElevation1.toColor.edgesIgnoringSafeArea(.all))
    }
}

struct StreamVideoPlayer: View {
    @Injected(\.utils) private var utils

    private var cdn: CDN { StreamCDN() }

    private var avPlayerProvider: AVPlayerProvider {
        utils.avPlayerProvider
    }

    let url: URL

    @State var avPlayer: AVPlayer?
    @State var error: Error?

    init(url: URL) {
        self.url = url
    }
    
    var body: some View {
        VStack {
            if let avPlayer {
                VideoPlayer(player: avPlayer)
                    .clipped()
            }
        }
        .onAppear {
            guard avPlayer == nil else {
                avPlayer?.play()
                return
            }
            cdn.fileRequest(for: url) { result in
                switch result {
                case let .success(cdnRequest):
                    avPlayer = AVPlayer(url: cdnRequest.url)
                    try? AVAudioSession.sharedInstance().setCategory(.playback, options: [])
                    avPlayer?.play()
                    self.avPlayerProvider.player(for: cdnRequest.url) { result in
                        switch result {
                        case let .success(player):
                            self.avPlayer = player
                            try? AVAudioSession.sharedInstance().setCategory(.playback, options: [])
                            self.avPlayer?.play()
                        case let .failure(error):
                            self.error = error
                        }
                    }
                case let .failure(error):
                    self.error = error
                }
            }
        }
        .onDisappear {
            avPlayer?.pause()
        }
    }
}

extension ChatUser {
    var onlineText: String {
        if isOnline {
            L10n.Message.Title.online
        } else {
            L10n.Message.Title.offline
        }
    }
}
