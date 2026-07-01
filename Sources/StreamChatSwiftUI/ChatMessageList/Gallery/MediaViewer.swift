//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import AVKit
import StreamChat
import StreamChatCommonUI
import SwiftUI
import UniformTypeIdentifiers

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
        NavigationView {
            GeometryReader { reader in
                VStack(spacing: 0) {
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

                    viewFactory.makeMediaViewerFooterView(
                        options: MediaViewerFooterViewOptions(
                            shareContent: sharingContent,
                            shareFallbackURL: sharingFallbackURL,
                            selected: selected,
                            totalCount: mediaAttachments.count,
                            gridShown: $gridShown
                        )
                    )
                }
            }
            .background(Color(colors.backgroundCoreApp).edgesIgnoringSafeArea(.all))
            .modifier(
                viewFactory.makeMediaViewerToolbarModifier(
                    options: MediaViewerToolbarModifierOptions(
                        title: author.name ?? "",
                        subtitle: message.map {
                            utils.galleryHeaderViewDateFormatter.format($0.createdAt)
                        } ?? author.onlineText,
                        isShown: $isShown
                    )
                )
            )
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $gridShown) {
            GridMediaView(
                factory: viewFactory,
                attachments: mediaAttachments,
                onItemSelected: { index in
                    selected = index
                    gridShown = false
                }
            )
            .modifier(PresentationDetentsModifier(sheetSizes: [.medium, .large]))
        }
    }

    private var sharingContent: [UIImage] {
        if let image = loadedImages[selected] {
            [image]
        } else {
            []
        }
    }

    /// Used when there is no in-memory ``UIImage`` (videos never populate ``loadedImages``; images may still be loading).
    private var sharingFallbackURL: URL? {
        guard loadedImages[selected] == nil,
              selected >= 0,
              selected < mediaAttachments.count else { return nil }
        return mediaAttachments[selected].url
    }
}

struct GridMediaView<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    let factory: Factory
    let attachments: [MediaAttachment]
    var onItemSelected: ((Int) -> Void)?

    var body: some View {
        VStack(spacing: tokens.spacingLg) {
            Text(L10n.ChatInfo.Media.title)
                .font(fonts.bodyBold)
                .foregroundColor(Color(colors.navigationBarTitle))

            MediaAttachmentsGridView(
                factory: factory,
                attachments: attachments,
                showAvatars: false,
                onItemSelected: onItemSelected
            )
        }
        .padding(.horizontal, tokens.spacingSm)
        .padding(.vertical, tokens.spacing2xl)
        .background(colors.backgroundCoreElevation1.toColor.edgesIgnoringSafeArea(.all))
    }
}

// MARK: - Footer

/// Default footer view for the media viewer.
/// Displays a share button, page counter, and grid toggle button.
public struct MediaViewerFooterView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens

    let shareContent: [UIImage]
    let shareFallbackURL: URL?
    let selected: Int
    let totalCount: Int
    @Binding var gridShown: Bool

    public init(
        shareContent: [UIImage],
        shareFallbackURL: URL? = nil,
        selected: Int,
        totalCount: Int,
        gridShown: Binding<Bool>
    ) {
        self.shareContent = shareContent
        self.shareFallbackURL = shareFallbackURL
        self.selected = selected
        self.totalCount = totalCount
        _gridShown = gridShown
    }

    public var body: some View {
        HStack {
            ShareButtonView(content: shareActivityItems)

            Spacer()

            Text(L10n.Message.Gallery.pageCount(selected + 1, totalCount))
                .font(fonts.subheadlineBold)
                .foregroundColor(colors.textPrimary.toColor)

            Spacer()

            StreamIconButton(role: .secondary, style: .ghost, size: .medium) {
                gridShown = true
            } icon: {
                Image(uiImage: images.gallery)
                    .customizable()
                    .frame(width: tokens.iconSizeSm, height: tokens.iconSizeSm)
                    .foregroundColor(Color(colors.textSecondary))
            }
        }
        .padding(.horizontal, tokens.spacingSm)
        .frame(height: 48 + tokens.spacingSm * 2)
        .background(Color(colors.backgroundCoreElevation1))
    }

    private var shareActivityItems: [Any] {
        if !shareContent.isEmpty {
            return shareContent
        }
        if let shareFallbackURL {
            return [shareFallbackURL]
        }
        return []
    }
}

// MARK: - Toolbar

/// Toolbar modifier for the media viewer navigation bar.
/// Displays a back button, title/subtitle, in the navigation toolbar.
public struct MediaViewerToolbarModifier: ViewModifier {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    let title: String
    let subtitle: String
    @Binding var isShown: Bool

    public init(title: String, subtitle: String, isShown: Binding<Bool>) {
        self.title = title
        self.subtitle = subtitle
        _isShown = isShown
    }

    public func body(content: Content) -> some View {
        content
            .toolbarThemed {
                toolbarContent()
            }
    }

    @ToolbarContentBuilder private func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                isShown = false
            } label: {
                Image(systemName: "chevron.backward")
                    .renderingMode(.template)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(dismissButtonColor)
            }
        }

        ToolbarItem(placement: .principal) {
            VStack(spacing: 2) {
                Text(title)
                    .font(fonts.headline)
                    .foregroundColor(Color(colors.textPrimary))
                Text(subtitle)
                    .font(fonts.subheadline)
                    .foregroundColor(Color(colors.textSecondary))
            }
        }
    }

    private var dismissButtonColor: Color {
        guard colors.navigationBarTintColor != colors.accentPrimary else {
            return Color(colors.textPrimary)
        }
        return Color(colors.navigationBarTintColor)
    }
}

struct StreamVideoPlayer: View {
    @Injected(\.utils) private var utils

    let url: URL

    @State var avPlayer: AVPlayer?
    @State var error: Error?
    @State private var isVisible = false

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
            isVisible = true
            guard avPlayer == nil else {
                avPlayer?.play()
                return
            }
            loadPlayer()
        }
        .onDisappear {
            isVisible = false
            avPlayer?.pause()
        }
    }

    private func loadPlayer() {
        let loader = AVPlayerLoader(
            url: url,
            mediaLoader: utils.mediaLoader,
            avPlayerProvider: utils.avPlayerProvider,
            cache: utils.videoAttachmentDiskCache,
            policy: utils.messageListConfig.videoAttachmentCachingPolicy
        )
        Task { @MainActor in
            let result = await loader.load()
            guard isVisible else { return }
            switch result {
            case let .success(player):
                avPlayer = player
                try? AVAudioSession.sharedInstance().setCategory(.playback, options: [])
                avPlayer?.play()
            case let .failure(error):
                self.error = error
            }
        }
    }
}

extension StreamVideoPlayer {
    @MainActor final class AVPlayerLoader {
        private let url: URL
        private let mediaLoader: MediaLoader
        private let avPlayerProvider: AVPlayerProvider
        private let cache: LRUDiskCache
        private let policy: VideoAttachmentCachingPolicy
        private let isPlayable: @Sendable (URL) async -> Bool

        init(
            url: URL,
            mediaLoader: MediaLoader,
            avPlayerProvider: AVPlayerProvider,
            cache: LRUDiskCache,
            policy: VideoAttachmentCachingPolicy,
            isPlayable: @escaping @Sendable (URL) async -> Bool = AVPlayerLoader.isPlayable
        ) {
            self.url = url
            self.mediaLoader = mediaLoader
            self.avPlayerProvider = avPlayerProvider
            self.cache = cache
            self.policy = policy
            self.isPlayable = isPlayable
        }

        func load() async -> Result<AVPlayer, Error> {
            let canCache = policy.maxCacheSize > 0 && !url.isFileURL && isContentTypeAllowed(url)
            let key = url.path
            let fileExtension = url.pathExtension.isEmpty ? "mp4" : url.pathExtension

            if canCache, let localURL = await cache.cachedFileURL(forKey: key, fileExtension: fileExtension) {
                if await isPlayable(localURL) {
                    return await loadPlayer(from: MediaLoaderVideoAsset(asset: AVURLAsset(url: localURL)))
                }
                log.debug("Cached video is not playable; evicting and streaming from remote")
                await cache.remove(forKey: key, fileExtension: fileExtension)
                return await loadFromRemote()
            }

            if canCache {
                prefetchToCache(key: key, fileExtension: fileExtension)
            }
            return await loadFromRemote()
        }

        private func isContentTypeAllowed(_ url: URL) -> Bool {
            guard let type = UTType(filenameExtension: url.pathExtension.lowercased()) else { return false }
            return policy.allowedContentTypes.contains { type.conforms(to: $0) }
        }

        private nonisolated static func isPlayable(_ url: URL) async -> Bool {
            await withCheckedContinuation { continuation in
                let asset = AVURLAsset(url: url)
                asset.loadValuesAsynchronously(forKeys: ["playable"]) {
                    continuation.resume(
                        returning: asset.statusOfValue(forKey: "playable", error: nil) == .loaded && asset.isPlayable
                    )
                }
            }
        }

        private func loadFromRemote() async -> Result<AVPlayer, Error> {
            do {
                let videoAsset = try await mediaLoader.loadVideoAsset(at: url)
                return await loadPlayer(from: videoAsset)
            } catch {
                return .failure(error)
            }
        }

        private func loadPlayer(from videoAsset: MediaLoaderVideoAsset) async -> Result<AVPlayer, Error> {
            await withCheckedContinuation { continuation in
                avPlayerProvider.player(from: videoAsset) { continuation.resume(returning: $0) }
            }
        }

        private func prefetchToCache(key: String, fileExtension: String) {
            mediaLoader.loadFileRequest(for: url) { result in
                switch result {
                case let .success(fileRequest):
                    let cache = self.cache
                    URLSession.shared.downloadTask(with: fileRequest.urlRequest) { tempURL, response, error in
                        if let error {
                            log.debug("Video cache prefetch download failed: \(error)")
                            return
                        }
                        guard let tempURL,
                              let http = response as? HTTPURLResponse,
                              (200..<300).contains(http.statusCode) else {
                            log.debug("Video cache prefetch received a non-success response")
                            return
                        }
                        let stableURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
                        do {
                            try FileManager.default.moveItem(at: tempURL, to: stableURL)
                        } catch {
                            log.debug("Video cache prefetch could not move the downloaded file: \(error)")
                            return
                        }
                        Task {
                            if await cache.store(fileAt: stableURL, forKey: key, fileExtension: fileExtension) == nil {
                                log.debug("Video cache prefetch could not store the downloaded file")
                                try? FileManager.default.removeItem(at: stableURL)
                            }
                        }
                    }.resume()
                case let .failure(error):
                    log.debug("Video cache prefetch file request failed: \(error)")
                }
            }
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
