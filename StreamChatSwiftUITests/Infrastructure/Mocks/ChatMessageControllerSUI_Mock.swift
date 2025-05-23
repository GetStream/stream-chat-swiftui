//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChat
@testable import StreamChatTestTools

public class ChatMessageControllerSUI_Mock: ChatMessageController {
    /// Creates a new mock instance of `ChatMessageController`.
    public static func mock(
        chatClient: ChatClient,
        currentUserId: UserId = "ID",
        cid: ChannelId? = nil,
        messageId: String = "MockMessage"
    ) -> ChatMessageControllerSUI_Mock {
        if let authenticationRepository = chatClient.authenticationRepository as? AuthenticationRepository_Mock {
            authenticationRepository.mockedCurrentUserId = currentUserId
        }
        var channelId = cid
        if channelId == nil {
            channelId = try! .init(cid: "mock:channel")
        }
        return .init(
            client: chatClient,
            cid: channelId!,
            messageId: messageId,
            replyPaginationHandler: chatClient.makeMessagesPaginationStateHandler()
        )
    }

    public var message_mock: ChatMessage?
    override public var message: ChatMessage? {
        message_mock ?? super.message
    }

    public var replies_mock: [ChatMessage]?
    override public var replies: LazyCachedMapCollection<ChatMessage> {
        replies_mock.map { $0.lazyCachedMap { $0 } } ?? super.replies
    }

    public var state_mock: State?
    override public var state: DataController.State {
        get { state_mock ?? super.state }
        set { super.state = newValue }
    }

    public var startObserversIfNeeded_mock: (() -> Void)?
    override public func startObserversIfNeeded() {
        if let mock = startObserversIfNeeded_mock {
            mock()
            return
        }

        super.startObserversIfNeeded()
    }

    var synchronize_callCount = 0
    override public func synchronize(_ completion: ((Error?) -> Void)? = nil) {
        synchronize_callCount += 1
    }

    var updateDraftReply_callCount = 0
    var updateDraftReply_text: String?

    override public func updateDraftReply(
        text: String,
        isSilent: Bool = false,
        attachments: [AnyAttachmentPayload] = [],
        mentionedUserIds: [UserId] = [],
        quotedMessageId: MessageId? = nil,
        showReplyInChannel: Bool = false,
        command: Command? = nil,
        extraData: [String: RawJSON] = [:],
        completion: ((Result<DraftMessage, any Error>) -> Void)? = nil
    ) {
        updateDraftReply_callCount += 1
        updateDraftReply_text = text
    }

    var deleteDraftReply_callCount = 0

    override public func deleteDraftReply(completion: (((any Error)?) -> Void)? = nil) {
        deleteDraftReply_callCount += 1
    }
}

public extension ChatMessageControllerSUI_Mock {
    /// Simulates the initial conditions. Setting these values doesn't trigger any observer callback.
    func simulateInitial(message: ChatMessage, replies: [ChatMessage], state: DataController.State) {
        message_mock = message
        replies_mock = replies
        state_mock = state
        // Initial simulation should also have a user pre-created
        try? client.databaseContainer.createCurrentUser()
    }

    /// Simulates a change of the `message` value. Observers are notified with the provided `change` value.
    func simulate(message: ChatMessage?, change: EntityChange<ChatMessage>) {
        message_mock = message
        delegateCallback {
            $0.messageController(self, didChangeMessage: change)
        }
    }

    /// Simulates changes in the `replies` array. Observers are notified with the provided `changes` value.
    func simulate(replies: [ChatMessage], changes: [ListChange<ChatMessage>]) {
        replies_mock = replies
        delegateCallback {
            $0.messageController(self, didChangeReplies: changes)
        }
    }

    /// Simulates changes of `state`. Observers are notified with the new value.
    func simulate(state: DataController.State) {
        state_mock = state
        delegateCallback {
            $0.controller(self, didChangeState: state)
        }
    }
}
