//
// Copyright © 2022 Stream.io Inc. All rights reserved.
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
    public var channelAvatarsMerger: ChannelAvatarsMerging
    public var messageTypeResolver: MessageTypeResolving
    public var messageActionsResolver: MessageActionsResolving
    public var commandsConfig: CommandsConfig
    public var messageListConfig: MessageListConfig
    public var composerConfig: ComposerConfig
    public var shouldSyncChannelControllerOnAppear: (ChatChannelController) -> Bool
    
    var messageCachingUtils = MessageCachingUtils()
    var messageListDateUtils: MessageListDateUtils
    
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
        shouldSyncChannelControllerOnAppear: @escaping (ChatChannelController) -> Bool = { _ in true }
    ) {
        self.dateFormatter = dateFormatter
        self.videoPreviewLoader = videoPreviewLoader
        self.imageLoader = imageLoader
        self.imageCDN = imageCDN
        self.imageProcessor = imageProcessor
        self.imageMerger = imageMerger
        self.channelNamer = channelNamer
        self.channelAvatarsMerger = channelAvatarsMerger
        self.messageTypeResolver = messageTypeResolver
        messageActionsResolver = messageActionResolver
        self.commandsConfig = commandsConfig
        self.messageListConfig = messageListConfig
        self.composerConfig = composerConfig
        self.shouldSyncChannelControllerOnAppear = shouldSyncChannelControllerOnAppear
        messageListDateUtils = MessageListDateUtils(messageListConfig: messageListConfig)
    }
}
