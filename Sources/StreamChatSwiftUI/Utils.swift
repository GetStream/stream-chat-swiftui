//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

/// Class providing implementations of several utilities used in the SDK.
/// The default implementations can be replaced in the init method, or directly via the variables.
public class Utils {
    public var dateFormatter: DateFormatter
    public var videoPreviewLoader: VideoPreviewLoader
    public var imageLoader: ImageLoading
    public var imageCDN: ImageCDN
    public var imageProcessor: ImageProcessor
    public var imageMerger: ImageMerging
    public var channelNamer: ChatChannelNamer
    public var chatUserNamer: ChatUserNamer
    public var channelAvatarsMerger: ChannelAvatarsMerging
    public var messageTypeResolver: MessageTypeResolving
    public var messageActionsResolver: MessageActionsResolving
    public var commandsConfig: CommandsConfig
    public var messageListConfig: MessageListConfig
    public var composerConfig: ComposerConfig
    public var shouldSyncChannelControllerOnAppear: (ChatChannelController) -> Bool
    public var snapshotCreator: SnapshotCreator
    public var messageIdBuilder: MessageIdBuilder
    public var sortReactions: (MessageReactionType, MessageReactionType) -> Bool
    public var channelHeaderLoader: ChannelHeaderLoader

    var messageCachingUtils = MessageCachingUtils()
    var messageListDateUtils: MessageListDateUtils
    var channelControllerFactory = ChannelControllerFactory()

    public init(
        dateFormatter: DateFormatter = .makeDefault(),
        videoPreviewLoader: VideoPreviewLoader = DefaultVideoPreviewLoader(),
        imageLoader: ImageLoading = NukeImageLoader(),
        imageCDN: ImageCDN = StreamImageCDN(),
        imageProcessor: ImageProcessor = NukeImageProcessor(),
        imageMerger: ImageMerging = DefaultImageMerger(),
        channelAvatarsMerger: ChannelAvatarsMerging = ChannelAvatarsMerger(),
        messageTypeResolver: MessageTypeResolving = MessageTypeResolver(),
        messageActionResolver: MessageActionsResolving = MessageActionsResolver(),
        commandsConfig: CommandsConfig = DefaultCommandsConfig(),
        messageListConfig: MessageListConfig = MessageListConfig(),
        composerConfig: ComposerConfig = ComposerConfig(),
        channelNamer: @escaping ChatChannelNamer = DefaultChatChannelNamer(),
        chatUserNamer: ChatUserNamer = DefaultChatUserNamer(),
        snapshotCreator: SnapshotCreator = DefaultSnapshotCreator(),
        messageIdBuilder: MessageIdBuilder = DefaultMessageIdBuilder(),
        channelHeaderLoader: ChannelHeaderLoader = ChannelHeaderLoader(),
        sortReactions: @escaping (MessageReactionType, MessageReactionType) -> Bool = Utils.defaultSortReactions,
        shouldSyncChannelControllerOnAppear: @escaping (ChatChannelController) -> Bool = { _ in true }
    ) {
        self.dateFormatter = dateFormatter
        self.videoPreviewLoader = videoPreviewLoader
        self.imageLoader = imageLoader
        self.imageCDN = imageCDN
        self.imageProcessor = imageProcessor
        self.imageMerger = imageMerger
        self.channelNamer = channelNamer
        self.chatUserNamer = chatUserNamer
        self.channelAvatarsMerger = channelAvatarsMerger
        self.messageTypeResolver = messageTypeResolver
        messageActionsResolver = messageActionResolver
        self.commandsConfig = commandsConfig
        self.messageListConfig = messageListConfig
        self.composerConfig = composerConfig
        self.snapshotCreator = snapshotCreator
        self.messageIdBuilder = messageIdBuilder
        self.shouldSyncChannelControllerOnAppear = shouldSyncChannelControllerOnAppear
        self.sortReactions = sortReactions
        self.channelHeaderLoader = channelHeaderLoader
        messageListDateUtils = MessageListDateUtils(messageListConfig: messageListConfig)
    }
    
    public static var defaultSortReactions: (MessageReactionType, MessageReactionType) -> Bool {
        { $0.rawValue < $1.rawValue }
    }
}
