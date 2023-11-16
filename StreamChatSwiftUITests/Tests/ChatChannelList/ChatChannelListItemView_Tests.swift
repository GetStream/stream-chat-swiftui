//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import StreamSwiftTestHelpers
import XCTest

final class ChatChannelListItemView_Tests: StreamChatTestCase {
        
    func test_channelListItem_audioMessage() throws {
        // Given
        let message = try mockAudioMessage(text: "Audio", isSentByCurrentUser: true)
        let channel = ChatChannel.mock(cid: .unique, latestMessages: [message])
        
        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "Test",
            avatar: .circleImage,
            onlineIndicatorShown: true,
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_channelListItem_imageMessage() throws {
        // Given
        let message = try mockImageMessage(text: "Image", isSentByCurrentUser: true)
        let channel = ChatChannel.mock(cid: .unique, latestMessages: [message])
        
        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "Test",
            avatar: .circleImage,
            onlineIndicatorShown: true,
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_channelListItem_videoMessage() throws {
        // Given
        let message = try mockVideoMessage(text: "Video", isSentByCurrentUser: true)
        let channel = ChatChannel.mock(cid: .unique, latestMessages: [message])
        
        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "Test",
            avatar: .circleImage,
            onlineIndicatorShown: true,
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_channelListItem_fileMessage() throws {
        // Given
        let message = try mockFileMessage(title: "Filename", text: "File", isSentByCurrentUser: true)
        let channel = ChatChannel.mock(cid: .unique, latestMessages: [message])
        
        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "Test",
            avatar: .circleImage,
            onlineIndicatorShown: true,
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_channelListItem_giphyMessage() throws {
        // Given
        let message = try mockGiphyMessage(text: "Giphy", isSentByCurrentUser: true)
        let channel = ChatChannel.mock(cid: .unique, latestMessages: [message])
        
        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "Test",
            avatar: .circleImage,
            onlineIndicatorShown: true,
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    // MARK: - private
    
    private func mockAudioMessage(text: String, isSentByCurrentUser: Bool) throws -> ChatMessage {
        .mock(
            id: .unique,
            cid: .unique,
            text: text,
            type: .regular,
            author: .mock(id: "user", name: "User"),
            createdAt: Date(timeIntervalSince1970: 100),
            attachments: [
                .dummy(
                    type: .audio,
                    payload: try JSONEncoder().encode(AudioAttachmentPayload(
                        title: "Some Audio",
                        audioRemoteURL: URL(string: "url")!,
                        file: .init(type: .mp3, size: 123, mimeType: nil),
                        extraData: nil
                    ))
                )
            ],
            localState: nil,
            isSentByCurrentUser: isSentByCurrentUser
        )
    }
    
    private func mockImageMessage(text: String, isSentByCurrentUser: Bool) throws -> ChatMessage {
        .mock(
            id: .unique,
            cid: .unique,
            text: text,
            type: .regular,
            author: .mock(id: "user", name: "User"),
            createdAt: Date(timeIntervalSince1970: 100),
            attachments: [
                .dummy(
                    type: .image,
                    payload: try JSONEncoder().encode(ImageAttachmentPayload(
                        title: "Test",
                        imageRemoteURL: URL(string: "Url")!
                    ))
                )
            ],
            localState: nil,
            isSentByCurrentUser: isSentByCurrentUser
        )
    }
    
    private func mockVideoMessage(text: String, isSentByCurrentUser: Bool) throws -> ChatMessage {
        .mock(
            id: .unique,
            cid: .unique,
            text: text,
            type: .regular,
            author: .mock(id: "user", name: "User"),
            createdAt: Date(timeIntervalSince1970: 100),
            attachments: [
                .dummy(
                    type: .video,
                    payload: try JSONEncoder().encode(VideoAttachmentPayload(
                        title: "Test",
                        videoRemoteURL: URL(string: "Url")!,
                        file: .init(type: .mp4, size: 123, mimeType: nil),
                        extraData: nil
                    ))
                )
            ],
            localState: nil,
            isSentByCurrentUser: isSentByCurrentUser
        )
    }
    
    private func mockFileMessage(title: String?, text: String, isSentByCurrentUser: Bool) throws -> ChatMessage {
        .mock(
            id: .unique,
            cid: .unique,
            text: text,
            type: .regular,
            author: .mock(id: "user", name: "User"),
            createdAt: Date(timeIntervalSince1970: 100),
            attachments: [
                .dummy(
                    type: .file,
                    payload: try JSONEncoder().encode(FileAttachmentPayload(
                        title: title,
                        assetRemoteURL: URL(string: "Url")!,
                        file: .init(type: .pdf, size: 123, mimeType: nil),
                        extraData: nil
                    ))
                )
            ],
            localState: nil,
            isSentByCurrentUser: isSentByCurrentUser
        )
    }
    
    private func mockGiphyMessage(text: String, isSentByCurrentUser: Bool) throws -> ChatMessage {
        .mock(
            id: .unique,
            cid: .unique,
            text: text,
            type: .regular,
            author: .mock(id: "user", name: "User"),
            createdAt: Date(timeIntervalSince1970: 100),
            attachments: [
                .dummy(
                    type: .giphy,
                    payload: try JSONEncoder().encode(GiphyAttachmentPayload(
                        title: "Test",
                        previewURL: URL(string: "Url")!
                    ))
                )
            ],
            localState: nil,
            isSentByCurrentUser: isSentByCurrentUser
        )
    }
}
