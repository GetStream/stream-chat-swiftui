//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

/// Class providing implementations of several utilities used in the SDK.
/// The default implementations can be replaced in the init method, or directly via the variables.
public class Utils {
    public var markdownFormatter: MarkdownFormatter

    public var dateFormatter: DateFormatter
    
    /// Date formatter where the format depends on the time passed.
    ///
    /// - SeeAlso: ``ChannelListConfig/messageRelativeDateFormatEnabled``.
    public var messageRelativeDateFormatter: DateFormatter
    public var galleryHeaderViewDateFormatter: DateFormatter
    public var videoPreviewLoader: VideoPreviewLoader
    public var imageLoader: ImageLoading
    public var imageCDN: ImageCDN
    public var imageProcessor: ImageProcessor
    public var imageMerger: ImageMerging
    public var fileCDN: FileCDN
    public var channelNamer: ChatChannelNamer
    public var chatUserNamer: ChatUserNamer
    public var channelAvatarsMerger: ChannelAvatarsMerging
    public var messageTypeResolver: MessageTypeResolving
    public var messageActionsResolver: MessageActionsResolving
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
    public var channelHeaderLoader: ChannelHeaderLoader
    public var videoDurationFormatter: VideoDurationFormatter
    public var audioRecordingNameFormatter: AudioRecordingNameFormatter
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

    public lazy var audioSessionFeedbackGenerator: AudioSessionFeedbackGenerator = StreamAudioSessionFeedbackGenerator()

    public var originalTranslationsStore = MessageOriginalTranslationsStore()

    var messageCachingUtils = MessageCachingUtils()
    var messageListDateUtils: MessageListDateUtils
    var channelControllerFactory = ChannelControllerFactory()
    
    internal var _audioPlayer: AudioPlaying?
    internal var _audioRecorder: AudioRecording?
    internal var pollsDateFormatter = PollsDateFormatter()

    public init(
        markdownFormatter: MarkdownFormatter = DefaultMarkdownFormatter(),
        dateFormatter: DateFormatter = .makeDefault(),
        messageRelativeDateFormatter: DateFormatter = MessageRelativeDateFormatter(),
        galleryHeaderViewDateFormatter: DateFormatter = GalleryHeaderViewDateFormatter(),
        videoPreviewLoader: VideoPreviewLoader = DefaultVideoPreviewLoader(),
        imageLoader: ImageLoading = NukeImageLoader(),
        imageCDN: ImageCDN = StreamImageCDN(),
        imageProcessor: ImageProcessor = NukeImageProcessor(),
        imageMerger: ImageMerging = DefaultImageMerger(),
        fileCDN: FileCDN = DefaultFileCDN(),
        channelAvatarsMerger: ChannelAvatarsMerging = ChannelAvatarsMerger(),
        messageTypeResolver: MessageTypeResolving = MessageTypeResolver(),
        messageActionResolver: MessageActionsResolving = MessageActionsResolver(),
        messagePreviewFormatter: MessagePreviewFormatter = MessagePreviewFormatter(),
        commandsConfig: CommandsConfig = DefaultCommandsConfig(),
        channelListConfig: ChannelListConfig = ChannelListConfig(),
        messageListConfig: MessageListConfig = MessageListConfig(),
        composerConfig: ComposerConfig = ComposerConfig(),
        pollsConfig: PollsConfig = PollsConfig(),
        channelNamer: @escaping ChatChannelNamer = DefaultChatChannelNamer(),
        chatUserNamer: ChatUserNamer = DefaultChatUserNamer(),
        snapshotCreator: SnapshotCreator = DefaultSnapshotCreator(),
        messageIdBuilder: MessageIdBuilder = DefaultMessageIdBuilder(),
        channelHeaderLoader: ChannelHeaderLoader = ChannelHeaderLoader(),
        videoDurationFormatter: VideoDurationFormatter = DefaultVideoDurationFormatter(),
        audioRecordingNameFormatter: AudioRecordingNameFormatter = DefaultAudioRecordingNameFormatter(),
        sortReactions: @escaping (MessageReactionType, MessageReactionType) -> Bool = Utils.defaultSortReactions,
        shouldSyncChannelControllerOnAppear: @escaping (ChatChannelController) -> Bool = { _ in true }
    ) {
        self.markdownFormatter = markdownFormatter
        self.dateFormatter = dateFormatter
        self.messageRelativeDateFormatter = messageRelativeDateFormatter
        self.galleryHeaderViewDateFormatter = galleryHeaderViewDateFormatter
        self.videoPreviewLoader = videoPreviewLoader
        self.imageLoader = imageLoader
        self.imageCDN = imageCDN
        self.imageProcessor = imageProcessor
        self.imageMerger = imageMerger
        self.fileCDN = fileCDN
        self.channelNamer = channelNamer
        self.chatUserNamer = chatUserNamer
        self.channelAvatarsMerger = channelAvatarsMerger
        self.messageTypeResolver = messageTypeResolver
        messageActionsResolver = messageActionResolver
        self.messagePreviewFormatter = messagePreviewFormatter
        self.commandsConfig = commandsConfig
        self.channelListConfig = channelListConfig
        self.messageListConfig = messageListConfig
        self.composerConfig = composerConfig
        self.snapshotCreator = snapshotCreator
        self.messageIdBuilder = messageIdBuilder
        self.shouldSyncChannelControllerOnAppear = shouldSyncChannelControllerOnAppear
        self.sortReactions = sortReactions
        self.channelHeaderLoader = channelHeaderLoader
        self.videoDurationFormatter = videoDurationFormatter
        self.audioRecordingNameFormatter = audioRecordingNameFormatter
        self.pollsConfig = pollsConfig
        messageListDateUtils = MessageListDateUtils(messageListConfig: messageListConfig)
    }
    
    public static var defaultSortReactions: (MessageReactionType, MessageReactionType) -> Bool {
        { $0.rawValue < $1.rawValue }
    }
}
