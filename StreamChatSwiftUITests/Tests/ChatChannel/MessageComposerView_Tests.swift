//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Photos
import SnapshotTesting
@testable import StreamChat
@testable import StreamChatCommonUI
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor class MessageComposerView_Tests: StreamChatTestCase {
    let composerWidth: CGFloat = 375

    override func setUp() {
        super.setUp()
        
        let utils = Utils(
            mediaLoader: MediaLoader_Mock(),
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
            willSendMessage: {}
        )
        .frame(width: composerWidth, height: 200)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_messageComposerView_rtlSnapshot() {
        // Given
        let factory = DefaultViewFactory.shared
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)

        // When – RTL layout (e.g. Arabic)
        let view = MessageComposerView(
            viewFactory: factory,
            channelController: channelController,
            messageController: nil,
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            willSendMessage: {}
        )
        .environment(\.layoutDirection, .rightToLeft)
        .frame(width: defaultScreenSize.width, height: 100)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision), named: "rtl")
    }

    func test_messageComposerView_rtlWithTextSnapshot() {
        // Given – composer with text so Send button is enabled (arrow up) in RTL
        let factory = DefaultViewFactory.shared
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let viewModel = MessageComposerViewModel(channelController: channelController, messageController: nil)
        viewModel.text = "Hello"

        // When – RTL layout
        let view = MessageComposerView(
            viewFactory: factory,
            viewModel: viewModel,
            channelController: channelController,
            messageController: nil,
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            willSendMessage: {}
        )
        .environment(\.layoutDirection, .rightToLeft)
        .frame(width: defaultScreenSize.width, height: 100)

        // Then – Send button should show arrow up
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision), named: "rtl-with-text")
    }
    
    // MARK: - Voice Recording

    func test_messageComposerView_recording() {
        // Given
        let size = CGSize(width: composerWidth, height: 250)
        let factory = DefaultViewFactory.shared
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let viewModel = MessageComposerViewModel(channelController: channelController, messageController: nil)
        viewModel.recordingState = .recording

        // When
        let view = MessageComposerView(
            viewFactory: factory,
            viewModel: viewModel,
            channelController: channelController,
            messageController: nil,
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            willSendMessage: {}
        )
        .frame(width: size.width, height: size.height)

        // Then
        AssertSnapshot(view, size: size)
    }

    func test_messageComposerView_recordingSlideToCancel() {
        // Given
        let size = CGSize(width: composerWidth, height: 250)
        let factory = DefaultViewFactory.shared
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let viewModel = MessageComposerViewModel(channelController: channelController, messageController: nil)
        viewModel.recordingState = .recording
        viewModel.recordingGestureLocation = CGPoint(x: -50, y: 0)

        // When
        let view = MessageComposerView(
            viewFactory: factory,
            viewModel: viewModel,
            channelController: channelController,
            messageController: nil,
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            willSendMessage: {}
        )
        .frame(width: size.width, height: size.height)

        // Then
        AssertSnapshot(view, size: size)
    }

    func test_messageComposerView_recordingLocked() {
        // Given
        let size = CGSize(width: composerWidth, height: 120)
        let factory = DefaultViewFactory.shared
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let viewModel = MessageComposerViewModel(channelController: channelController, messageController: nil)
        viewModel.recordingState = .locked
        viewModel.audioRecordingInfo = AudioRecordingInfo(
            waveform: [0, 0.2, 0.5, 0.8, 1.0, 0.6, 0.3, 0.1, 0.4, 0.7],
            duration: 5.0
        )

        // When
        let view = MessageComposerView(
            viewFactory: factory,
            viewModel: viewModel,
            channelController: channelController,
            messageController: nil,
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            willSendMessage: {}
        )
        .frame(width: size.width, height: size.height)

        // Then
        AssertSnapshot(view, size: size)
    }

    func test_messageComposerView_recordingStopped() {
        // Given
        let size = CGSize(width: composerWidth, height: 120)
        let factory = DefaultViewFactory.shared
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let viewModel = MessageComposerViewModel(channelController: channelController, messageController: nil)
        viewModel.recordingState = .stopped
        viewModel.audioRecordingInfo = AudioRecordingInfo(
            waveform: [0, 0.2, 0.5, 0.8, 1.0, 0.6, 0.3, 0.1, 0.4, 0.7],
            duration: 12.5
        )
        viewModel.pendingAudioRecording = AddedVoiceRecording(
            url: .localYodaImage,
            duration: 12.5,
            waveform: [0, 0.2, 0.5, 0.8, 1.0, 0.6, 0.3, 0.1, 0.4, 0.7]
        )

        // When
        let view = MessageComposerView(
            viewFactory: factory,
            viewModel: viewModel,
            channelController: channelController,
            messageController: nil,
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            willSendMessage: {}
        )
        .frame(width: size.width, height: size.height)

        // Then
        AssertSnapshot(view, size: size)
    }

    func test_messageComposerView_recordingWhileQuoting() {
        let size = CGSize(width: composerWidth, height: 250)
        let factory = DefaultViewFactory.shared
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let quoted = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Original message being replied to",
            author: .mock(id: .unique, name: "John Smart")
        )
        let viewModel = MessageComposerViewModel(channelController: channelController, messageController: nil)
        viewModel.recordingState = .recording

        let view = MessageComposerView(
            viewFactory: factory,
            viewModel: viewModel,
            channelController: channelController,
            messageController: nil,
            quotedMessage: .constant(quoted),
            editedMessage: .constant(nil),
            willSendMessage: {}
        )
        .frame(width: size.width, height: size.height)

        AssertSnapshot(view, variants: [.defaultLight], size: size)
    }

    func test_messageComposerView_recordingTipSnackbar() {
        // Given
        let size = CGSize(width: composerWidth, height: 200)
        let factory = DefaultViewFactory.shared
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let viewModel = MessageComposerViewModel(channelController: channelController, messageController: nil)
        viewModel.showRecordingTip()

        // When
        let view = MessageComposerView(
            viewFactory: factory,
            viewModel: viewModel,
            channelController: channelController,
            messageController: nil,
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            willSendMessage: {}
        )
        .frame(width: size.width, height: size.height)

        // Then
        AssertSnapshot(view, size: size)
    }

    func test_messageComposerView_addedVoiceRecording() {
        // Given
        let size = CGSize(width: composerWidth, height: 200)
        let factory = DefaultViewFactory.shared
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let viewModel = MessageComposerViewModel(channelController: channelController, messageController: nil)
        viewModel.addedVoiceRecordings = [
            AddedVoiceRecording(url: .localYodaImage, duration: 5, waveform: [0, 0.1, 0.6, 1.0])
        ]

        // When
        let view = MessageComposerView(
            viewFactory: factory,
            viewModel: viewModel,
            channelController: channelController,
            messageController: nil,
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            willSendMessage: {}
        )
        .frame(width: size.width, height: size.height)

        // Then
        AssertSnapshot(view, size: size)
    }

    func test_messageComposerView_voiceRecordingPlaying() {
        // Given
        let url = URL(string: "https://example.com/recording.m4a")!
        let recording = AddedVoiceRecording(
            url: url,
            duration: 10,
            waveform: [0, 0.1, 0.4, 0.7, 1.0, 0.8, 0.5, 0.3, 0.6, 0.9]
        )
        let handler = VoiceRecordingHandler()
        handler.isPlaying = true
        handler.context = AudioPlaybackContext(
            assetLocation: url,
            duration: 10,
            currentTime: 4.2,
            state: .playing,
            rate: .normal,
            isSeeking: false
        )
        let size = CGSize(width: composerWidth - 32, height: 100)

        // When
        let view = ComposerVoiceRecordingAttachmentView(
            handler: handler,
            recording: recording,
            onDiscardAttachment: { _ in }
        )
        .frame(width: size.width)
        .padding()

        // Then
        AssertSnapshot(view, variants: [.defaultLight], size: size)
    }

    func test_composerInputView_slowMode() {
        // Given
        let factory = DefaultViewFactory.shared
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)

        // When
        let view = ComposerInputView(
            factory: factory,
            channelController: channelController,
            text: .constant(""),
            selectedRangeLocation: .constant(0),
            command: .constant(nil),
            recordingState: .constant(.initial),
            recordingGestureLocation: .constant(.zero),
            composerAssets: [],
            addedCustomAttachments: [],
            addedVoiceRecordings: [],
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            cooldownDuration: 15,
            hasContent: true,
            canSendMessage: true,
            audioRecordingInfo: .initial,
            pendingAudioRecordingURL: nil,
            onCustomAttachmentTap: { _ in },
            removeAttachmentWithId: { _ in },
            sendMessage: {},
            onImagePasted: { _ in },
            startRecording: {},
            stopRecording: {},
            confirmRecording: {},
            discardRecording: {},
            previewRecording: {},
            showRecordingTip: {},
            sendInChannelShown: false,
            showReplyInChannel: .constant(false)
        )
        .frame(width: composerWidth, height: 200)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_trailingComposerView_snapshot() {
        // Given
        let factory = DefaultViewFactory.shared

        // When
        let view = factory.makeTrailingComposerView(
            options: TrailingComposerViewOptions(
                enabled: true,
                cooldownDuration: 0,
                onTap: {}
            )
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
            options: TrailingComposerViewOptions(
                enabled: true,
                cooldownDuration: 15,
                onTap: {}
            )
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
        let view = factory.makeLeadingComposerView(options: LeadingComposerViewOptions(state: pickerTypeState, channelConfig: nil))
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
        let view = factory.makeLeadingComposerView(options: LeadingComposerViewOptions(state: pickerTypeState, channelConfig: nil))
            .environmentObject(viewModel)
            .frame(width: 36, height: 36)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_messageComposerView_commandActive() {
        // Given
        let factory = DefaultViewFactory.shared
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let viewModel = MessageComposerViewModel(channelController: channelController, messageController: nil)
        viewModel.composerCommand = ComposerCommandFactory.shared.mute()

        // When
        let view = MessageComposerView(
            viewFactory: factory,
            viewModel: viewModel,
            channelController: channelController,
            messageController: nil,
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            willSendMessage: {}
        )
        .frame(width: composerWidth, height: 200)

        // Then
        AssertSnapshot(view, variants: [.defaultLight, .defaultDark])
    }

    // MARK: - Send Button Icon

    func test_messageComposerView_sendButton_noCommandSelected() {
        // Given — text entered, no command: send button shows the standard composerSend icon
        let factory = DefaultViewFactory.shared
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let viewModel = MessageComposerViewModel(channelController: channelController, messageController: nil)
        viewModel.text = "Hello"

        // When
        let view = MessageComposerView(
            viewFactory: factory,
            viewModel: viewModel,
            channelController: channelController,
            messageController: nil,
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            willSendMessage: {}
        )
        .frame(width: composerWidth, height: 56)

        // Then
        AssertSnapshot(view, variants: [.defaultLight, .defaultDark])
    }

    func test_messageComposerView_sendButton_commandSelected_noText() {
        // Given — instant command active, no text: send button shows selectionBadgeIcon (disabled)
        let factory = DefaultViewFactory.shared
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let viewModel = MessageComposerViewModel(channelController: channelController, messageController: nil)
        viewModel.composerCommand = ComposerCommandFactory.shared.giphy()

        // When
        let view = MessageComposerView(
            viewFactory: factory,
            viewModel: viewModel,
            channelController: channelController,
            messageController: nil,
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            willSendMessage: {}
        )
        .frame(width: composerWidth, height: 56)

        // Then
        AssertSnapshot(view, variants: [.defaultLight, .defaultDark])
    }

    func test_messageComposerView_sendButton_commandSelected_withText() {
        // Given — instant command active with text: send button shows selectionBadgeIcon (enabled)
        let factory = DefaultViewFactory.shared
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let viewModel = MessageComposerViewModel(channelController: channelController, messageController: nil)
        viewModel.composerCommand = ComposerCommandFactory.shared.giphy()
        viewModel.text = "funny cat"

        // When
        let view = MessageComposerView(
            viewFactory: factory,
            viewModel: viewModel,
            channelController: channelController,
            messageController: nil,
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            willSendMessage: {}
        )
        .frame(width: composerWidth, height: 56)

        // Then
        AssertSnapshot(view, variants: [.defaultLight, .defaultDark])
    }

    // MARK: - Send In Channel

    func test_messageComposerView_sendInChannel_selected() {
        // Given
        let size = CGSize(width: composerWidth, height: 200)
        let factory = DefaultViewFactory.shared
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let messageController = ChatMessageControllerSUI_Mock.mock(
            chatClient: chatClient,
            cid: .unique,
            messageId: .unique
        )
        let viewModel = MessageComposerViewModel(
            channelController: channelController,
            messageController: messageController
        )
        viewModel.showReplyInChannel = true

        // When
        let view = MessageComposerView(
            viewFactory: factory,
            viewModel: viewModel,
            channelController: channelController,
            messageController: messageController,
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            willSendMessage: {}
        )
        .frame(width: size.width, height: size.height)

        // Then
        AssertSnapshot(view, size: size)
    }

    func test_messageComposerView_sendInChannel_unselected() {
        // Given
        let size = CGSize(width: composerWidth, height: 200)
        let factory = DefaultViewFactory.shared
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let messageController = ChatMessageControllerSUI_Mock.mock(
            chatClient: chatClient,
            cid: .unique,
            messageId: .unique
        )
        let viewModel = MessageComposerViewModel(
            channelController: channelController,
            messageController: messageController
        )
        viewModel.showReplyInChannel = false

        // When
        let view = MessageComposerView(
            viewFactory: factory,
            viewModel: viewModel,
            channelController: channelController,
            messageController: messageController,
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            willSendMessage: {}
        )
        .frame(width: size.width, height: size.height)

        // Then
        AssertSnapshot(view, size: size)
    }

    // MARK: - Attachment Picker Prompt Views

    func test_photoLibraryAccessPromptView_snapshot() {
        let view = PhotoLibraryAccessPromptView()
            .frame(width: composerWidth, height: 300)

        AssertSnapshot(view)
    }

    func test_fileOpenPromptView_snapshot() {
        let view = FileOpenPromptView(onTap: {})
            .frame(width: composerWidth, height: 300)

        AssertSnapshot(view)
    }

    func test_cameraOpenPromptView_snapshot() {
        let view = CameraOpenPromptView(onTap: {})
            .frame(width: composerWidth, height: 300)

        AssertSnapshot(view)
    }

    func test_cameraAccessDeniedPromptView_snapshot() {
        let view = CameraAccessDeniedPromptView()
            .frame(width: composerWidth, height: 300)

        AssertSnapshot(view)
    }

    func test_pollCreatePromptView_snapshot() {
        let view = PollCreatePromptView(onTap: {})
            .frame(width: composerWidth, height: 300)

        AssertSnapshot(view)
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
            willSendMessage: {}
        )
        .frame(width: composerWidth, height: 200)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_composerInputView_frozenChannel() {
        // Given
        let factory = DefaultViewFactory.shared
        let mockChannelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        mockChannelController.channel_mock = .mockDMChannel(ownCapabilities: [.uploadFile, .readEvents])

        // When
        let view = ComposerInputView(
            factory: factory,
            channelController: mockChannelController,
            text: .constant(""),
            selectedRangeLocation: .constant(0),
            command: .constant(nil),
            recordingState: .constant(.initial),
            recordingGestureLocation: .constant(.zero),
            composerAssets: [],
            addedCustomAttachments: [],
            addedVoiceRecordings: [],
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            cooldownDuration: 0,
            hasContent: true,
            canSendMessage: true,
            audioRecordingInfo: .initial,
            pendingAudioRecordingURL: nil,
            onCustomAttachmentTap: { _ in },
            removeAttachmentWithId: { _ in },
            sendMessage: {},
            onImagePasted: { _ in },
            startRecording: {},
            stopRecording: {},
            confirmRecording: {},
            discardRecording: {},
            previewRecording: {},
            showRecordingTip: {},
            sendInChannelShown: false,
            showReplyInChannel: .constant(false)
        )
        .frame(width: composerWidth, height: 200)

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
        let view = factory.makeLeadingComposerView(options: LeadingComposerViewOptions(state: pickerTypeState, channelConfig: nil))
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
        let view = factory.makeTrailingComposerView(options: TrailingComposerViewOptions(
            enabled: true,
            cooldownDuration: 0,
            onTap: {}
        ))
        .environmentObject(viewModel)
        .frame(width: 100, height: 40)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_composerInputView_inputTextView() {
        // Given
        let view = InputTextView(
            frame: .init(x: 16, y: 16, width: composerWidth - 32, height: 50)
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
            placeholder: "Message",
            editable: true,
            maxMessageLength: nil,
            currentHeight: 38,
            onImagePasted: { _ in }
        )
        .frame(width: composerWidth, height: 50)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_composerInputView_rangeSelection() {
        // Given
        let view = ComposerTextInputView(
            text: .constant("This is a sample text"),
            height: .constant(38),
            selectedRangeLocation: .constant(3),
            placeholder: "Message",
            editable: true,
            maxMessageLength: nil,
            currentHeight: 38,
            onImagePasted: { _ in }
        )
        let inputView = InputTextView(
            frame: .init(x: 16, y: 16, width: composerWidth - 32, height: 50)
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
            placeholder: "Message",
            editable: true,
            maxMessageLength: nil,
            currentHeight: 38,
            onImagePasted: { _ in }
        )
        let inputView = InputTextView(
            frame: .init(x: 16, y: 16, width: composerWidth - 32, height: 50)
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
    
    func test_composerInputView_snapshot() {
        // Given
        let inputView = InputTextView()
        let view = ComposerTextInputView(
            text: .constant("test test"),
            height: .constant(100),
            selectedRangeLocation: .constant(0),
            placeholder: "Message",
            editable: true,
            maxMessageLength: nil,
            currentHeight: 36,
            onImagePasted: { _ in }
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

    func test_messageComposerView_withAttachmentPicker() {
        // Given
        let (fetchResult, loader) = makeMockPhotoAssets()
        let factory = MockMediaPickerViewFactory(assetLoader: loader)
        factory.mockPhotoAssets = fetchResult
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let viewModel = MessageComposerViewModel(channelController: channelController, messageController: nil)
        viewModel.pickerTypeState = .expanded(.media)

        // When
        let view = MessageComposerView(
            viewFactory: factory,
            viewModel: viewModel,
            channelController: channelController,
            messageController: nil,
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            willSendMessage: {}
        )
        .frame(width: composerWidth)

        // Then
        AssertSnapshot(view, variants: [.defaultLight, .defaultDark])
    }

    func test_composerInputView_command() {
        let factory = DefaultViewFactory.shared
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let size = CGSize(width: composerWidth, height: 200)

        let view = ComposerInputView(
            factory: factory,
            channelController: channelController,
            text: .constant(""),
            selectedRangeLocation: .constant(0),
            command: .constant(ComposerCommandFactory.shared.giphy()),
            recordingState: .constant(.initial),
            recordingGestureLocation: .constant(.zero),
            composerAssets: [],
            addedCustomAttachments: [],
            addedVoiceRecordings: [],
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            cooldownDuration: 0,
            hasContent: true,
            canSendMessage: true,
            audioRecordingInfo: .initial,
            pendingAudioRecordingURL: nil,
            onCustomAttachmentTap: { _ in },
            removeAttachmentWithId: { _ in },
            sendMessage: {},
            onImagePasted: { _ in },
            startRecording: {},
            stopRecording: {},
            confirmRecording: {},
            discardRecording: {},
            previewRecording: {},
            showRecordingTip: {},
            sendInChannelShown: false,
            showReplyInChannel: .constant(false)
        )
        .frame(width: size.width, height: size.height)

        AssertSnapshot(view, size: size)

        // Themed
        streamChat?.appearance.colorPalette.backgroundCoreInverse = UIColor(Color.indigo)
        streamChat?.appearance.colorPalette.textOnInverse = .yellow

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles, size: size, suffix: "themed")
    }

    func test_composerInputView_command_empty() {
        let factory = DefaultViewFactory.shared
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let size = CGSize(width: composerWidth, height: 200)

        let view = ComposerInputView(
            factory: factory,
            channelController: channelController,
            text: .constant(""),
            selectedRangeLocation: .constant(0),
            command: .constant(ComposerCommandFactory.shared.giphy()),
            recordingState: .constant(.initial),
            recordingGestureLocation: .constant(.zero),
            composerAssets: [],
            addedCustomAttachments: [],
            addedVoiceRecordings: [],
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            cooldownDuration: 0,
            hasContent: false,
            canSendMessage: true,
            audioRecordingInfo: .initial,
            pendingAudioRecordingURL: nil,
            onCustomAttachmentTap: { _ in },
            removeAttachmentWithId: { _ in },
            sendMessage: {},
            onImagePasted: { _ in },
            startRecording: {},
            stopRecording: {},
            confirmRecording: {},
            discardRecording: {},
            previewRecording: {},
            showRecordingTip: {},
            sendInChannelShown: false,
            showReplyInChannel: .constant(false)
        )
        .frame(width: size.width, height: size.height)

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles, size: size)
    }

    func test_composerInputView_command_mute() {
        let factory = DefaultViewFactory.shared
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let size = CGSize(width: composerWidth, height: 200)

        let view = ComposerInputView(
            factory: factory,
            channelController: channelController,
            text: .constant(""),
            selectedRangeLocation: .constant(0),
            command: .constant(ComposerCommandFactory.shared.mute()),
            recordingState: .constant(.initial),
            recordingGestureLocation: .constant(.zero),
            composerAssets: [],
            addedCustomAttachments: [],
            addedVoiceRecordings: [],
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            cooldownDuration: 0,
            hasContent: false,
            canSendMessage: true,
            audioRecordingInfo: .initial,
            pendingAudioRecordingURL: nil,
            onCustomAttachmentTap: { _ in },
            removeAttachmentWithId: { _ in },
            sendMessage: {},
            onImagePasted: { _ in },
            startRecording: {},
            stopRecording: {},
            confirmRecording: {},
            discardRecording: {},
            previewRecording: {},
            showRecordingTip: {},
            sendInChannelShown: false,
            showReplyInChannel: .constant(false)
        )
        .frame(width: size.width, height: size.height)

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles, size: size)
    }
  
    // MARK: - Drafts

    // Note: For some reason the text is not rendered in the composer,
    // Maybe it's because of the `UITextView` that is used in the `InputTextView`.
    // Either way, the test of the content is covered.

    func test_composerView_draftWithImageAttachment() throws {
        let size = CGSize(width: composerWidth, height: 200)
        let mockDraftMessage = try DraftMessage.mock(
            attachments: [
                .dummy(
                    type: .image,
                    payload: JSONEncoder().encode(
                        ImageAttachmentPayload(
                            title: nil,
                            imageRemoteURL: TestImages.yoda.url,
                            file: .init(type: .jpeg, size: 10, mimeType: nil)
                        )
                    )
                ),
                .dummy(
                    type: .image,
                    payload: JSONEncoder().encode(
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
        let size = CGSize(width: composerWidth, height: 200)
        let mockDraftMessage = try DraftMessage.mock(
            attachments: [
                .dummy(
                    type: .video,
                    payload: JSONEncoder().encode(
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
        let size = CGSize(width: composerWidth, height: 200)
        let mockDraftMessage = try DraftMessage.mock(
            attachments: [
                .dummy(
                    type: .file,
                    payload: JSONEncoder().encode(
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

        let size = CGSize(width: composerWidth, height: 200)
        let mockDraftMessage = try DraftMessage.mock(
            attachments: [
                .dummy(
                    type: .voiceRecording,
                    payload: JSONEncoder().encode(
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
        let size = CGSize(width: composerWidth, height: 200)
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
            willSendMessage: {}
        )
    }
    
    // MARK: - Editing

    func test_composerView_editingMessageWithText() {
        let size = CGSize(width: composerWidth, height: 300)
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
        let size = CGSize(width: composerWidth, height: 300)
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
        let size = CGSize(width: composerWidth, height: 300)
        let mockEditedMessage = try ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Message with image",
            author: .mock(id: .unique),
            attachments: [
                .dummy(
                    type: .image,
                    payload: JSONEncoder().encode(
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
        let size = CGSize(width: composerWidth, height: 300)
        let mockEditedMessage = try ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Message with video",
            author: .mock(id: .unique),
            attachments: [
                .dummy(
                    type: .video,
                    payload: JSONEncoder().encode(
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
        let size = CGSize(width: composerWidth, height: 300)
        let mockEditedMessage = try ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Message with file",
            author: .mock(id: .unique),
            attachments: [
                .dummy(
                    type: .file,
                    payload: JSONEncoder().encode(
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

        let size = CGSize(width: composerWidth, height: 200)
        let mockEditedMessage = try ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Message with voice recording",
            author: .mock(id: .unique),
            attachments: [
                .dummy(
                    type: .voiceRecording,
                    payload: JSONEncoder().encode(
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
        let viewModel = MessageComposerViewModel(
            channelController: channelController,
            messageController: nil,
            editedMessage: .constant(editedMessage)
        )
        viewModel.attachmentsConverter = SynchronousAttachmentsConverter()
        viewModel.fillEditedMessage(editedMessage)

        return MessageComposerView(
            viewFactory: factory,
            viewModel: viewModel,
            channelController: channelController,
            quotedMessage: .constant(nil),
            editedMessage: .constant(editedMessage),
            willSendMessage: {}
        )
    }

    // MARK: - Quoting

    func test_composerView_quotingMessageWithImageAttachment() throws {
        let size = CGSize(width: composerWidth, height: 300)
        let mockQuotedMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Original message being replied to",
            author: .mock(id: .unique, name: "John Smart")
        )

        let addedAsset = AddedAsset(
            image: TestImages.yoda.image,
            id: .unique,
            url: TestImages.yoda.url,
            type: .image
        )

        let factory = DefaultViewFactory.shared
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let viewModel = MessageComposerViewModel(channelController: channelController, messageController: nil)
        viewModel.updateAddedAssets([addedAsset])

        let view = MessageComposerView(
            viewFactory: factory,
            viewModel: viewModel,
            channelController: channelController,
            quotedMessage: .constant(mockQuotedMessage),
            editedMessage: .constant(nil),
            willSendMessage: {}
        )
        .frame(width: size.width, height: size.height)

        AssertSnapshot(view, variants: [.defaultLight], size: size)
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
            willSendMessage: {}
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
            willSendMessage: {}
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
            willSendMessage: {}
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
            willSendMessage: {}
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

    // MARK: - Liquid Glass Style

    func test_messageComposerView_liquidGlass_snapshot() {
        // Given
        let size = CGSize(width: composerWidth, height: 200)
        let factory = LiquidGlassViewFactory()
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)

        // When
        let view = MessageComposerView(
            viewFactory: factory,
            channelController: channelController,
            messageController: nil,
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            willSendMessage: {}
        )
        .frame(width: size.width, height: size.height)

        // Then
        AssertSnapshot(view, variants: [.defaultLight, .defaultDark], size: size)
    }

    func test_messageComposerView_liquidGlass_withImageAttachment() {
        // Given
        let size = CGSize(width: composerWidth, height: 200)
        let factory = LiquidGlassViewFactory()
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let viewModel = MessageComposerViewModel(channelController: channelController, messageController: nil)
        let addedAsset = AddedAsset(
            image: TestImages.yoda.image,
            id: .unique,
            url: TestImages.yoda.url,
            type: .image
        )
        viewModel.updateAddedAssets([addedAsset])

        // When
        let view = MessageComposerView(
            viewFactory: factory,
            viewModel: viewModel,
            channelController: channelController,
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            willSendMessage: {}
        )
        .frame(width: size.width, height: size.height)

        // Then
        AssertSnapshot(view, variants: [.defaultLight, .defaultDark], size: size)
    }

    func test_messageComposerView_liquidGlass_withAttachmentPicker() {
        // Given
        let (fetchResult, loader) = makeMockPhotoAssets()
        let factory = MockLiquidGlassMediaPickerViewFactory(assetLoader: loader)
        factory.mockPhotoAssets = fetchResult
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let viewModel = MessageComposerViewModel(channelController: channelController, messageController: nil)
        viewModel.pickerTypeState = .expanded(.media)

        // When
        let view = MessageComposerView(
            viewFactory: factory,
            viewModel: viewModel,
            channelController: channelController,
            messageController: nil,
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            willSendMessage: {}
        )
        .frame(width: composerWidth)

        // Then
        AssertSnapshot(view, variants: [.defaultLight, .defaultDark])
    }
}

// MARK: - Helpers

private extension MessageComposerView_Tests {
    func makeMockPhotoAssets() -> (fetchResult: MockPHFetchResult, loader: PhotoAssetLoader) {
        let itemColors: [UIColor] = [
            .systemBlue, .systemGreen, .systemOrange,
            .systemPurple, .systemRed, .systemTeal,
            .systemPink, .systemYellow, .systemIndigo
        ]
        let mockAssets: [PHAsset] = (0..<9).map { index in
            if index == 3 || index == 7 {
                return MockPHAsset(
                    mockId: "asset-\(index)",
                    mockMediaType: .video,
                    mockDuration: index == 3 ? 15.5 : 125
                )
            }
            return MockPHAsset(mockId: "asset-\(index)")
        }

        let fetchResult = MockPHFetchResult(mockAssets: mockAssets)
        let loader = PhotoAssetLoader()
        let imageSize = CGSize(width: 200, height: 200)
        for (index, asset) in mockAssets.enumerated() {
            loader.loadedImages[asset.localIdentifier] = UIImage.make(
                color: itemColors[index],
                size: imageSize
            )
        }
        return (fetchResult, loader)
    }
}

class SynchronousAttachmentsConverter: MessageAttachmentsConverter {
    override func attachmentsToAssets(
        _ attachments: [AnyChatMessageAttachment],
        completion: @escaping @Sendable @MainActor (TotalAddedAssets) -> Void
    ) {
        super.attachmentsToAssets(attachments, with: nil, completion: completion)
    }
}

// MARK: - Mock View Factory

private class MockMediaPickerViewFactory: ViewFactory {
    @Injected(\.chatClient) var chatClient: ChatClient

    var styles = RegularStyles()
    var mockPhotoAssets: PHFetchResult<PHAsset>?

    private let assetLoader: PhotoAssetLoader

    init(assetLoader: PhotoAssetLoader) {
        self.assetLoader = assetLoader
    }

    func makeAttachmentMediaPickerView(
        options: AttachmentMediaPickerViewOptions
    ) -> some View {
        AttachmentMediaPickerView(
            assetLoader: assetLoader,
            photoLibraryAssets: options.photoLibraryAssets,
            onImageTap: options.onAssetTap,
            imageSelected: options.isAssetSelected,
            selectedAssetIds: options.selectedAssetIds
        )
    }

    func makeAttachmentPickerView(
        options: AttachmentPickerViewOptions
    ) -> some View {
        AttachmentPickerView(
            viewFactory: self,
            selectedPickerState: options.attachmentPickerState,
            filePickerShown: options.filePickerShown,
            cameraPickerShown: options.cameraPickerShown,
            onFilesPicked: options.onFilesPicked,
            onPickerStateChange: options.onPickerStateChange,
            photoLibraryAssets: mockPhotoAssets ?? options.photoLibraryAssets,
            onAssetTap: options.onAssetTap,
            onCustomAttachmentTap: options.onCustomAttachmentTap,
            isAssetSelected: options.isAssetSelected,
            addedCustomAttachments: options.addedCustomAttachments,
            cameraImageAdded: options.cameraImageAdded,
            askForAssetsAccessPermissions: options.askForAssetsAccessPermissions,
            isDisplayed: options.isDisplayed,
            height: 500,
            selectedAssetIds: options.selectedAssetIds,
            channelController: options.channelController,
            messageController: options.messageController,
            canSendPoll: options.canSendPoll,
            instantCommands: options.instantCommands,
            onCommandSelected: options.onCommandSelected
        )
    }
}

private class MockLiquidGlassMediaPickerViewFactory: ViewFactory {
    @Injected(\.chatClient) var chatClient: ChatClient

    var styles = LiquidGlassStyles()
    var mockPhotoAssets: PHFetchResult<PHAsset>?

    private let assetLoader: PhotoAssetLoader

    init(assetLoader: PhotoAssetLoader) {
        self.assetLoader = assetLoader
    }

    func makeAttachmentMediaPickerView(
        options: AttachmentMediaPickerViewOptions
    ) -> some View {
        AttachmentMediaPickerView(
            assetLoader: assetLoader,
            photoLibraryAssets: options.photoLibraryAssets,
            onImageTap: options.onAssetTap,
            imageSelected: options.isAssetSelected,
            selectedAssetIds: options.selectedAssetIds
        )
    }

    func makeAttachmentPickerView(
        options: AttachmentPickerViewOptions
    ) -> some View {
        AttachmentPickerView(
            viewFactory: self,
            selectedPickerState: options.attachmentPickerState,
            filePickerShown: options.filePickerShown,
            cameraPickerShown: options.cameraPickerShown,
            onFilesPicked: options.onFilesPicked,
            onPickerStateChange: options.onPickerStateChange,
            photoLibraryAssets: mockPhotoAssets ?? options.photoLibraryAssets,
            onAssetTap: options.onAssetTap,
            onCustomAttachmentTap: options.onCustomAttachmentTap,
            isAssetSelected: options.isAssetSelected,
            addedCustomAttachments: options.addedCustomAttachments,
            cameraImageAdded: options.cameraImageAdded,
            askForAssetsAccessPermissions: options.askForAssetsAccessPermissions,
            isDisplayed: options.isDisplayed,
            height: 500,
            selectedAssetIds: options.selectedAssetIds,
            channelController: options.channelController,
            messageController: options.messageController,
            canSendPoll: options.canSendPoll,
            instantCommands: options.instantCommands,
            onCommandSelected: options.onCommandSelected
        )
    }
}

// MARK: - Photos Framework Mocks

private class MockPHAsset: PHAsset, @unchecked Sendable {
    private let _mockId: String
    private let _mockMediaType: PHAssetMediaType
    private let _mockDuration: TimeInterval

    init(
        mockId: String,
        mockMediaType: PHAssetMediaType = .image,
        mockDuration: TimeInterval = 0
    ) {
        self._mockId = mockId
        self._mockMediaType = mockMediaType
        self._mockDuration = mockDuration
        super.init()
    }

    override var localIdentifier: String { _mockId }
    override var mediaType: PHAssetMediaType { _mockMediaType }
    override var duration: TimeInterval { _mockDuration }

    override func requestContentEditingInput(
        with options: PHContentEditingInputRequestOptions?,
        completionHandler: @escaping (PHContentEditingInput?, [AnyHashable: Any]) -> Void
    ) -> PHContentEditingInputRequestID {
        completionHandler(nil, [:])
        return 0
    }

    override func cancelContentEditingInputRequest(_ requestID: PHContentEditingInputRequestID) {}
}

private class MockPHFetchResult: PHFetchResult<PHAsset>, @unchecked Sendable {
    private let _mockAssets: [PHAsset]

    init(mockAssets: [PHAsset]) {
        self._mockAssets = mockAssets
        super.init()
    }

    override var count: Int { _mockAssets.count }

    override func object(at index: Int) -> PHAsset {
        _mockAssets[index]
    }
}

private extension UIImage {
    static func make(color: UIColor, size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
