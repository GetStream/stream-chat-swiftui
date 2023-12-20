//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class ChatChannelTestHelpers {

    static func makeChannelController(
        chatClient: ChatClient,
        chatChannel: ChatChannel? = nil,
        messages: [ChatMessage] = [],
        lastActiveWatchers: [ChatUser] = []
    ) -> ChatChannelController_Mock {
        let config = ChannelConfig(commands: [Command(name: "giphy", description: "", set: "", args: "")])
        let channel = chatChannel ?? ChatChannel.mockDMChannel(config: config, lastActiveWatchers: lastActiveWatchers)
        let channelQuery = ChannelQuery(cid: channel.cid)
        let channelListQuery = ChannelListQuery(filter: .containMembers(userIds: [chatClient.currentUserId ?? .unique]))
        let channelController = ChatChannelController_Mock.mock(
            channelQuery: channelQuery,
            channelListQuery: channelListQuery,
            client: chatClient
        )
        var channelMessages = messages
        if channelMessages.isEmpty {
            let message = ChatMessage.mock(
                id: .unique,
                cid: channel.cid,
                text: "Test message",
                author: ChatUser.mock(id: chatClient.currentUserId ?? .unique)
            )
            channelMessages = [message]
        }

        channelController.simulateInitial(channel: channel, messages: channelMessages, state: .initialized)
        return channelController
    }

    static let testURL = URL(string: "https://vignette.wikia.nocookie.net/starwars/images/2/20/LukeTLJ.jpg")!

    static var imageAttachments: [AnyChatMessageAttachment] = {
        let attachmentFile = AttachmentFile(type: .png, size: 0, mimeType: "image/png")
        let uploadingState = AttachmentUploadingState(
            localFileURL: testURL,
            state: .pendingUpload,
            file: attachmentFile
        )
        let imageAttachments: [AnyChatMessageAttachment] = [
            ChatMessageImageAttachment(
                id: .unique,
                type: .image,
                payload: ImageAttachmentPayload(
                    title: "test",
                    imageRemoteURL: testURL,
                    extraData: [:]
                ),
                uploadingState: uploadingState
            )
            .asAnyAttachment
        ]

        return imageAttachments
    }()

    static var giphyAttachments: [AnyChatMessageAttachment] = {
        let attachmentFile = AttachmentFile(type: .gif, size: 0, mimeType: "image/gif")
        let uploadingState = AttachmentUploadingState(
            localFileURL: testURL,
            state: .pendingUpload,
            file: attachmentFile
        )
        let giphyAttachments: [AnyChatMessageAttachment] = [
            ChatMessageGiphyAttachment(
                id: .unique,
                type: .giphy,
                payload: GiphyAttachmentPayload(
                    title: "test",
                    previewURL: testURL,
                    actions: []
                ),
                uploadingState: uploadingState
            )
            .asAnyAttachment
        ]

        return giphyAttachments
    }()

    static var videoAttachments: [AnyChatMessageAttachment] = {
        let attachmentFile = AttachmentFile(type: .mp4, size: 0, mimeType: "video/mp4")
        let uploadingState = AttachmentUploadingState(
            localFileURL: testURL,
            state: .pendingUpload,
            file: attachmentFile
        )
        let giphyAttachments: [AnyChatMessageAttachment] = [
            ChatMessageVideoAttachment(
                id: .unique,
                type: .video,
                payload: VideoAttachmentPayload(
                    title: "test",
                    videoRemoteURL: testURL,
                    file: attachmentFile,
                    extraData: nil
                ),
                uploadingState: uploadingState
            )
            .asAnyAttachment
        ]

        return giphyAttachments
    }()

    static var videoAttachment: ChatMessageVideoAttachment = {
        let attachmentFile = AttachmentFile(type: .mp4, size: 0, mimeType: "video/mp4")
        let uploadingState = AttachmentUploadingState(
            localFileURL: testURL,
            state: .pendingUpload,
            file: attachmentFile
        )

        return ChatMessageVideoAttachment(
            id: .unique,
            type: .video,
            payload: VideoAttachmentPayload(
                title: "test",
                videoRemoteURL: testURL,
                file: attachmentFile,
                extraData: nil
            ),
            uploadingState: uploadingState
        )

    }()

    static var linkAttachments: [AnyChatMessageAttachment] = {
        let attachmentFile = AttachmentFile(type: .generic, size: 0, mimeType: "video/mp4")
        let uploadingState = AttachmentUploadingState(
            localFileURL: testURL,
            state: .pendingUpload,
            file: attachmentFile
        )
        let linkAttachments: [AnyChatMessageAttachment] = [
            ChatMessageLinkAttachment(
                id: .unique,
                type: .linkPreview,
                payload: LinkAttachmentPayload(
                    originalURL: testURL,
                    title: "test",
                    text: "test",
                    author: "test",
                    titleLink: testURL,
                    assetURL: testURL,
                    previewURL: testURL
                ),
                uploadingState: uploadingState
            )
            .asAnyAttachment
        ]

        return linkAttachments
    }()

    static var fileAttachments: [AnyChatMessageAttachment] {
        let attachmentFile = AttachmentFile(type: .generic, size: 0, mimeType: "video/mp4")
        let uploadingState = AttachmentUploadingState(
            localFileURL: testURL,
            state: .pendingUpload,
            file: attachmentFile
        )
        let fileAttachments: [AnyChatMessageAttachment] = [
            ChatMessageFileAttachment(
                id: .unique,
                type: .file,
                payload:
                FileAttachmentPayload(
                    title: "test",
                    assetRemoteURL: testURL,
                    file: attachmentFile,
                    extraData: nil
                ),
                uploadingState: uploadingState
            )
            .asAnyAttachment
        ]

        return fileAttachments
    }
    
    static var voiceRecordingAttachments: [AnyChatMessageAttachment] {
        let payload = VoiceRecordingAttachmentPayload(
            title: "Recording",
            voiceRecordingRemoteURL: .localYodaImage,
            file: try! .init(url: .localYodaImage),
            duration: 5,
            waveformData: [0, 0.1, 0.5, 1],
            extraData: nil
        )
        let attachment = ChatMessageVoiceRecordingAttachment(
            id: .unique,
            type: .voiceRecording,
            payload: payload,
            uploadingState: nil
        ).asAnyAttachment
        
        return [attachment]
    }
}
