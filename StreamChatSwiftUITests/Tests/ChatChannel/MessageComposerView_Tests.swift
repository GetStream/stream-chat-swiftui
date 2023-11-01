//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import Photos
import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

class MessageComposerView_Tests: StreamChatTestCase {

    override func setUp() {
        super.setUp()
        let utils = Utils(
            messageListConfig: MessageListConfig(becomesFirstResponderOnOpen: true)
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
    }

    func test_messageComposerView_snapshot() {
        // Given
        let factory = DefaultViewFactory.shared
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)

        // When
        let view = MessageComposerView(
            viewFactory: factory,
            channelController: channelController,
            messageController: nil,
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            onMessageSent: {}
        )
        .frame(width: defaultScreenSize.width, height: 100)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_composerInputView_slowMode() {
        // Given
        let factory = DefaultViewFactory.shared

        // When
        let view = ComposerInputView(
            factory: factory,
            text: .constant(""),
            selectedRangeLocation: .constant(0),
            command: .constant(nil),
            addedAssets: [],
            addedFileURLs: [],
            addedCustomAttachments: [],
            quotedMessage: .constant(nil),
            cooldownDuration: 15,
            onCustomAttachmentTap: { _ in },
            removeAttachmentWithId: { _ in }
        )
        .frame(width: defaultScreenSize.width, height: 100)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_trailingComposerView_snapshot() {
        // Given
        let factory = DefaultViewFactory.shared

        // When
        let view = factory.makeTrailingComposerView(
            enabled: true,
            cooldownDuration: 0,
            onTap: {}
        )
        .frame(width: 40, height: 40)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_trailingComposerView_slowMode() {
        // Given
        let factory = DefaultViewFactory.shared

        // When
        let view = factory.makeTrailingComposerView(
            enabled: true,
            cooldownDuration: 15,
            onTap: {}
        )
        .frame(width: 40, height: 40)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_composerInputView_inputTextView() {
        // Given
        let view = InputTextView(
            frame: .init(x: 16, y: 16, width: defaultScreenSize.width - 32, height: 50)
        )

        // When
        view.text = "This is a sample text"
        view.selectedRange.location = 3

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_composerInputView_composerInputTextView() {
        // Given
        let view = ComposerTextInputView(
            text: .constant("This is a sample text"),
            height: .constant(38),
            selectedRangeLocation: .constant(3),
            placeholder: "Send a message",
            editable: true,
            currentHeight: 38
        )
        .frame(width: defaultScreenSize.width, height: 50)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_composerInputView_rangeSelection() {
        // Given
        let view = ComposerTextInputView(
            text: .constant("This is a sample text"),
            height: .constant(38),
            selectedRangeLocation: .constant(3),
            placeholder: "Send a message",
            editable: true,
            currentHeight: 38
        )
        let inputView = InputTextView(
            frame: .init(x: 16, y: 16, width: defaultScreenSize.width - 32, height: 50)
        )

        // When
        inputView.selectedRange.location = 3
        let coordinator = ComposerTextInputView.Coordinator(textInput: view, maxMessageLength: nil)
        coordinator.textViewDidChangeSelection(inputView)

        // Then
        XCTAssert(coordinator.textInput.selectedRangeLocation == 3)
    }

    func test_composerInputView_textSelection() {
        // Given
        let view = ComposerTextInputView(
            text: .constant("New text"),
            height: .constant(38),
            selectedRangeLocation: .constant(3),
            placeholder: "Send a message",
            editable: true,
            currentHeight: 38
        )
        let inputView = InputTextView(
            frame: .init(x: 16, y: 16, width: defaultScreenSize.width - 32, height: 50)
        )

        // When
        inputView.text = "New text"
        inputView.selectedRange.location = 3
        let coordinator = ComposerTextInputView.Coordinator(textInput: view, maxMessageLength: nil)
        coordinator.textViewDidChange(inputView)

        // Then
        XCTAssert(coordinator.textInput.selectedRangeLocation == 3)
        XCTAssert(coordinator.textInput.text == "New text")
    }

    func test_quotedMessageHeaderView_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Quoted message",
            author: .mock(id: .unique)
        )

        // When
        let view = QuotedMessageHeaderView(quotedMessage: .constant(message), showContent: true)
            .frame(width: defaultScreenSize.width, height: 36)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_composerInputView_snapshot() {
        // Given
        let inputView = InputTextView()
        let view = ComposerTextInputView(
            text: .constant("test test"),
            height: .constant(100),
            selectedRangeLocation: .constant(0),
            placeholder: "Send a message",
            editable: true,
            currentHeight: 36
        )
        let coordinator = ComposerTextInputView.Coordinator(textInput: view, maxMessageLength: nil)
        let viewWithSize = view.applyDefaultSize()

        // When
        inputView.scrollToBottom()
        coordinator.updateHeight(inputView, shouldAnimate: true)
        coordinator.updateHeight(inputView, shouldAnimate: false)

        // Then
        assertSnapshot(matching: viewWithSize, as: .image(perceptualPrecision: precision))
        XCTAssert(coordinator.textInput.height == 100)
    }

    func test_photoAttachmentCell_loadingResource() {
        // Given
        let asset = PHAsset()
        let loader = PhotoAssetLoader()
        let cell = PhotoAttachmentCell(
            assetLoader: loader,
            asset: asset,
            onImageTap: { _ in },
            imageSelected: { _ in
                false
            }
        )

        // When
        _ = cell.onAppear()
        _ = cell.onDisappear()
        let newRequestId = cell.requestId

        // Then
        XCTAssert(newRequestId == nil)
    }

    func test_videoIndicatorView_snapshot() {
        // Given
        let view = VideoIndicatorView()
            .frame(width: 100, height: 100)
            .background(.black)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_videoDurationIndicatorView_snapshot() {
        // Given
        let view = VideoDurationIndicatorView(duration: "02:54")
            .frame(width: 100, height: 100)
            .background(.black)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_photosPickerView_snapshot() {
        // Given
        let view = PhotoAttachmentPickerView(
            assets: .init(fetchResult: .init()),
            onImageTap: { _ in },
            imageSelected: { _ in true }
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
}
