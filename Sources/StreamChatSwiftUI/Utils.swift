//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import AVKit
import Foundation
import StreamChat
import StreamChatCommonUI

/// Class providing implementations of several utilities used in the SDK.
/// The default implementations can be replaced in the init method, or directly via the variables.
@MainActor public class Utils {
    public var markdownFormatter: MarkdownFormatter

    public var dateFormatter: DateFormatter
    
    /// Date formatter where the format depends on the time passed.
    public var messageTimestampFormatter: MessageTimestampFormatter
    public var galleryHeaderViewDateFormatter: GalleryHeaderViewDateFormatter
    public var messageDateSeparatorFormatter: MessageDateSeparatorFormatter
    public var videoLoader: VideoLoader
    public var imageLoader: ImageLoader
    public var imageProcessor: ImageProcessor
    public var channelNameFormatter: ChannelNameFormatter
    public var avPlayerProvider: AVPlayerProvider
    public var chatUserNamer: ChatUserNamer
    public var messageTypeResolver: MessageTypeResolving
    public var messageActionsResolver: MessageActionsResolving
    public var messageAttachmentPreviewIconProvider: MessageAttachmentPreviewIconProvider
    public var messagePreviewFormatter: MessagePreviewFormatter
    public var commandsConfig: CommandsConfig
    public var channelListConfig: ChannelListConfig
    public var messageListConfig: MessageListConfig
    public var composerConfig: ComposerConfig
    public var pollsConfig: PollsConfig
    public var shouldSyncChannelControllerOnAppear: (ChatChannelController) -> Bool
    public var snapshotCreator: SnapshotCreator
    public var messageIdBuilder: MessageIdBuilder
    public var sortReactions: (MessageReactionType, MessageReactionType) -> Bool
    public var videoDurationFormatter: VideoDurationFormatter
    public var mediaBadgeDurationFormatter: MediaBadgeDurationFormatter
    public var audioRecordingNameFormatter: AudioRecordingNameFormatter
    public var messageRemindersFormatter: any MessageRemindersFormatter
    public var audioPlayerBuilder: () -> AudioPlaying = { StreamAudioPlayer() }
    public var audioPlayer: AudioPlaying {
        if let _audioPlayer {
            return _audioPlayer
        } else {
            let player = audioPlayerBuilder()
            _audioPlayer = player
            return player
        }
    }
    
    public var audioRecorderBuilder: () -> AudioRecording = { StreamAudioRecorder() }
    public var audioRecorder: AudioRecording {
        if let _audioRecorder {
            return _audioRecorder
        } else {
            let recorder = audioRecorderBuilder()
            _audioRecorder = recorder
            return recorder
        }
    }

    @MainActor
    public lazy var audioSessionFeedbackGenerator: AudioSessionFeedbackGenerator = StreamAudioSessionFeedbackGenerator()

    public var originalTranslationsStore = MessageOriginalTranslationsStore()

    var messageCachingUtils = MessageCachingUtils()
    var messageListDateUtils: MessageListDateUtils
    var channelControllerFactory = ChannelControllerFactory()
    
    var _audioPlayer: AudioPlaying?
    var _audioRecorder: AudioRecording?
    var pollsDateFormatter: PollTimestampFormatter = DefaultPollTimestampFormatter()

    public init(
        markdownFormatter: MarkdownFormatter = DefaultMarkdownFormatter(),
        dateFormatter: DateFormatter = .makeDefault(),
        messageTimestampFormatter: MessageTimestampFormatter = ChannelListMessageTimestampFormatter(),
        galleryHeaderViewDateFormatter: GalleryHeaderViewDateFormatter = DefaultGalleryHeaderViewDateFormatter(),
        messageDateSeparatorFormatter: MessageDateSeparatorFormatter = DefaultMessageDateSeparatorFormatter(),
        videoLoader: VideoLoader? = nil,
        imageLoader: ImageLoader = StreamImageLoader(),
        imageProcessor: ImageProcessor = NukeImageProcessor(),
        avPlayerProvider: AVPlayerProvider = DefaultAVPlayerProvider(),
        messageTypeResolver: MessageTypeResolving = MessageTypeResolver(),
        messageActionResolver: MessageActionsResolving = MessageActionsResolver(),
        messageAttachmentPreviewIconProvider: MessageAttachmentPreviewIconProvider = DefaultMessageAttachmentPreviewIconProvider(),
        messagePreviewFormatter: MessagePreviewFormatter = MessagePreviewFormatter(),
        commandsConfig: CommandsConfig = DefaultCommandsConfig(),
        channelListConfig: ChannelListConfig = ChannelListConfig(),
        messageListConfig: MessageListConfig = MessageListConfig(),
        composerConfig: ComposerConfig = ComposerConfig(),
        pollsConfig: PollsConfig = PollsConfig(),
        channelNameFormatter: ChannelNameFormatter = DefaultChannelNameFormatter(),
        chatUserNamer: ChatUserNamer = DefaultChatUserNamer(),
        snapshotCreator: SnapshotCreator = DefaultSnapshotCreator(),
        messageIdBuilder: MessageIdBuilder = DefaultMessageIdBuilder(),
        videoDurationFormatter: VideoDurationFormatter = DefaultVideoDurationFormatter(),
        mediaBadgeDurationFormatter: MediaBadgeDurationFormatter = DefaultMediaBadgeDurationFormatter(),
        audioRecordingNameFormatter: AudioRecordingNameFormatter = DefaultAudioRecordingNameFormatter(),
        messageRemindersFormatter: any MessageRemindersFormatter = DefaultMessageRemindersFormatter(),
        sortReactions: @escaping (MessageReactionType, MessageReactionType) -> Bool = Utils.defaultSortReactions,
        shouldSyncChannelControllerOnAppear: @escaping (ChatChannelController) -> Bool = { _ in true }
    ) {
        self.markdownFormatter = markdownFormatter
        self.dateFormatter = dateFormatter
        self.messageTimestampFormatter = messageTimestampFormatter
        self.galleryHeaderViewDateFormatter = galleryHeaderViewDateFormatter
        self.messageDateSeparatorFormatter = messageDateSeparatorFormatter
        self.imageLoader = imageLoader
        self.videoLoader = videoLoader ?? StreamVideoLoader(imageLoader: imageLoader)
        self.imageProcessor = imageProcessor
        self.channelNameFormatter = channelNameFormatter
        self.avPlayerProvider = avPlayerProvider
        self.chatUserNamer = chatUserNamer
        self.messageTypeResolver = messageTypeResolver
        messageActionsResolver = messageActionResolver
        self.messageAttachmentPreviewIconProvider = messageAttachmentPreviewIconProvider
        self.messagePreviewFormatter = messagePreviewFormatter
        self.commandsConfig = commandsConfig
        self.channelListConfig = channelListConfig
        self.messageListConfig = messageListConfig
        self.composerConfig = composerConfig
        self.snapshotCreator = snapshotCreator
        self.messageIdBuilder = messageIdBuilder
        self.shouldSyncChannelControllerOnAppear = shouldSyncChannelControllerOnAppear
        self.sortReactions = sortReactions
        self.videoDurationFormatter = videoDurationFormatter
        self.mediaBadgeDurationFormatter = mediaBadgeDurationFormatter
        self.audioRecordingNameFormatter = audioRecordingNameFormatter
        self.messageRemindersFormatter = messageRemindersFormatter
        self.pollsConfig = pollsConfig
        messageListDateUtils = MessageListDateUtils(messageListConfig: messageListConfig)
    }
    
    public static var defaultSortReactions: (MessageReactionType, MessageReactionType) -> Bool {
        { $0.rawValue < $1.rawValue }
    }
}

/// Provides a custom `AVPlayer` for a given video URL.
///
/// Conform to this protocol to provide a custom player configuration,
/// such as injecting authentication headers via a custom `AVURLAsset`.
///
/// The URL passed to ``player(for:completion:)`` has already been resolved
/// through the `CDN` protocol's `fileRequest(for:completion:)`.
public protocol AVPlayerProvider {
    /// Creates and returns an `AVPlayer` for the given video URL.
    /// - Parameters:
    ///   - url: A video URL already resolved through the `CDN`.
    ///   - completion: A completion that is called when the player is ready or an error occurred.
    func player(
        for url: URL,
        completion: @escaping ((Result<AVPlayer, Error>) -> Void)
    )
}

/// The default implementation that creates an `AVPlayer` directly from the provided URL.
public final class DefaultAVPlayerProvider: AVPlayerProvider {
    public init() {}

    public func player(
        for url: URL,
        completion: @escaping ((Result<AVPlayer, Error>) -> Void)
    ) {
        completion(.success(AVPlayer(url: url)))
    }
}
