//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

class ViewFactory_Tests: XCTestCase {
    
    private var chatClient: ChatClient = {
        let client = ChatClient.mock()
        client.currentUserId = .unique
        return client
    }()
    
    private let message = ChatMessage.mock(
        id: .unique,
        cid: .unique,
        text: "test",
        author: .mock(id: .unique)
    )
    
    private var streamChat: StreamChat?
    
    override func setUp() {
        super.setUp()
        streamChat = StreamChat(chatClient: chatClient)
    }
    
    func test_viewFactory_makeNoChannelsView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeNoChannelsView()
        
        // Then
        XCTAssert(view is NoChannelsView)
    }
    
    func test_viewFactory_makeLoadingView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeLoadingView()
        
        // Then
        XCTAssert(view is LoadingView)
    }
    
    func test_viewFactory_navigationBarDisplayMode() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let displayMode = viewFactory.navigationBarDisplayMode()
        
        // Then
        XCTAssert(displayMode == .inline)
    }
    
    func test_viewFactory_makeChannelListHeaderViewModifier() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let viewModifier = viewFactory.makeChannelListHeaderViewModifier(title: "Test")
        
        // Then
        XCTAssert(viewModifier is DefaultChannelListHeaderModifier)
    }
    
    func test_viewFactory_supportedMoreChannelActions() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        let channel: ChatChannel = .mockDMChannel()
        let expected = ChannelAction.defaultActions(
            for: channel,
            chatClient: chatClient,
            onDismiss: {},
            onError: { _ in }
        )
        
        // When
        let actions = viewFactory.supportedMoreChannelActions(
            for: channel,
            onDismiss: {},
            onError: { _ in }
        )
        
        // Then
        XCTAssert(actions == expected)
    }
    
    func test_viewFactory_makeMoreChannelActionsView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        let channel: ChatChannel = .mockDMChannel()
        
        // When
        let view = viewFactory.makeMoreChannelActionsView(
            for: channel,
            onDismiss: {},
            onError: { _ in }
        )
        
        // Then
        XCTAssert(view is MoreChannelActionsView)
    }
    
    func test_viewFactory_makeMessageAvatarView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeMessageAvatarView(for: .mock(id: .unique))
        
        // Then
        XCTAssert(view is MessageAvatarView)
    }
    
    func test_viewFactory_makeChannelHeaderViewModifier() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeChannelHeaderViewModifier(for: .mockDMChannel())
        
        // Then
        XCTAssert(view is DefaultChannelHeaderModifier)
    }
    
    func test_viewFactory_makeMessageTextView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeMessageTextView(
            for: message,
            isFirst: true,
            availableWidth: 300,
            scrolledId: .constant(nil)
        )
        
        // Then
        XCTAssert(view is MessageTextView)
    }
    
    func test_viewFactory_makeImageAttachmentView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeImageAttachmentView(
            for: message,
            isFirst: true,
            availableWidth: 300,
            scrolledId: .constant(nil)
        )
        
        // Then
        XCTAssert(view is ImageAttachmentContainer)
    }
    
    func test_viewFactory_makeGiphyAttachmentView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeGiphyAttachmentView(
            for: message,
            isFirst: true,
            availableWidth: 300,
            scrolledId: .constant(nil)
        )
        
        // Then
        XCTAssert(view is GiphyAttachmentView<DefaultViewFactory>)
    }
    
    func test_viewFactory_makeLinkAttachmentView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeLinkAttachmentView(
            for: message,
            isFirst: true,
            availableWidth: 300,
            scrolledId: .constant(nil)
        )
        
        // Then
        XCTAssert(view is LinkAttachmentContainer)
    }
    
    func test_viewFactory_makeFileAttachmentView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeFileAttachmentView(
            for: message,
            isFirst: true,
            availableWidth: 300,
            scrolledId: .constant(nil)
        )
        
        // Then
        XCTAssert(view is FileAttachmentsContainer)
    }
    
    func test_viewFactory_makeVideoAttachmentView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeVideoAttachmentView(
            for: message,
            isFirst: true,
            availableWidth: 300,
            scrolledId: .constant(nil)
        )
        
        // Then
        XCTAssert(view is VideoAttachmentsContainer)
    }
    
    func test_viewFactory_makeDeletedMessageView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeDeletedMessageView(
            for: message,
            isFirst: true,
            availableWidth: 300
        )
        
        // Then
        XCTAssert(view is DeletedMessageView)
    }
    
    func test_viewFactory_makeCustomAttachmentViewType() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeCustomAttachmentViewType(
            for: message,
            isFirst: true,
            availableWidth: 300,
            scrolledId: .constant(nil)
        )
        
        // Then
        XCTAssert(view is EmptyView)
    }
    
    func test_viewFactory_makeGiphyBadgeViewType() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeGiphyBadgeViewType(for: message, availableWidth: 300)
        
        // Then
        XCTAssert(view is GiphyBadgeView)
    }
    
    func test_viewFactory_makeCustomAttachmentView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeCustomAttachmentView(
            addedCustomAttachments: [],
            onCustomAttachmentTap: { _ in }
        )
        
        // Then
        XCTAssert(view is EmptyView)
    }
    
    func test_viewFactory_makeCustomAttachmentPreviewView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeCustomAttachmentPreviewView(
            addedCustomAttachments: [],
            onCustomAttachmentTap: { _ in }
        )
        
        // Then
        XCTAssert(view is EmptyView)
    }
    
    func test_viewFactory_makeFilePickerView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeFilePickerView(
            filePickerShown: .constant(true),
            addedFileURLs: .constant([])
        )
        
        // Then
        XCTAssert(view is FilePickerDisplayView)
    }
    
    func test_viewFactory_makeCameraPickerView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeCameraPickerView(
            selected: .constant(.photos),
            cameraPickerShown: .constant(false),
            cameraImageAdded: { _ in }
        )
        
        // Then
        XCTAssert(view is CameraPickerDisplayView)
    }
    
    func test_viewFactory_makeAssetsAccessPermissionView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeAssetsAccessPermissionView()
        
        // Then
        XCTAssert(view is AssetsAccessPermissionView)
    }
    
    func test_viewFactory_supportedMessageActions() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        let expected = MessageAction.defaultActions(
            factory: DefaultViewFactory.shared,
            for: message,
            channel: .mockDMChannel(),
            chatClient: chatClient,
            onFinish: { _ in },
            onError: { _ in }
        )
        
        // When
        let actions = viewFactory.supportedMessageActions(
            for: message,
            channel: .mockDMChannel(),
            onFinish: { _ in },
            onError: { _ in }
        )
        
        // Then
        XCTAssert(actions == expected)
    }
    
    func test_viewFactory_makeMessageActionsView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeMessageActionsView(
            for: message,
            channel: .mockDMChannel(),
            onFinish: { _ in },
            onError: { _ in }
        )
        
        // Then
        XCTAssert(view is MessageActionsView)
    }
    
    func test_viewFactory_makeMessageReactionsView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeMessageReactionView(message: message)
        
        // Then
        XCTAssert(view is ReactionsContainer)
    }
    
    func test_viewFactory_makeReactionsOverlayView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeReactionsOverlayView(
            channel: .mockDMChannel(),
            currentSnapshot: UIImage(systemName: "checkmark")!,
            messageDisplayInfo: .init(
                message: message,
                frame: .zero,
                contentWidth: 300,
                isFirst: true
            ),
            onBackgroundTap: {},
            onActionExecuted: { _ in }
        )
        
        // Then
        XCTAssert(view is ReactionsOverlayView<DefaultViewFactory>)
    }
    
    func test_viewFactory_makeMessageThreadHeaderViewModifier() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let viewModifier = viewFactory.makeMessageThreadHeaderViewModifier()
        
        // Then
        XCTAssert(viewModifier is DefaultMessageThreadHeaderModifier)
    }
    
    func test_viewFactory_makeSendInChannelView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeSendInChannelView(
            showReplyInChannel: .constant(true),
            isDirectMessage: true
        )
        
        // Then
        XCTAssert(view is SendInChannelView)
    }
    
    func test_viewFactory_makeQuotedMessageHeaderView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeQuotedMessageHeaderView(
            quotedMessage: .constant(message)
        )
        
        // Then
        XCTAssert(view is QuotedMessageHeaderView)
    }
    
    func test_viewFactory_makeQuotedMessageComposerView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeQuotedMessageComposerView(
            quotedMessage: message
        )
        
        // Then
        XCTAssert(view is QuotedMessageViewContainer)
    }
    
    func test_viewFactory_makeEditedMessageHeaderView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeEditedMessageHeaderView(
            editedMessage: .constant(message)
        )
        
        // Then
        XCTAssert(view is EditMessageHeaderView)
    }
    
    func test_viewFactory_makeCommandsContainerView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeCommandsContainerView(suggestions: [:]) { _ in }
        
        // Then
        XCTAssert(view is CommandsContainerView)
    }
    
    func test_viewFactory_makeLeadingSwipeActionsView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeLeadingSwipeActionsView(
            channel: .mockDMChannel(),
            offsetX: 80,
            buttonWidth: 40,
            buttonTapped: { _ in }
        )
        
        // Then
        XCTAssert(view is EmptyView)
    }
    
    func test_viewFactory_makeTrailingSwipeActionsView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeTrailingSwipeActionsView(
            channel: .mockDMChannel(),
            offsetX: 80,
            buttonWidth: 40,
            leftButtonTapped: { _ in },
            rightButtonTapped: { _ in }
        )
        
        // Then
        XCTAssert(view is TrailingSwipeActionsView)
    }
    
    func test_viewFactory_makeMessageReadIndicatorView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeMessageReadIndicatorView(
            channel: .mockDMChannel(),
            message: .mock(id: .unique, cid: .unique, text: "Test", author: .mock(id: .unique))
        )
        
        // Then
        XCTAssert(view is MessageReadIndicatorView)
    }
    
    func test_viewFactory_makeSystemMessageView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeSystemMessageView(
            message: .mock(id: .unique, cid: .unique, text: "Test", author: .mock(id: .unique))
        )
        
        // Then
        XCTAssert(view is SystemMessageView)
    }
}

extension ChannelAction: Equatable {
    
    public static func == (lhs: ChannelAction, rhs: ChannelAction) -> Bool {
        lhs.id == rhs.id
    }
}
