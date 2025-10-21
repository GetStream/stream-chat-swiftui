//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Photos
import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

class MessageComposerView_Tests: StreamChatTestCase {
    override func setUp() {
        super.setUp()

        let imageLoader = TestImagesLoader_Mock()
        let utils = Utils(
            imageLoader: imageLoader,
            messageListConfig: MessageListConfig(
                becomesFirstResponderOnOpen: true,
                draftMessagesEnabled: true
            ),
            composerConfig: ComposerConfig(isVoiceRecordingEnabled: true)
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
    
    func test_messageComposerView_recording() {
        // Given
        let factory = DefaultViewFactory.shared
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let viewModel = MessageComposerViewModel(channelController: channelController, messageController: nil)
        viewModel.recordingState = .recording(.zero)
        
        // When
        let view = MessageComposerView(
            viewFactory: factory,
            viewModel: viewModel,
            channelController: channelController,
            messageController: nil,
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            onMessageSent: {}
        )
        .frame(width: defaultScreenSize.width, height: 250)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_messageComposerView_recordingLocked() {
        // Given
        let factory = DefaultViewFactory.shared
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let viewModel = MessageComposerViewModel(channelController: channelController, messageController: nil)
        viewModel.recordingState = .locked
        
        // When
        let view = MessageComposerView(
            viewFactory: factory,
            viewModel: viewModel,
            channelController: channelController,
            messageController: nil,
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            onMessageSent: {}
        )
        .frame(width: defaultScreenSize.width, height: 120)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_messageComposerView_recordingTip() {
        // Given
        let factory = DefaultViewFactory.shared
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let viewModel = MessageComposerViewModel(channelController: channelController, messageController: nil)
        viewModel.recordingState = .showingTip
        
        // When
        let view = MessageComposerView(
            viewFactory: factory,
            viewModel: viewModel,
            channelController: channelController,
            messageController: nil,
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            onMessageSent: {}
        )
        .frame(width: defaultScreenSize.width, height: 120)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_messageComposerView_addedVoiceRecording() {
        // Given
        let factory = DefaultViewFactory.shared
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let viewModel = MessageComposerViewModel(channelController: channelController, messageController: nil)
        viewModel.addedVoiceRecordings = [AddedVoiceRecording(url: .localYodaImage, duration: 5, waveform: [0, 0.1, 0.6, 1.0])]
        
        // When
        let view = MessageComposerView(
            viewFactory: factory,
            viewModel: viewModel,
            channelController: channelController,
            messageController: nil,
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            onMessageSent: {}
        )
        .frame(width: defaultScreenSize.width, height: 200)

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
        .environmentObject(MessageComposerTestUtils.makeComposerViewModel(chatClient: chatClient))
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
        .environmentObject(MessageComposerTestUtils.makeComposerViewModel(chatClient: chatClient))
        .frame(width: 100, height: 40)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_trailingComposerView_slowMode() {
        // Given
        let factory = DefaultViewFactory.shared
        let viewModel = MessageComposerTestUtils.makeComposerViewModel(chatClient: chatClient)
        viewModel.cooldownDuration = 15
        
        // When
        let view = factory.makeTrailingComposerView(
            enabled: true,
            cooldownDuration: 15,
            onTap: {}
        )
        .environmentObject(viewModel)
        .frame(width: 36, height: 36)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_leadingComposerView_uploadFileCapability() {
        // Given
        let factory = DefaultViewFactory.shared
        let mockChannelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        mockChannelController.channel_mock = .mockDMChannel(ownCapabilities: [.sendMessage, .uploadFile])
        let viewModel = MessageComposerViewModel(channelController: mockChannelController, messageController: nil)

        // When
        let pickerTypeState: Binding<PickerTypeState> = .constant(.expanded(.none))
        let view = factory.makeLeadingComposerView(state: pickerTypeState, channelConfig: nil)
            .environmentObject(viewModel)
            .frame(width: 36, height: 36)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_leadingComposerView_withoutUploadFileCapability() {
        // Given
        let factory = DefaultViewFactory.shared
        let mockChannelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        mockChannelController.channel_mock = .mockDMChannel(ownCapabilities: [])
        let viewModel = MessageComposerViewModel(channelController: mockChannelController, messageController: nil)

        // When
        let pickerTypeState: Binding<PickerTypeState> = .constant(.expanded(.none))
        let view = factory.makeLeadingComposerView(state: pickerTypeState, channelConfig: nil)
            .environmentObject(viewModel)
            .frame(width: 36, height: 36)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    // MARK: - Frozen Channel Tests

    func test_messageComposerView_frozenChannel() {
        // Given
        let factory = DefaultViewFactory.shared
        let mockChannelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        // Create a channel without sendMessage capability (simulating frozen channel)
        mockChannelController.channel_mock = .mockDMChannel(ownCapabilities: [.uploadFile, .readEvents])
        let viewModel = MessageComposerViewModel(channelController: mockChannelController, messageController: nil)

        // When
        let view = MessageComposerView(
            viewFactory: factory,
            viewModel: viewModel,
            channelController: mockChannelController,
            messageController: nil,
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            onMessageSent: {}
        )
        .frame(width: defaultScreenSize.width, height: 100)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_composerInputView_frozenChannel() {
        // Given
        let factory = DefaultViewFactory.shared
        let mockChannelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        mockChannelController.channel_mock = .mockDMChannel(ownCapabilities: [.uploadFile, .readEvents])
        let viewModel = MessageComposerViewModel(channelController: mockChannelController, messageController: nil)

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
            cooldownDuration: 0,
            onCustomAttachmentTap: { _ in },
            removeAttachmentWithId: { _ in }
        )
        .environmentObject(viewModel)
        .frame(width: defaultScreenSize.width, height: 100)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_leadingComposerView_frozenChannel() {
        // Given
        let factory = DefaultViewFactory.shared
        let mockChannelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        mockChannelController.channel_mock = .mockDMChannel(ownCapabilities: [.uploadFile, .readEvents])
        let viewModel = MessageComposerViewModel(channelController: mockChannelController, messageController: nil)

        // When
        let pickerTypeState: Binding<PickerTypeState> = .constant(.expanded(.none))
        let view = factory.makeLeadingComposerView(state: pickerTypeState, channelConfig: nil)
            .environmentObject(viewModel)
            .frame(width: 36, height: 36)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_trailingComposerView_frozenChannel() {
        // Given
        let factory = DefaultViewFactory.shared
        let mockChannelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        mockChannelController.channel_mock = .mockDMChannel(ownCapabilities: [.uploadFile, .readEvents])
        let viewModel = MessageComposerViewModel(channelController: mockChannelController, messageController: nil)

        // When
        let view = factory.makeTrailingComposerView(
            enabled: true,
            cooldownDuration: 0,
            onTap: {}
        )
        .environmentObject(viewModel)
        .frame(width: 100, height: 40)

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

    func test_composerInputView_command() {
        let factory = DefaultViewFactory.shared
        let size = CGSize(width: defaultScreenSize.width, height: 100)

        let view = ComposerInputView(
            factory: factory,
            text: .constant(""),
            selectedRangeLocation: .constant(0),
            command: .constant(.init(
                id: .unique,
                typingSuggestion: .empty,
                displayInfo: CommandDisplayInfo(
                    displayName: "Giphy",
                    icon: Images().commandGiphy,
                    format: "",
                    isInstant: true
                )
            )),
            addedAssets: [],
            addedFileURLs: [],
            addedCustomAttachments: [],
            quotedMessage: .constant(nil),
            cooldownDuration: 0,
            onCustomAttachmentTap: { _ in },
            removeAttachmentWithId: { _ in }
        )
        .environmentObject(MessageComposerTestUtils.makeComposerViewModel(chatClient: chatClient))
        .frame(width: size.width, height: size.height)

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles, size: size)

        // Themed
        streamChat?.appearance.colors.tintColor = .mint
        streamChat?.appearance.colors.staticColorText = .black
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles, size: size, suffix: "themed")
    }
  
    // MARK: - Drafts

    // Note: For some reason the text is not rendered in the composer,
    // Maybe it's because of the `UITextView` that is used in the `InputTextView`.
    // Either way, the test of the content is covered.

    func test_composerView_draftWithImageAttachment() throws {
        let size = CGSize(width: defaultScreenSize.width, height: 200)
        let mockDraftMessage = DraftMessage.mock(
            attachments: [
                .dummy(
                    type: .image,
                    payload: try JSONEncoder().encode(
                        ImageAttachmentPayload(
                            title: nil,
                            imageRemoteURL: TestImages.yoda.url,
                            file: .init(type: .jpeg, size: 10, mimeType: nil)
                        )
                    )
                ),
                .dummy(
                    type: .image,
                    payload: try JSONEncoder().encode(
                        ImageAttachmentPayload(
                            title: nil,
                            imageRemoteURL: TestImages.chewbacca.url,
                            file: .init(type: .jpeg, size: 10, mimeType: nil)
                        )
                    )
                )
            ]
        )

        let view = makeComposerView(with: mockDraftMessage)
            .frame(width: size.width, height: size.height)

        AssertSnapshot(view, variants: [.defaultLight], size: size)
    }

    func test_composerView_draftWithVideoAttachment() throws {
        let size = CGSize(width: defaultScreenSize.width, height: 200)
        let mockDraftMessage = DraftMessage.mock(
            attachments: [
                .dummy(
                    type: .video,
                    payload: try JSONEncoder().encode(
                        VideoAttachmentPayload(
                            title: nil,
                            videoRemoteURL: TestImages.yoda.url,
                            thumbnailURL: TestImages.yoda.url,
                            file: .init(type: .mov, size: 10, mimeType: nil),
                            extraData: nil
                        )
                    )
                )
            ]
        )

        let view = makeComposerView(with: mockDraftMessage)
            .frame(width: size.width, height: size.height)

        AssertSnapshot(view, variants: [.defaultLight], size: size)
    }

    func test_composerView_draftWithFileAttachment() throws {
        let size = CGSize(width: defaultScreenSize.width, height: 200)
        let mockDraftMessage = DraftMessage.mock(
            attachments: [
                .dummy(
                    type: .file,
                    payload: try JSONEncoder().encode(
                        FileAttachmentPayload(
                            title: "Test",
                            assetRemoteURL: .localYodaQuote,
                            file: .init(type: .txt, size: 10, mimeType: nil),
                            extraData: nil
                        )
                    )
                )
            ]
        )
        let view = makeComposerView(with: mockDraftMessage)
            .frame(width: size.width, height: size.height)

        AssertSnapshot(view, variants: [.defaultLight], size: size)
    }

    func test_composerView_draftWithVoiceRecordingAttachment() throws {
        let url: URL = URL(fileURLWithPath: "/tmp/\(UUID().uuidString)")
        let duration: TimeInterval = 100
        let waveformData: [Float] = .init(repeating: 0.5, count: 10)
        try Data(count: 1024).write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }

        let size = CGSize(width: defaultScreenSize.width, height: 200)
        let mockDraftMessage = DraftMessage.mock(
            attachments: [
                .dummy(
                    type: .voiceRecording,
                    payload: try JSONEncoder().encode(
                        VoiceRecordingAttachmentPayload(
                            title: "Audio",
                            voiceRecordingRemoteURL: url,
                            file: .init(type: .aac, size: 120, mimeType: "audio/aac"),
                            duration: duration,
                            waveformData: waveformData,
                            extraData: nil
                        )
                    )
                )
            ]
        )
        let view = makeComposerView(with: mockDraftMessage)
            .frame(width: size.width, height: size.height)

        AssertSnapshot(view, variants: [.defaultLight], size: size)
    }

    func test_composerView_draftWithCommand() throws {
        let size = CGSize(width: defaultScreenSize.width, height: 100)
        let mockDraftMessage = DraftMessage.mock(
            text: "/giphy test"
        )

        let view = makeComposerView(with: mockDraftMessage)
            .frame(width: size.width, height: size.height)

        AssertSnapshot(view, variants: [.defaultLight], size: size)
    }

    private func makeComposerView(with draftMessage: DraftMessage) -> some View {
        let factory = DefaultViewFactory.shared
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        channelController.channel_mock = .mock(
            cid: .unique,
            config: ChannelConfig(commands: [Command(name: "giphy", description: "", set: "", args: "")]),
            draftMessage: draftMessage
        )
        let viewModel = MessageComposerViewModel(channelController: channelController, messageController: nil)
        viewModel.attachmentsConverter = SynchronousAttachmentsConverter()
        viewModel.fillDraftMessage()

        return MessageComposerView(
            viewFactory: factory,
            viewModel: viewModel,
            channelController: channelController,
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            onMessageSent: {}
        )
    }
    
    func test_composerQuotedMessage_translated() {
        let factory = DefaultViewFactory.shared
        let size = CGSize(width: defaultScreenSize.width, height: 100)

        let channelController = ChatChannelTestHelpers.makeChannelController(
            chatClient: chatClient,
            chatChannel: .mock(
                cid: .unique,
                membership: .mock(id: .unique, language: .spanish)
            )
        )
        let viewModel = MessageComposerViewModel(channelController: channelController, messageController: nil)
        let view = ComposerInputView(
            factory: factory,
            text: .constant("Hello"),
            selectedRangeLocation: .constant(0),
            command: .constant(nil),
            addedAssets: [],
            addedFileURLs: [],
            addedCustomAttachments: [],
            quotedMessage: .constant(
                .mock(
                    text: "Hello",
                    translations: [.spanish: "Hola"]
                )
            ),
            cooldownDuration: 0,
            onCustomAttachmentTap: { _ in
            },
            removeAttachmentWithId: { _ in }
        )
        .environmentObject(viewModel)
        .frame(width: size.width, height: size.height)

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles, size: size)
    }

    // MARK: - Editing

    func test_composerView_editingMessageWithText() {
        let size = CGSize(width: defaultScreenSize.width, height: 100)
        let mockEditedMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "This is a message being edited",
            author: .mock(id: .unique)
        )

        let view = makeComposerViewWithEditedMessage(mockEditedMessage)
            .frame(width: size.width, height: size.height)

        AssertSnapshot(view, variants: [.defaultLight], size: size)
    }

    func test_composerView_editingMessageWithQuotedMessage() {
        let size = CGSize(width: defaultScreenSize.width, height: 100)
        let mockEditedMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "This is a message being edited",
            author: .mock(id: .unique),
            quotedMessage: .mock(text: "Should not appear")
        )

        let view = makeComposerViewWithEditedMessage(mockEditedMessage)
            .frame(width: size.width, height: size.height)

        AssertSnapshot(view, variants: [.defaultLight], size: size)
    }

    func test_composerView_editingMessageWithImageAttachment() throws {
        let size = CGSize(width: defaultScreenSize.width, height: 200)
        let mockEditedMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Message with image",
            author: .mock(id: .unique),
            attachments: [
                .dummy(
                    type: .image,
                    payload: try JSONEncoder().encode(
                        ImageAttachmentPayload(
                            title: nil,
                            imageRemoteURL: TestImages.yoda.url,
                            file: .init(type: .jpeg, size: 10, mimeType: nil)
                        )
                    )
                )
            ]
        )

        let view = makeComposerViewWithEditedMessage(mockEditedMessage)
            .frame(width: size.width, height: size.height)

        AssertSnapshot(view, variants: [.defaultLight], size: size)
    }

    func test_composerView_editingMessageWithVideoAttachment() throws {
        let size = CGSize(width: defaultScreenSize.width, height: 200)
        let mockEditedMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Message with video",
            author: .mock(id: .unique),
            attachments: [
                .dummy(
                    type: .video,
                    payload: try JSONEncoder().encode(
                        VideoAttachmentPayload(
                            title: nil,
                            videoRemoteURL: TestImages.yoda.url,
                            thumbnailURL: TestImages.yoda.url,
                            file: .init(type: .mov, size: 10, mimeType: nil),
                            extraData: nil
                        )
                    )
                )
            ]
        )

        let view = makeComposerViewWithEditedMessage(mockEditedMessage)
            .frame(width: size.width, height: size.height)

        AssertSnapshot(view, variants: [.defaultLight], size: size)
    }

    func test_composerView_editingMessageWithFileAttachment() throws {
        let size = CGSize(width: defaultScreenSize.width, height: 200)
        let mockEditedMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Message with file",
            author: .mock(id: .unique),
            attachments: [
                .dummy(
                    type: .file,
                    payload: try JSONEncoder().encode(
                        FileAttachmentPayload(
                            title: "Test",
                            assetRemoteURL: .localYodaQuote,
                            file: .init(type: .txt, size: 10, mimeType: nil),
                            extraData: nil
                        )
                    )
                )
            ]
        )

        let view = makeComposerViewWithEditedMessage(mockEditedMessage)
            .frame(width: size.width, height: size.height)

        AssertSnapshot(view, variants: [.defaultLight], size: size)
    }

    func test_composerView_editingMessageWithVoiceRecording() throws {
        let url: URL = URL(fileURLWithPath: "/tmp/\(UUID().uuidString)")
        let duration: TimeInterval = 100
        let waveformData: [Float] = .init(repeating: 0.5, count: 10)
        try Data(count: 1024).write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }

        let size = CGSize(width: defaultScreenSize.width, height: 200)
        let mockEditedMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Message with voice recording",
            author: .mock(id: .unique),
            attachments: [
                .dummy(
                    type: .voiceRecording,
                    payload: try JSONEncoder().encode(
                        VoiceRecordingAttachmentPayload(
                            title: "Audio",
                            voiceRecordingRemoteURL: url,
                            file: .init(type: .aac, size: 120, mimeType: "audio/aac"),
                            duration: duration,
                            waveformData: waveformData,
                            extraData: nil
                        )
                    )
                )
            ]
        )

        let view = makeComposerViewWithEditedMessage(mockEditedMessage)
            .frame(width: size.width, height: size.height)

        AssertSnapshot(view, variants: [.defaultLight], size: size)
    }

    private func makeComposerViewWithEditedMessage(_ editedMessage: ChatMessage) -> some View {
        let factory = DefaultViewFactory.shared
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let viewModel = MessageComposerViewModel(channelController: channelController, messageController: nil)
        viewModel.attachmentsConverter = SynchronousAttachmentsConverter()
        viewModel.fillEditedMessage(editedMessage)

        return MessageComposerView(
            viewFactory: factory,
            viewModel: viewModel,
            channelController: channelController,
            quotedMessage: .constant(nil),
            editedMessage: .constant(editedMessage),
            onMessageSent: {}
        )
    }
    
    // MARK: - Notification Tests
    
    func test_commandsOverlayHiddenNotification_hidesCommandsOverlay() {
        // Given
        let utils = Utils(
            messageListConfig: MessageListConfig(
                hidesCommandsOverlayOnMessageListTap: true
            )
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
        
        let factory = DefaultViewFactory.shared
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let viewModel = MessageComposerViewModel(channelController: channelController, messageController: nil)
        
        // Set up a command to be shown
        viewModel.composerCommand = ComposerCommand(
            id: "testCommand",
            typingSuggestion: TypingSuggestion.empty,
            displayInfo: nil
        )
        
        let view = MessageComposerView(
            viewFactory: factory,
            viewModel: viewModel,
            channelController: channelController,
            messageController: nil,
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            onMessageSent: {}
        )
        view.addToViewHierarchy()

        // When
        NotificationCenter.default.post(
            name: .commandsOverlayHiddenNotification,
            object: nil
        )
        
        // Then
        XCTAssertNil(viewModel.composerCommand)
    }
    
    func test_commandsOverlayHiddenNotification_respectsConfigSetting() {
        // Given
        let utils = Utils(
            messageListConfig: MessageListConfig(
                hidesCommandsOverlayOnMessageListTap: false
            )
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
        
        let factory = DefaultViewFactory.shared
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let viewModel = MessageComposerViewModel(channelController: channelController, messageController: nil)
        
        // Set up a command to be shown
        let testCommand = ComposerCommand(
            id: "testCommand",
            typingSuggestion: TypingSuggestion.empty,
            displayInfo: nil
        )
        viewModel.composerCommand = testCommand
        
        let view = MessageComposerView(
            viewFactory: factory,
            viewModel: viewModel,
            channelController: channelController,
            messageController: nil,
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            onMessageSent: {}
        )
        view.addToViewHierarchy()

        // When
        NotificationCenter.default.post(
            name: .commandsOverlayHiddenNotification,
            object: nil
        )
        
        // Then
        XCTAssertNotNil(viewModel.composerCommand)
        XCTAssertEqual(viewModel.composerCommand?.id, testCommand.id)
    }
    
    func test_attachmentPickerHiddenNotification_hidesAttachmentPicker() {
        // Given
        let utils = Utils(
            messageListConfig: MessageListConfig(
                hidesAttachmentsPickersOnMessageListTap: true
            )
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
        
        let factory = DefaultViewFactory.shared
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let viewModel = MessageComposerViewModel(channelController: channelController, messageController: nil)
        
        // Set up attachment picker to be shown
        viewModel.pickerTypeState = .expanded(.media)
        
        let view = MessageComposerView(
            viewFactory: factory,
            viewModel: viewModel,
            channelController: channelController,
            messageController: nil,
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            onMessageSent: {}
        )
        view.addToViewHierarchy()

        // When
        NotificationCenter.default.post(
            name: .attachmentPickerHiddenNotification,
            object: nil
        )
        
        // Then
        XCTAssertEqual(viewModel.pickerTypeState, .expanded(.none))
    }
    
    func test_attachmentPickerHiddenNotification_respectsConfigSetting() {
        // Given
        let utils = Utils(
            messageListConfig: MessageListConfig(
                hidesAttachmentsPickersOnMessageListTap: false
            )
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
        
        let factory = DefaultViewFactory.shared
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let viewModel = MessageComposerViewModel(channelController: channelController, messageController: nil)
        
        // Set up attachment picker to be shown
        viewModel.pickerTypeState = .expanded(.media)
        
        let view = MessageComposerView(
            viewFactory: factory,
            viewModel: viewModel,
            channelController: channelController,
            messageController: nil,
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            onMessageSent: {}
        )
        view.addToViewHierarchy()

        // When
        NotificationCenter.default.post(
            name: .attachmentPickerHiddenNotification,
            object: nil
        )
        
        // Then
        XCTAssertEqual(viewModel.pickerTypeState, .expanded(.media))
    }
}

class SynchronousAttachmentsConverter: MessageAttachmentsConverter {
    override func attachmentsToAssets(
        _ attachments: [AnyChatMessageAttachment],
        completion: @escaping (ComposerAssets) -> Void
    ) {
        super.attachmentsToAssets(attachments, with: nil, completion: completion)
    }
}
