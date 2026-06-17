//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import SwiftUI
import XCTest

@MainActor class MessageComposerViewModel_Tests: StreamChatTestCase {
    private let testImage = UIImage(systemName: "checkmark")!
    private var mockURL: URL!
    
    private var defaultAsset: AddedAsset {
        AddedAsset(
            image: testImage,
            id: .unique,
            url: mockURL,
            type: .image
        )
    }
    
    override func setUp() {
        super.setUp()
        mockURL = generateURL()
        writeMockData(for: mockURL)
    }
    
    override func tearDown() {
        super.tearDown()
        if let mockURL {
            try? FileManager.default.removeItem(at: mockURL)
        }
    }
    
    func test_messageComposerVM_recordingGestureOverlay_shownWhenQuotedOnlyAndEmpty() {
        let quoted = ChatMessage.mock(id: .unique, cid: .unique, text: "Quoted", author: .mock(id: .unique))
        var quotedRef: ChatMessage? = quoted
        let binding = Binding<ChatMessage?>(
            get: { quotedRef },
            set: { quotedRef = $0 }
        )
        let viewModel = MessageComposerViewModel(
            channelController: makeChannelController(),
            messageController: nil,
            quotedMessage: binding
        )

        XCTAssertFalse(viewModel.hasContent)
        XCTAssertTrue(viewModel.shouldShowRecordingGestureOverlay)
    }

    func test_messageComposerVM_sendButtonDisabled() {
        // Given
        let viewModel = makeComposerViewModel()
        
        // When
        let buttonEnabled = viewModel.hasContent
        
        // Then
        XCTAssert(buttonEnabled == false)
    }
    
    func test_messageComposerVM_emptySpaceButtonDisabled() {
        // Given
        let viewModel = makeComposerViewModel()
        
        // When
        viewModel.text = "      "
        
        // Then
        XCTAssert(viewModel.hasContent == false)
    }

    func test_messageComposerVM_sendButtonEnabled_addedAsset() {
        // Given
        let viewModel = makeComposerViewModel()
        
        // When
        viewModel.imageTapped(defaultAsset)
        let buttonEnabled = viewModel.hasContent
        
        // Then
        XCTAssert(buttonEnabled == true)
        XCTAssertEqual(viewModel.composerAssets.count, 1)
    }
    
    func test_messageComposerVM_sendButtonEnabled_addedFile() {
        // Given
        let viewModel = makeComposerViewModel()
        
        // When
        viewModel.addFileURLs([mockURL])
        let buttonEnabled = viewModel.hasContent
        
        // Then
        XCTAssert(buttonEnabled == true)
        XCTAssertEqual(viewModel.composerAssets.count, 1)
    }

    func test_messageComposerVM_onCommandSelected_setsInstantCommand() {
        // Given
        let viewModel = makeComposerViewModel()
        let textBinding = Binding(
            get: { viewModel.text },
            set: { viewModel.text = $0 }
        )
        let rangeBinding = Binding(
            get: { viewModel.selectedRangeLocation },
            set: { viewModel.selectedRangeLocation = $0 }
        )
        let commandBinding = Binding(
            get: { viewModel.composerCommand },
            set: { viewModel.composerCommand = $0 }
        )
        let displayInfo = CommandDisplayInfo(
            displayName: "Giphy",
            icon: UIImage(systemName: "photo") ?? UIImage(),
            format: "/giphy [text]",
            isInstant: true
        )
        let command = ComposerCommand(
            id: "/giphy",
            typingSuggestion: TypingSuggestion.empty,
            displayInfo: displayInfo
        )

        // When
        viewModel.pickerTypeState = .expanded(.none)
        viewModel.composerCommand = ComposerCommand(
            id: "instantCommands",
            typingSuggestion: TypingSuggestion.empty,
            displayInfo: nil
        )
        viewModel.handleCommand(
            for: textBinding,
            selectedRangeLocation: rangeBinding,
            command: commandBinding,
            extraData: ["instantCommand": command]
        )

        // Then
        XCTAssertEqual(viewModel.composerCommand?.id, "/giphy")
    }

    func test_messageComposerVM_instantCommand_clearsMediaAttachments() {
        // Given
        let viewModel = makeComposerViewModel()
        viewModel.imageTapped(defaultAsset)
        XCTAssertEqual(viewModel.composerAssets.count, 1)

        // When
        viewModel.composerCommand = makeGiphyCommand()

        // Then
        XCTAssertTrue(viewModel.composerAssets.isEmpty)
    }

    func test_messageComposerVM_instantCommand_clearsFileAttachments() {
        // Given
        let viewModel = makeComposerViewModel()
        viewModel.addFileURLs([mockURL])
        XCTAssertEqual(viewModel.composerAssets.count, 1)

        // When
        viewModel.composerCommand = makeGiphyCommand()

        // Then
        XCTAssertTrue(viewModel.composerAssets.isEmpty)
    }

    func test_messageComposerVM_instantCommand_clearsCustomAttachments() {
        // Given
        let viewModel = makeComposerViewModel()
        let attachment = CustomAttachment(id: .unique, content: .mockFile)
        viewModel.customAttachmentTapped(attachment)
        XCTAssertEqual(viewModel.addedCustomAttachments.count, 1)

        // When
        viewModel.composerCommand = makeGiphyCommand()

        // Then
        XCTAssertTrue(viewModel.addedCustomAttachments.isEmpty)
    }

    func test_messageComposerVM_instantCommand_clearsVoiceRecordings() {
        // Given
        let viewModel = makeComposerViewModel()
        let recording = AddedVoiceRecording(url: mockURL, duration: 1.0, waveform: [])
        viewModel.addedVoiceRecordings = [recording]

        // When
        viewModel.composerCommand = makeGiphyCommand()

        // Then
        XCTAssertTrue(viewModel.addedVoiceRecordings.isEmpty)
    }

    func test_messageComposerVM_sendButtonEnabled_addedCustomAttachment() {
        // Given
        let viewModel = makeComposerViewModel()
        let attachment = CustomAttachment(id: .unique, content: .mockFile)
        
        // When
        viewModel.customAttachmentTapped(attachment)
        let buttonEnabled = viewModel.hasContent
        
        // Then
        XCTAssert(buttonEnabled == true)
        XCTAssertEqual(viewModel.addedCustomAttachments.count, 1)
    }
    
    func test_messageComposerVM_changePickerState() {
        // Given
        let viewModel = makeComposerViewModel()
        
        // When
        viewModel.change(pickerState: .custom)
        
        // Then
        XCTAssert(viewModel.pickerState == .custom)
    }
    
    func test_messageComposerVM_imageRemovalByTappingTwice() {
        // Given
        let viewModel = makeComposerViewModel()
        let asset = defaultAsset
        
        // When
        viewModel.imageTapped(asset) // added to the attachments list
        viewModel.imageTapped(asset) // removed from the attachments list
        
        // Then
        XCTAssert(viewModel.composerAssets.isEmpty)
    }
    
    func test_messageComposerVM_removeFileAttachment() {
        // Given
        let viewModel = makeComposerViewModel()
        
        // When
        viewModel.composerAssets = [.addedFile(mockURL)]
        viewModel.removeAttachment(with: mockURL.absoluteString)
        
        // Then
        XCTAssert(viewModel.composerAssets.isEmpty)
    }
    
    func test_messageComposerVM_removeImageAttachment() {
        // Given
        let viewModel = makeComposerViewModel()
        let asset = defaultAsset
        
        // When
        viewModel.imageTapped(asset)
        viewModel.removeAttachment(with: asset.id)
        
        // Then
        XCTAssert(viewModel.composerAssets.isEmpty)
    }
    
    func test_messageComposerVM_cameraImageAdded() {
        // Given
        let viewModel = makeComposerViewModel()
        
        // When
        viewModel.cameraImageAdded(defaultAsset)
        
        // Then
        XCTAssertEqual(viewModel.composerAssets.count, 1)
        XCTAssert(viewModel.pickerState == .photos)
    }
    
    func test_messageComposerVM_imageIsSelected() {
        // Given
        let viewModel = makeComposerViewModel()
        let asset = defaultAsset
        
        // When
        viewModel.imageTapped(asset)
        let imageIsSelected = viewModel.isImageSelected(with: asset.id)
        
        // Then
        XCTAssert(imageIsSelected == true)
    }
    
    func test_messageComposerVM_imageIsNotSelected() {
        // Given
        let viewModel = makeComposerViewModel()
        
        // When
        viewModel.imageTapped(defaultAsset)
        let imageSelected = viewModel.isImageSelected(with: .unique)
        
        // Then
        XCTAssert(imageSelected == false)
    }
    
    func test_messageComposerVM_customAttachmentSelected() {
        // Given
        let viewModel = makeComposerViewModel()
        let attachment = CustomAttachment(id: .unique, content: .mockFile)
        
        // When
        viewModel.customAttachmentTapped(attachment)
        let isSelected = viewModel.isCustomAttachmentSelected(attachment)
        
        // Then
        XCTAssert(isSelected == true)
    }
    
    func test_messageComposerVM_customAttachmentRemovalByTappingTwice() {
        // Given
        let viewModel = makeComposerViewModel()
        let attachment = CustomAttachment(id: .unique, content: .mockFile)
        
        // When
        viewModel.customAttachmentTapped(attachment)
        viewModel.customAttachmentTapped(attachment)
        let isSelected = viewModel.isCustomAttachmentSelected(attachment)
        
        // Then
        XCTAssert(isSelected == false)
        XCTAssert(viewModel.addedCustomAttachments.isEmpty)
    }
    
    func test_messageComposerVM_overlayNotShown() {
        // Given
        let viewModel = makeComposerViewModel()
        
        // When
        viewModel.pickerTypeState = .expanded(.none)
        let overlayShown = viewModel.overlayShown
        
        // Then
        XCTAssert(overlayShown == false)
    }
    
    func test_messageComposerVM_overlayShown() {
        // Given
        let viewModel = makeComposerViewModel()
        
        // When
        viewModel.pickerTypeState = .expanded(.media)
        let overlayShown = viewModel.overlayShown
        
        // Then
        XCTAssert(overlayShown == true)
    }
    
    func test_messageComposerVM_sendNewMessage() {
        // Given
        let viewModel = makeComposerViewModel()
        
        // When
        viewModel.text = "test"
        viewModel.imageTapped(defaultAsset)
        viewModel.composerAssets.append(.addedFile(mockURL))
        viewModel.sendMessage {
            // Then
            XCTAssert(viewModel.errorShown == false)
            XCTAssert(viewModel.text == "")
            XCTAssert(viewModel.composerAssets.isEmpty)
        }
    }
    
    // MARK: - isSendingMessage guard (PR #1373)

    func test_messageComposerVM_isSendingMessage_initiallyFalse() {
        // Given / When
        let viewModel = makeComposerViewModel()

        // Then
        XCTAssertFalse(viewModel.isSendingMessage)
    }

    func test_messageComposerVM_isSendingMessage_trueWhileSending() {
        // Given
        let viewModel = makeComposerViewModel()
        viewModel.text = "test"

        // When
        viewModel.sendMessage()

        // Then – flag is set synchronously before clearInputData()'s delayed reset fires
        XCTAssertTrue(viewModel.isSendingMessage)
    }

    func test_messageComposerVM_isSendingMessage_preventsDoubleSend() {
        // Given
        let channelController = makeChannelController()
        let viewModel = MessageComposerViewModel(
            channelController: channelController,
            messageController: nil
        )
        viewModel.text = "test"

        // When – call sendMessage twice in rapid succession
        viewModel.sendMessage()
        viewModel.sendMessage()

        // Then – createNewMessage must only have been called once
        XCTAssertEqual(channelController.createNewMessageCallCount, 1)
    }

    func test_messageComposerVM_isSendingMessage_resetAfterClearInputDataDelay() {
        // Given
        let viewModel = makeComposerViewModel()
        viewModel.text = "test"
        let expectation = expectation(description: "isSendingMessage reset after 0.1 s delay")

        // When
        viewModel.sendMessage()
        XCTAssertTrue(viewModel.isSendingMessage)

        // Then – clearInputData() schedules the reset 0.1 s later; wait for it
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertFalse(viewModel.isSendingMessage)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func test_messageComposerVM_isSendingMessage_secondCallIgnoredWhenAlreadySending() {
        // Given
        let channelController = makeChannelController()
        let viewModel = MessageComposerViewModel(
            channelController: channelController,
            messageController: nil
        )
        viewModel.text = "first message"

        // When – first send sets the guard; immediate second send must be a no-op
        viewModel.sendMessage()
        viewModel.text = "second message"
        viewModel.sendMessage()

        // Then – still only one network call
        XCTAssertEqual(channelController.createNewMessageCallCount, 1)
        // Flag still true (clearInputData delay hasn't fired)
        XCTAssertTrue(viewModel.isSendingMessage)
    }

    func test_messageComposerVM_notInThread() {
        // Given
        let viewModel = makeComposerViewModel()
        
        // When
        let sendInChannel = viewModel.sendInChannelShown
        let isDMChannel = viewModel.isDirectChannel
        
        // Then
        XCTAssert(sendInChannel == false)
        XCTAssert(isDMChannel == true)
    }
    
    func test_messageComposerVM_inThread() {
        // Given
        let channelController = makeChannelController()
        let messageController = ChatMessageControllerSUI_Mock.mock(
            chatClient: chatClient,
            cid: .unique,
            messageId: .unique
        )
        let viewModel = MessageComposerViewModel(
            channelController: channelController,
            messageController: messageController
        )
        
        // When
        let sendInChannel = viewModel.sendInChannelShown
        let isDMChannel = viewModel.isDirectChannel
        
        // Then
        XCTAssert(sendInChannel == true)
        XCTAssert(isDMChannel == true)
    }
    
    func test_messageComposerVM_settingComposerCommand() {
        // Given
        let viewModel = makeComposerViewModel()
        
        // When
        viewModel.text = "/giphy"
        
        // Then
        XCTAssert(viewModel.composerCommand != nil)
        XCTAssert(viewModel.composerCommand?.id == "/giphy")
    }
    
    func test_messageComposerVM_instantCommandsShown() {
        // Given
        let viewModel = makeComposerViewModel()
        
        // When
        viewModel.pickerTypeState = .expanded(.instantCommands)
        
        // Then
        XCTAssert(viewModel.composerCommand != nil)
        XCTAssert(viewModel.composerCommand?.id == "instantCommands")
    }
    
    func test_messageComposerVM_giphySendButtonEnabled() {
        // Given
        let viewModel = makeComposerViewModel()
        let command = ComposerCommand(
            id: "/giphy",
            typingSuggestion: TypingSuggestion(
                text: "/giphy",
                locationRange: NSRange(location: 1, length: 5)
            ),
            displayInfo: CommandDisplayInfo(
                displayName: "Giphy",
                icon: UIImage(systemName: "xmark")!,
                format: "/giphy [text]",
                isInstant: true
            )
        )
        
        // When
        viewModel.composerCommand = command
        let initialSendButtonState = viewModel.hasContent
        viewModel.text = "hey"
        let finalSendButtonState = viewModel.hasContent
        
        // Then
        XCTAssert(initialSendButtonState == false)
        XCTAssert(finalSendButtonState == true)
    }
    
    func test_messageComposerVM_suggestionsShown() {
        // Given
        let viewModel = makeComposerViewModel()
        
        // When
        viewModel.pickerTypeState = .expanded(.instantCommands)
        
        // Then
        XCTAssert(!viewModel.suggestions.isEmpty)
    }
    
    func test_messageComposerVM_maxAttachmentsAssets() {
        // Given
        let viewModel = makeComposerViewModel()
        
        // When
        for _ in 0..<10 {
            let newAsset = defaultAsset
            viewModel.imageTapped(newAsset)
        }
        let newAsset = defaultAsset
        viewModel.imageTapped(newAsset) // This one will not be added, default limit is 10.

        // Then
        XCTAssertEqual(viewModel.composerAssets.count, 10)
    }
    
    func test_messageComposerVM_maxAttachmentsCombined() {
        // Given
        let viewModel = makeComposerViewModel()
        var urls = [URL]()
        
        // When
        for _ in 0..<5 {
            let newAsset = defaultAsset
            viewModel.imageTapped(newAsset)
        }
        for _ in 0..<5 {
            let newURL = generateURL()
            writeMockData(for: newURL)
            urls.append(newURL)
            viewModel.addFileURLs([newURL])
        }
        let newAsset = defaultAsset
        viewModel.imageTapped(newAsset) // This one will not be added, default limit is 10.
        let newURL = generateURL()
        viewModel.addFileURLs([newURL])
        
        // Then
        let total = viewModel.composerAssets.count
        XCTAssertEqual(total, 10)
        for url in urls {
            try? FileManager.default.removeItem(at: url)
        }
    }
    
    func test_messageComposerVM_maxSizeExceeded() {
        // Given
        let viewModel = makeComposerViewModel()
        let client = ChatClient.mock(isLocalStorageEnabled: false)
        streamChat = StreamChat(
            chatClient: client,
            utils: Utils(composerConfig: ComposerConfig(maxAttachmentSize: 5))
        )
        
        // When
        let newAsset = defaultAsset
        viewModel.imageTapped(newAsset) // will not be added because of small max attachment size.
        let alertShown = viewModel.attachmentSizeExceeded
        
        // Then
        XCTAssert(viewModel.composerAssets.isEmpty)
        XCTAssert(alertShown == true)
    }
    
    func test_messageComposerVM_maxSizeExceededWithAppSettingsConfiguration() {
        // Given
        let expectedValue: Int64 = 5
        chatClient.mockedAppSettings = .mock(imageUploadConfig: .mock(
            sizeLimitInBytes: expectedValue
        ))
        let viewModel = makeComposerViewModel()
        
        // When
        let newAsset = defaultAsset
        viewModel.imageTapped(newAsset) // will not be added because of small max attachment size.
        let alertShown = viewModel.attachmentSizeExceeded
        
        // Then
        XCTAssert(viewModel.composerAssets.isEmpty)
        XCTAssert(alertShown == true)
    }
    
    func test_messageComposerVM_mentionUsers() {
        // Given
        let viewModel = makeComposerViewModel()
        let command = ComposerCommand(
            id: "mentions",
            typingSuggestion: TypingSuggestion(text: "Hey @Martin", locationRange: NSRange(location: 0, length: 11)),
            displayInfo: nil
        )
        let user = ChatUser.mock(id: .unique, name: "Martin")
        
        // When
        viewModel.handleCommand(
            for: .constant("Hey @Martin"),
            selectedRangeLocation: .constant(11),
            command: .constant(command),
            extraData: ["chatUser": user]
        )
        
        // Then
        XCTAssertEqual(viewModel.mentionedUsers.count, 1)
        XCTAssert(viewModel.mentionedUsers.first?.name == "Martin")
    }
    
    func test_messageComposerVM_noMentionedUsers() {
        // Given
        let viewModel = makeComposerViewModel()
        
        // When
        viewModel.handleCommand(
            for: .constant("Hey Martin"),
            selectedRangeLocation: .constant(10),
            command: .constant(nil),
            extraData: [:]
        )
        
        // Then
        XCTAssert(viewModel.mentionedUsers.isEmpty)
    }
    
    func test_messageComposerVM_mentionedUsersClearText() {
        // Given
        let viewModel = makeComposerViewModel()
        let command = ComposerCommand(
            id: "mentions",
            typingSuggestion: TypingSuggestion(text: "Hey @Martin", locationRange: NSRange(location: 0, length: 11)),
            displayInfo: nil
        )
        let user = ChatUser.mock(id: .unique, name: "Martin")
        
        // When
        viewModel.handleCommand(
            for: .constant("Hey @Martin"),
            selectedRangeLocation: .constant(11),
            command: .constant(command),
            extraData: ["chatUser": user]
        )
        viewModel.text = ""
        
        // Then
        XCTAssert(viewModel.mentionedUsers.isEmpty)
    }

    func test_checkForMentionedUsers_withUserSuggestion() {
        // Given
        let viewModel = makeComposerViewModel()
        let user = ChatUser.mock(id: .unique, name: "Martin")

        // When
        viewModel.checkForMentionedUsers(
            commandId: "mentions",
            extraData: ["mentionSuggestion": MentionSuggestion.user(user)]
        )

        // Then
        XCTAssertEqual(viewModel.mentionedUsers, [user])
    }

    func test_checkForMentionedUsers_withHereSuggestion() {
        // Given
        let viewModel = makeComposerViewModel()

        // When
        viewModel.checkForMentionedUsers(
            commandId: "mentions",
            extraData: ["mentionSuggestion": MentionSuggestion.here]
        )

        // Then
        XCTAssertTrue(viewModel.mentionsHere)
        XCTAssertFalse(viewModel.mentionsChannel)
    }

    func test_checkForMentionedUsers_withChannelSuggestion() {
        // Given
        let viewModel = makeComposerViewModel()

        // When
        viewModel.checkForMentionedUsers(
            commandId: "mentions",
            extraData: ["mentionSuggestion": MentionSuggestion.channel]
        )

        // Then
        XCTAssertTrue(viewModel.mentionsChannel)
        XCTAssertFalse(viewModel.mentionsHere)
    }

    func test_checkForMentionedUsers_withRoleSuggestion() {
        // Given
        let viewModel = makeComposerViewModel()

        // When
        viewModel.checkForMentionedUsers(
            commandId: "mentions",
            extraData: ["mentionSuggestion": MentionSuggestion.role(Role(name: "admin"))]
        )

        // Then
        XCTAssertEqual(viewModel.mentionedRoles, ["admin"])
    }

    func test_checkForMentionedUsers_withGroupSuggestion() {
        // Given
        let viewModel = makeComposerViewModel()
        let group = makeUserGroup(name: "Dream Team")

        // When
        viewModel.checkForMentionedUsers(
            commandId: "mentions",
            extraData: ["mentionSuggestion": MentionSuggestion.group(group)]
        )

        // Then
        XCTAssertEqual(viewModel.mentionedGroups.map(\.id), [group.id])
    }

    func test_checkForMentionedUsers_withGroupSuggestion_doesNotDuplicate() {
        // Given
        let viewModel = makeComposerViewModel()
        let group = makeUserGroup(name: "Dream Team")

        // When
        viewModel.checkForMentionedUsers(
            commandId: "mentions",
            extraData: ["mentionSuggestion": MentionSuggestion.group(group)]
        )
        viewModel.checkForMentionedUsers(
            commandId: "mentions",
            extraData: ["mentionSuggestion": MentionSuggestion.group(group)]
        )

        // Then
        XCTAssertEqual(viewModel.mentionedGroups.count, 1)
    }

    func test_checkForMentionedUsers_whenNotMentionsCommand_ignored() {
        // Given
        let viewModel = makeComposerViewModel()

        // When
        viewModel.checkForMentionedUsers(
            commandId: "giphy",
            extraData: ["mentionSuggestion": MentionSuggestion.here]
        )

        // Then
        XCTAssertFalse(viewModel.mentionsHere)
        XCTAssertTrue(viewModel.mentionedUsers.isEmpty)
    }

    func test_clearRemovedMentions_removesMentionsNoLongerInText() {
        // Given
        let viewModel = makeComposerViewModel()
        populateAllMentionTypes(in: viewModel)

        // When
        viewModel.text = "Hello there"
        viewModel.clearRemovedMentions()

        // Then
        XCTAssertTrue(viewModel.mentionedUsers.isEmpty)
        XCTAssertTrue(viewModel.mentionedRoles.isEmpty)
        XCTAssertTrue(viewModel.mentionedGroups.isEmpty)
        XCTAssertFalse(viewModel.mentionsHere)
        XCTAssertFalse(viewModel.mentionsChannel)
    }

    func test_clearRemovedMentions_keepsMentionsStillInText() {
        // Given
        let viewModel = makeComposerViewModel()
        populateAllMentionTypes(in: viewModel)

        // When
        viewModel.text = "Hi @Martin @admin @Dream Team @here @channel"
        viewModel.clearRemovedMentions()

        // Then
        XCTAssertEqual(viewModel.mentionedUsers.first?.name, "Martin")
        XCTAssertEqual(viewModel.mentionedRoles, ["admin"])
        XCTAssertEqual(viewModel.mentionedGroups.map(\.name), ["Dream Team"])
        XCTAssertTrue(viewModel.mentionsHere)
        XCTAssertTrue(viewModel.mentionsChannel)
    }

    func test_showSuggestionsOverlay_whenMentionsWithMentionSuggestions_returnsTrue() {
        // Given
        let channelController = makeChannelController()
        let viewModel = MessageComposerViewModel(
            channelController: channelController,
            messageController: nil
        )

        // When
        channelController.channel_mock = .mock(cid: .unique, config: ChannelConfig(commands: []))
        viewModel.composerCommand = .init(id: "mentions", typingSuggestion: .empty, displayInfo: nil)
        viewModel.suggestions = ["mentions": [MentionSuggestion.here]]

        // Then
        XCTAssertTrue(viewModel.showSuggestionsOverlay)
    }

    func test_showSuggestionsOverlay_whenMentionsWithEmptyMentionSuggestions_returnsFalse() {
        // Given
        let channelController = makeChannelController()
        let viewModel = MessageComposerViewModel(
            channelController: channelController,
            messageController: nil
        )

        // When
        channelController.channel_mock = .mock(cid: .unique, config: ChannelConfig(commands: []))
        viewModel.composerCommand = .init(id: "mentions", typingSuggestion: .empty, displayInfo: nil)
        viewModel.suggestions = ["mentions": [MentionSuggestion]()]

        // Then
        XCTAssertFalse(viewModel.showSuggestionsOverlay)
    }

    func test_messageComposerVM_canSendPoll() {
        // Given
        let channelController = makeChannelController()
        let viewModel = MessageComposerViewModel(
            channelController: channelController,
            messageController: nil
        )

        // When
        let channelConfig = ChannelConfig(pollsEnabled: true)
        channelController.channel_mock = .mock(
            cid: .unique,
            config: channelConfig,
            ownCapabilities: [.sendPoll]
        )

        // Then
        XCTAssertTrue(viewModel.canSendPoll)
    }

    func test_messageComposerVM_canSendPoll_whenDoesNotHaveCapability() {
        // Given
        let channelController = makeChannelController()
        let viewModel = MessageComposerViewModel(
            channelController: channelController,
            messageController: nil
        )

        // When
        let channelConfig = ChannelConfig(pollsEnabled: true)
        channelController.channel_mock = .mock(
            cid: .unique,
            config: channelConfig,
            ownCapabilities: [.banChannelMembers]
        )

        // Then
        XCTAssertFalse(viewModel.canSendPoll)
    }

    func test_messageComposerVM_canSendPoll_whenNotEnabled() {
        // Given
        let channelController = makeChannelController()
        let viewModel = MessageComposerViewModel(
            channelController: channelController,
            messageController: nil
        )

        // When
        let channelConfig = ChannelConfig(pollsEnabled: false)
        channelController.channel_mock = .mock(
            cid: .unique,
            config: channelConfig,
            ownCapabilities: [.sendPoll]
        )

        // Then
        XCTAssertFalse(viewModel.canSendPoll)
    }

    func test_messageComposerVM_canSendPoll_whenInsideThread() {
        // Given
        let channelController = makeChannelController()
        let messageController = ChatMessageControllerSUI_Mock.mock(
            chatClient: chatClient,
            cid: .unique,
            messageId: .unique
        )
        let viewModel = MessageComposerViewModel(
            channelController: channelController,
            messageController: messageController
        )

        // When
        let channelConfig = ChannelConfig(pollsEnabled: true)
        channelController.channel_mock = .mock(
            cid: .unique,
            config: channelConfig,
            ownCapabilities: [.sendPoll]
        )

        // Then
        XCTAssertFalse(viewModel.canSendPoll)
    }

    func test_showSuggestionsOverlay_returnsTrue() {
        // Given
        let channelController = makeChannelController()
        let messageController = ChatMessageControllerSUI_Mock.mock(
            chatClient: chatClient,
            cid: .unique,
            messageId: .unique
        )
        let viewModel = MessageComposerViewModel(
            channelController: channelController,
            messageController: messageController
        )

        // When
        let channelConfig = ChannelConfig(commands: [.init()])
        channelController.channel_mock = .mock(
            cid: .unique,
            config: channelConfig
        )
        viewModel.composerCommand = .init(id: "test", typingSuggestion: .empty, displayInfo: nil)
        viewModel.suggestions = ["commands": []]

        // Then
        XCTAssertTrue(viewModel.showSuggestionsOverlay)
    }

    func test_showSuggestionsOverlay_whenComposerCommandIsNil_returnsFalse() {
        // Given
        let channelController = makeChannelController()
        let messageController = ChatMessageControllerSUI_Mock.mock(
            chatClient: chatClient,
            cid: .unique,
            messageId: .unique
        )
        let viewModel = MessageComposerViewModel(
            channelController: channelController,
            messageController: messageController
        )

        // When
        let channelConfig = ChannelConfig(commands: [.init()])
        channelController.channel_mock = .mock(
            cid: .unique,
            config: channelConfig
        )
        viewModel.composerCommand = nil

        // Then
        XCTAssertFalse(viewModel.showSuggestionsOverlay)
    }

    func test_showSuggestionsOverlay_whenCommandsAreDisabled_returnsFalse() {
        // Given
        let channelController = makeChannelController()
        let messageController = ChatMessageControllerSUI_Mock.mock(
            chatClient: chatClient,
            cid: .unique,
            messageId: .unique
        )
        let viewModel = MessageComposerViewModel(
            channelController: channelController,
            messageController: messageController
        )

        // When
        let channelConfig = ChannelConfig(commands: [])
        channelController.channel_mock = .mock(
            cid: .unique,
            config: channelConfig
        )
        viewModel.composerCommand = .init(id: "test", typingSuggestion: .empty, displayInfo: nil)

        // Then
        XCTAssertFalse(viewModel.showSuggestionsOverlay)
    }

    func test_showSuggestionsOverlay_whenMentionsWithUsers_returnsTrue() {
        // Given
        let channelController = makeChannelController()
        let messageController = ChatMessageControllerSUI_Mock.mock(
            chatClient: chatClient,
            cid: .unique,
            messageId: .unique
        )
        let viewModel = MessageComposerViewModel(
            channelController: channelController,
            messageController: messageController
        )

        // When
        let channelConfig = ChannelConfig(commands: [])
        channelController.channel_mock = .mock(
            cid: .unique,
            config: channelConfig
        )
        viewModel.composerCommand = .init(id: "mentions", typingSuggestion: .empty, displayInfo: nil)
        viewModel.suggestions = ["mentions": [ChatUser.mock(id: "test-user")]]

        // Then
        XCTAssertTrue(viewModel.showSuggestionsOverlay)
    }

    func test_showSuggestionsOverlay_whenMentionsWithNoUsers_returnsFalse() {
        // Given
        let channelController = makeChannelController()
        let messageController = ChatMessageControllerSUI_Mock.mock(
            chatClient: chatClient,
            cid: .unique,
            messageId: .unique
        )
        let viewModel = MessageComposerViewModel(
            channelController: channelController,
            messageController: messageController
        )

        // When
        let channelConfig = ChannelConfig(commands: [])
        channelController.channel_mock = .mock(
            cid: .unique,
            config: channelConfig
        )
        viewModel.composerCommand = .init(id: "mentions", typingSuggestion: .empty, displayInfo: nil)
        viewModel.suggestions = ["mentions": [ChatUser]()]

        // Then
        XCTAssertFalse(viewModel.showSuggestionsOverlay)
    }

    func test_showSuggestionsOverlay_whenCommandWithMentionUsers_returnsTrue() {
        // Given
        let channelController = makeChannelController()
        let viewModel = MessageComposerViewModel(
            channelController: channelController,
            messageController: nil
        )

        // When
        let channelConfig = ChannelConfig(commands: [.init()])
        channelController.channel_mock = .mock(
            cid: .unique,
            config: channelConfig
        )
        viewModel.composerCommand = .init(id: "/giphy", typingSuggestion: .empty, displayInfo: nil)
        viewModel.suggestions = ["mentions": [ChatUser.mock(id: "test-user")]]

        // Then
        XCTAssertTrue(viewModel.showSuggestionsOverlay)
    }

    func test_showSuggestionsOverlay_whenCommandWithNoMentionUsers_returnsFalse() {
        // Given
        let channelController = makeChannelController()
        let viewModel = MessageComposerViewModel(
            channelController: channelController,
            messageController: nil
        )

        // When
        let channelConfig = ChannelConfig(commands: [.init()])
        channelController.channel_mock = .mock(
            cid: .unique,
            config: channelConfig
        )
        viewModel.composerCommand = .init(id: "/giphy", typingSuggestion: .empty, displayInfo: nil)
        viewModel.suggestions = ["mentions": [ChatUser]()]

        // Then
        XCTAssertFalse(viewModel.showSuggestionsOverlay)
    }

    func test_messageComposerVM_checkChannelCooldown_whenNoLastMessageFromCurrentUser_keepsCooldownDisabled() {
        // Given
        let channelController = makeChannelController()
        channelController.channel_mock = makeChannelForCooldown(
            cooldownDuration: 15,
            lastMessageFromCurrentUser: nil
        )
        let viewModel = MessageComposerViewModel(
            channelController: channelController,
            messageController: nil
        )

        // When
        viewModel.checkChannelCooldown()

        // Then
        XCTAssertEqual(viewModel.cooldownDuration, 0)
    }

    func test_messageComposerVM_checkChannelCooldown_usesCurrentRemainingCooldown() {
        // Given
        let channelController = makeChannelController()
        let lastMessage = ChatMessage.mock(
            cid: channelController.cid ?? .unique,
            createdAt: Date().addingTimeInterval(-2),
            isSentByCurrentUser: true
        )
        channelController.channel_mock = makeChannelForCooldown(
            cooldownDuration: 15,
            lastMessageFromCurrentUser: lastMessage
        )
        let viewModel = MessageComposerViewModel(
            channelController: channelController,
            messageController: nil
        )

        // When
        viewModel.checkChannelCooldown()

        // Then
        XCTAssertLessThanOrEqual(viewModel.cooldownDuration, 13)
        XCTAssertGreaterThan(viewModel.cooldownDuration, 0)
    }

    func test_messageComposerVM_checkChannelCooldown_whenUserCanSkipSlowMode_keepsCooldownDisabled() {
        // Given
        let channelController = makeChannelController()
        let lastMessage = ChatMessage.mock(
            cid: channelController.cid ?? .unique,
            createdAt: Date().addingTimeInterval(-1),
            isSentByCurrentUser: true
        )
        channelController.channel_mock = makeChannelForCooldown(
            cooldownDuration: 15,
            lastMessageFromCurrentUser: lastMessage,
            ownCapabilities: [.sendMessage, .skipSlowMode]
        )
        let viewModel = MessageComposerViewModel(
            channelController: channelController,
            messageController: nil
        )

        // When
        viewModel.checkChannelCooldown()

        // Then
        XCTAssertEqual(viewModel.cooldownDuration, 0)
    }

    func test_addedAsset_extraData() {
        // Given
        let image = UIImage(systemName: "person")!
        let url = URL.newTemporaryFileURL()
        let addedAsset = AddedAsset(
            image: image,
            id: "imageId",
            url: url,
            type: .image,
            extraData: ["test": "test"]
        )
        
        // When
        try! image.pngData()?.write(to: url)
        let attachment = try! addedAsset.toAttachmentPayload()
        let payload = attachment.payload as! ImageAttachmentPayload
        let extraData = payload.extraData
        
        // Then
        XCTAssert(extraData?["test"] == "test")
        try! FileManager.default.removeItem(at: url)
    }

    func test_addedAsset_toAttachmentPayload_includesOriginalWidthHeightForImage() throws {
        let image = UIImage(systemName: "person")!
        let url = URL.newTemporaryFileURL()
        defer { try? FileManager.default.removeItem(at: url) }
        try image.pngData()?.write(to: url)

        let addedAsset = AddedAsset(
            image: image,
            id: "imageId",
            url: url,
            type: .image,
            originalWidth: 800,
            originalHeight: 600
        )

        let attachment = try addedAsset.toAttachmentPayload()
        let payload = try XCTUnwrap(attachment.payload as? ImageAttachmentPayload)
        XCTAssertEqual(payload.originalWidth, 800)
        XCTAssertEqual(payload.originalHeight, 600)
    }

    func test_addedAsset_toAttachmentPayload_includesWidthHeightDurationForVideo() throws {
        let thumbnail = UIImage(systemName: "video")!
        let url = URL.newTemporaryFileURL().appendingPathExtension("mp4")
        defer { try? FileManager.default.removeItem(at: url) }
        try Data(count: 100).write(to: url)

        let addedAsset = AddedAsset(
            image: thumbnail,
            id: "videoId",
            url: url,
            type: .video,
            originalWidth: 1920,
            originalHeight: 1080,
            duration: 120.5
        )

        let attachment = try addedAsset.toAttachmentPayload()
        let payload = try XCTUnwrap(attachment.payload as? VideoAttachmentPayload)
        XCTAssertEqual(payload.originalWidth, 1920)
        XCTAssertEqual(payload.originalHeight, 1080)
        XCTAssertEqual(payload.duration, 120.5)
    }

    func test_addedAsset_toAttachmentPayload_whenPayloadExists_returnsExistingPayload() throws {
        let image = UIImage(systemName: "person")!
        let url = URL.newTemporaryFileURL()
        defer { try? FileManager.default.removeItem(at: url) }
        try image.pngData()?.write(to: url)
        let existingPayload = ImageAttachmentPayload(
            title: "existing",
            imageRemoteURL: URL(string: "https://example.com/image.png")!,
            file: try AttachmentFile(url: url),
            originalWidth: 100,
            originalHeight: 200
        )

        let addedAsset = AddedAsset(
            image: image,
            id: "id",
            url: url,
            type: .image,
            payload: existingPayload
        )

        let attachment = try addedAsset.toAttachmentPayload()
        XCTAssertNil(attachment.localFileURL)
        let payload = try XCTUnwrap(attachment.payload as? ImageAttachmentPayload)
        XCTAssertEqual(payload.originalWidth, 100)
        XCTAssertEqual(payload.originalHeight, 200)
    }

    func test_addedAsset_toAttachmentPayload_videoWithOnlyDuration_setsDurationOnPayload() throws {
        let thumbnail = UIImage(systemName: "video")!
        let url = URL.newTemporaryFileURL().appendingPathExtension("mp4")
        defer { try? FileManager.default.removeItem(at: url) }
        try Data(count: 100).write(to: url)

        let addedAsset = AddedAsset(
            image: thumbnail,
            id: "videoId",
            url: url,
            type: .video,
            originalWidth: nil,
            originalHeight: nil,
            duration: 45.0
        )

        let attachment = try addedAsset.toAttachmentPayload()
        let payload = try XCTUnwrap(attachment.payload as? VideoAttachmentPayload)
        XCTAssertNil(payload.originalWidth)
        XCTAssertNil(payload.originalHeight)
        XCTAssertEqual(payload.duration, 45.0)
    }

    func test_addedAsset_toAttachmentPayload_withNoMetadata_passesNilLocalMetadata() throws {
        let image = UIImage(systemName: "person")!
        let url = URL.newTemporaryFileURL()
        defer { try? FileManager.default.removeItem(at: url) }
        try image.pngData()?.write(to: url)

        let addedAsset = AddedAsset(
            image: image,
            id: "id",
            url: url,
            type: .image,
            originalWidth: nil,
            originalHeight: nil,
            duration: nil
        )

        let attachment = try addedAsset.toAttachmentPayload()
        let payload = try XCTUnwrap(attachment.payload as? ImageAttachmentPayload)
        XCTAssertNotNil(payload.imageURL)
        XCTAssertNil(payload.originalWidth)
        XCTAssertNil(payload.originalHeight)
    }

    func test_imagePasted_setsOriginalWidthAndHeightOnAddedAsset() {
        let viewModel = makeComposerViewModel()
        let image = UIImage(systemName: "person.fill")!

        viewModel.imagePasted(image)

        let added: AddedAsset? = viewModel.composerAssets.compactMap {
            if case .addedAsset(let asset) = $0 { return asset }
            return nil
        }.last
        XCTAssertNotNil(added)
        XCTAssertEqual(added?.type, .image)
        XCTAssertNotNil(added?.originalWidth)
        XCTAssertNotNil(added?.originalHeight)
        XCTAssertEqual(added?.originalWidth, Double(image.size.width * image.scale))
        XCTAssertEqual(added?.originalHeight, Double(image.size.height * image.scale))
    }

    func test_cameraImageAdded_preservesAssetMetadata() {
        let viewModel = makeComposerViewModel()
        let image = UIImage(systemName: "video")!
        let url = URL.newTemporaryFileURL()
        defer { try? FileManager.default.removeItem(at: url) }
        try? Data(count: 10).write(to: url)
        let assetWithMetadata = AddedAsset(
            image: image,
            id: "cam",
            url: url,
            type: .video,
            originalWidth: 640,
            originalHeight: 480,
            duration: 12.5
        )

        viewModel.cameraImageAdded(assetWithMetadata)

        let addedAssets = viewModel.composerAssets.compactMap {
            if case .addedAsset(let asset) = $0 { return asset }
            return nil
        }
        XCTAssertEqual(addedAssets.count, 1)
        XCTAssertEqual(addedAssets.first?.originalWidth, 640)
        XCTAssertEqual(addedAssets.first?.originalHeight, 480)
        XCTAssertEqual(addedAssets.first?.duration, 12.5)
    }

    func test_convertAddedAssetsToPayloads_includesMetadataInPayloads() throws {
        let viewModel = makeComposerViewModel()
        let image = UIImage(systemName: "person")!
        let url = URL.newTemporaryFileURL()
        defer { try? FileManager.default.removeItem(at: url) }
        try image.pngData()?.write(to: url)
        viewModel.updateAddedAssets([
            AddedAsset(
                image: image,
                id: "1",
                url: url,
                type: .image,
                originalWidth: 300,
                originalHeight: 200
            )
        ])

        let payloads = try viewModel.convertAddedAssetsToPayloads()
        let imagePayload = try XCTUnwrap(payloads.first?.payload as? ImageAttachmentPayload)
        XCTAssertEqual(imagePayload.originalWidth, 300)
        XCTAssertEqual(imagePayload.originalHeight, 200)
    }

    func test_imagePickerCoordinator_imageSelection_setsOriginalWidthAndHeightOnAsset() throws {
        var captured: AddedAsset?
        let view = AttachmentImagePickerView(sourceType: .photoLibrary, onAssetPicked: { captured = $0 })
        let coordinator = view.makeCoordinator()
        let image = UIGraphicsImageRenderer(size: CGSize(width: 100, height: 80)).image { _ in }

        coordinator.imagePickerController(
            UIImagePickerController(),
            didFinishPickingMediaWithInfo: [.originalImage: image]
        )

        let asset = try XCTUnwrap(captured)
        XCTAssertEqual(asset.type, .image)
        XCTAssertEqual(asset.originalWidth, Double(image.size.width * image.scale))
        XCTAssertEqual(asset.originalHeight, Double(image.size.height * image.scale))
    }

    // MARK: - Recording
    
    func test_messageComposer_discardRecording() {
        // Given
        let viewModel = makeComposerViewModel()
        viewModel.recordingState = .recording
        
        // When
        viewModel.discardRecording()
        
        // Then
        XCTAssert(viewModel.recordingState == .initial)
        XCTAssert(viewModel.audioRecordingInfo == .initial)
    }
    
    func test_messageComposer_confirmStoppedRecording() {
        // Given
        let viewModel = makeComposerViewModel()
        viewModel.recordingState = .stopped
        viewModel.pendingAudioRecording = AddedVoiceRecording(
            url: .localYodaImage,
            duration: 1,
            waveform: [0, 1]
        )
        
        // When
        viewModel.confirmRecording()
        
        // Then
        XCTAssert(viewModel.recordingState == .initial)
        XCTAssert(viewModel.audioRecordingInfo == .initial)
        XCTAssertEqual(viewModel.addedVoiceRecordings.count, 1)
        XCTAssert(viewModel.pendingAudioRecording == nil)
    }
    
    func test_messageComposer_previewRecording() {
        // Given
        let viewModel = makeComposerViewModel()
        viewModel.recordingState = .recording
        
        // When
        viewModel.previewRecording()
        
        // Then
        XCTAssert(viewModel.recordingState == .stopped)
    }
    
    func test_messageComposer_lockRecording() {
        // Given
        let viewModel = makeComposerViewModel()
        viewModel.recordingState = .recording
        
        // When
        viewModel.recordingGestureLocation = .init(x: 0, y: VoiceRecordingConstants.lockMaxDistance - 1)
        
        // Then
        XCTAssert(viewModel.recordingState == .locked)
    }
    
    func test_messageComposer_cancelRecording() {
        // Given
        let viewModel = makeComposerViewModel()
        viewModel.recordingState = .recording
        
        // When
        viewModel.recordingGestureLocation = .init(x: VoiceRecordingConstants.cancelMaxDistance - 1, y: 0)
        
        // Then
        XCTAssert(viewModel.recordingState == .initial)
        XCTAssert(viewModel.recordingState.showsComposer == true)
    }
    
    func test_messageComposer_updateRecordingInfo() {
        // Given
        let viewModel = makeComposerViewModel()
        
        // Then
        let context = AudioRecordingContext(state: .recording, duration: 2.0, averagePower: 1.0)
        viewModel.audioRecorder(viewModel.audioRecorder, didUpdateContext: context)
        
        // Then
        XCTAssertEqual(viewModel.audioRecordingInfo.duration, 2.0)
        XCTAssert(viewModel.audioRecordingInfo.waveform == [1.0])
    }
    
    func test_messageComposer_recordingError() {
        // Given
        let viewModel = makeComposerViewModel()
        viewModel.recordingState = .recording
        
        // When
        viewModel.audioRecorder(viewModel.audioRecorder, didFailWithError: ClientError.Unexpected())
        
        // Then
        XCTAssert(viewModel.recordingState == .initial)
        XCTAssert(viewModel.audioRecordingInfo == .initial)
    }
    
    // MARK: - Recording Gesture Overlay Visibility

    func test_shouldShowRecordingGestureOverlay_whenInitialAndNoContent_returnsTrue() {
        // Given
        let viewModel = makeComposerViewModel()
        viewModel.recordingState = .initial

        // Then
        XCTAssertTrue(viewModel.shouldShowRecordingGestureOverlay)
    }

    func test_shouldShowRecordingGestureOverlay_whenInitialAndHasText_returnsFalse() {
        // Given
        let viewModel = makeComposerViewModel()
        viewModel.recordingState = .initial
        viewModel.text = "Hello"

        // Then
        XCTAssertFalse(viewModel.shouldShowRecordingGestureOverlay)
    }

    func test_shouldShowRecordingGestureOverlay_whenInitialAndHasAttachment_returnsFalse() {
        // Given
        let viewModel = makeComposerViewModel()
        viewModel.recordingState = .initial
        viewModel.imageTapped(defaultAsset)

        // Then
        XCTAssertFalse(viewModel.shouldShowRecordingGestureOverlay)
    }

    func test_shouldShowRecordingGestureOverlay_whenRecording_returnsTrue() {
        // Given
        let viewModel = makeComposerViewModel()
        viewModel.recordingState = .recording

        // Then
        XCTAssertTrue(viewModel.shouldShowRecordingGestureOverlay)
    }

    func test_shouldShowRecordingGestureOverlay_whenRecordingAndHasText_returnsTrue() {
        // Given
        let viewModel = makeComposerViewModel()
        viewModel.recordingState = .recording
        viewModel.text = "Hello"

        // Then
        XCTAssertTrue(viewModel.shouldShowRecordingGestureOverlay)
    }

    func test_shouldShowRecordingGestureOverlay_whenLocked_returnsFalse() {
        // Given
        let viewModel = makeComposerViewModel()
        viewModel.recordingState = .locked

        // Then
        XCTAssertFalse(viewModel.shouldShowRecordingGestureOverlay)
    }

    func test_shouldShowRecordingGestureOverlay_whenStopped_returnsFalse() {
        // Given
        let viewModel = makeComposerViewModel()
        viewModel.recordingState = .stopped

        // Then
        XCTAssertFalse(viewModel.shouldShowRecordingGestureOverlay)
    }

    func test_shouldShowRecordingGestureOverlay_whenVoiceRecordingDisabled_returnsFalse() {
        // Given
        let utils = Utils(composerConfig: ComposerConfig(isVoiceRecordingEnabled: false))
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
        let viewModel = makeComposerViewModel()
        viewModel.recordingState = .initial

        // Then
        XCTAssertFalse(viewModel.shouldShowRecordingGestureOverlay)
    }

    func test_shouldShowRecordingGestureOverlay_whenInstantCommandActive_returnsFalse() {
        // Given
        let viewModel = makeComposerViewModel()
        viewModel.recordingState = .initial

        // When
        viewModel.composerCommand = makeGiphyCommand()

        // Then
        XCTAssertFalse(
            viewModel.shouldShowRecordingGestureOverlay,
            "The overlay must stay hidden while an instant command is active, since the mic button is replaced by the send button."
        )
    }

    func test_shouldShowRecordingGestureOverlay_whenInCooldown_returnsFalse() {
        // Given
        let viewModel = makeComposerViewModel()
        viewModel.recordingState = .initial

        // When
        viewModel.cooldownDuration = 15

        // Then
        XCTAssertFalse(
            viewModel.shouldShowRecordingGestureOverlay,
            "The overlay must stay hidden during slow-mode cooldown, since the mic button is replaced by the cooldown indicator."
        )
    }

    func test_shouldShowRecordingGestureOverlay_whenEditingMessage_returnsFalse() {
        // Given
        var editedMessage: ChatMessage? = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Edited",
            author: .mock(id: .unique)
        )
        let editedBinding = Binding<ChatMessage?>(
            get: { editedMessage },
            set: { editedMessage = $0 }
        )
        let viewModel = MessageComposerViewModel(
            channelController: makeChannelController(),
            messageController: nil,
            editedMessage: editedBinding
        )
        viewModel.recordingState = .initial

        // Then
        XCTAssertFalse(
            viewModel.shouldShowRecordingGestureOverlay,
            "The overlay must stay hidden while editing a message, since the mic button is replaced by the confirm-edit button."
        )
    }

    func test_shouldShowRecordingGestureOverlay_whenCannotSendMessage_returnsFalse() {
        // Given
        let channelController = makeChannelController()
        channelController.channel_mock = .mockDMChannel(
            ownCapabilities: [.uploadFile, .readEvents]
        )
        let viewModel = MessageComposerViewModel(
            channelController: channelController,
            messageController: nil
        )
        viewModel.recordingState = .initial

        // Then
        XCTAssertFalse(
            viewModel.canSendMessage,
            "Precondition: the mock channel should not grant the send-message capability."
        )
        XCTAssertFalse(
            viewModel.shouldShowRecordingGestureOverlay,
            "The overlay must stay hidden in frozen/no-send channels, even when voice recording is enabled and the composer is empty."
        )
    }

    func test_composerInputState_whenCannotSendMessage_returnsCreatingInsteadOfAllowAudioRecording() {
        // Given
        let channelController = makeChannelController()
        channelController.channel_mock = .mockDMChannel(
            ownCapabilities: [.uploadFile, .readEvents]
        )
        let viewModel = MessageComposerViewModel(
            channelController: channelController,
            messageController: nil
        )

        // Then
        if case .allowAudioRecording = viewModel.composerInputState {
            XCTFail("composerInputState must not surface .allowAudioRecording when the channel does not allow sending messages.")
        }
    }

    func test_shouldShowRecordingGestureOverlay_whenInstantCommandActiveButRecording_returnsTrue() {
        // Given
        let viewModel = makeComposerViewModel()
        viewModel.composerCommand = makeGiphyCommand()

        // When
        viewModel.recordingState = .recording

        // Then
        XCTAssertTrue(
            viewModel.shouldShowRecordingGestureOverlay,
            "A recording already in progress must keep driving the overlay regardless of other composer state."
        )
    }

    // MARK: - Snackbar
    
    func test_messageComposer_showRecordingTip_setsSnackBarText() {
        // Given
        let viewModel = makeComposerViewModel()
        XCTAssertNil(viewModel.snackBarText)
        
        // When
        viewModel.showRecordingTip()
        
        // Then
        XCTAssertEqual(viewModel.snackBarText, L10n.Composer.Recording.tipSave)
    }

    func test_messageComposer_showRecordingTip_whenAutoSendEnabled_showsSendTip() {
        // Given
        let utils = Utils(composerConfig: ComposerConfig(isVoiceRecordingAutoSendEnabled: true))
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
        let viewModel = makeComposerViewModel()
        XCTAssertNil(viewModel.snackBarText)

        // When
        viewModel.showRecordingTip()

        // Then
        XCTAssertEqual(viewModel.snackBarText, L10n.Composer.Recording.tip)
    }
    
    func test_messageComposer_discardRecording_setsSnackBarText() {
        // Given
        let viewModel = makeComposerViewModel()
        viewModel.recordingState = .locked
        XCTAssertNil(viewModel.snackBarText)
        
        // When
        viewModel.discardRecording()
        
        // Then
        XCTAssertEqual(viewModel.snackBarText, L10n.Composer.Recording.voiceMessageDeleted)
        XCTAssertEqual(viewModel.recordingState, .initial)
    }
    
    func test_messageComposer_recordingError_setsSnackBarText() {
        // Given
        let viewModel = makeComposerViewModel()
        viewModel.recordingState = .recording
        XCTAssertNil(viewModel.snackBarText)
        
        // When
        viewModel.audioRecorder(viewModel.audioRecorder, didFailWithError: ClientError.Unexpected())
        
        // Then
        XCTAssertEqual(viewModel.snackBarText, L10n.Composer.Recording.recordingStopped)
    }
    
    func test_messageComposer_recordingError_whenNotRecording_doesNotSetSnackBarText() {
        // Given
        let viewModel = makeComposerViewModel()
        viewModel.recordingState = .initial
        XCTAssertNil(viewModel.snackBarText)
        
        // When
        viewModel.audioRecorder(viewModel.audioRecorder, didFailWithError: ClientError.Unexpected())
        
        // Then
        XCTAssertNil(viewModel.snackBarText)
    }
    
    // MARK: - Draft Message Tests

    func test_messageComposerVM_command() {
        // Given
        let draftMessage = DraftMessage.mock(text: "/giphy text")
        let channelController = makeChannelController()
        channelController.channel_mock = .mock(
            cid: channelController.cid!,
            config: ChannelConfig(commands: [Command(name: "giphy", description: "", set: "", args: "")]),
            draftMessage: draftMessage
        )
        let viewModel = makeComposerDraftsViewModel(
            channelController: channelController,
            messageController: nil
        )
        viewModel.fillDraftMessage()

        // When
        XCTAssertEqual(viewModel.composerCommand?.id, "/giphy")
        XCTAssertEqual(viewModel.text, "text")
    }

    func test_messageComposerVM_updateDraftMessage() {
        // Given
        let channelController = makeChannelController()
        let viewModel = makeComposerDraftsViewModel(
            channelController: channelController,
            messageController: nil
        )
        let quotedMessage = ChatMessage.mock(id: .unique, cid: .unique, text: "Quoted message", author: .mock(id: .unique))
        
        // When
        viewModel.text = "Draft text @here @channel @admin @Engineering"
        viewModel.mentionsHere = true
        viewModel.mentionsChannel = true
        viewModel.mentionedRoles = ["admin"]
        viewModel.mentionedGroups = [
            UserGroup(id: "engineering", name: "Engineering", createdAt: .init(), updatedAt: .init())
        ]
        viewModel.updateDraftMessage(quotedMessage: quotedMessage)
        
        // Then
        XCTAssertEqual(channelController.updateDraftMessage_text, "Draft text @here @channel @admin @Engineering")
        XCTAssertEqual(channelController.updateDraftMessage_callCount, 1)
        XCTAssertEqual(channelController.updateDraftMessage_mentionedHere, true)
        XCTAssertEqual(channelController.updateDraftMessage_mentionedChannel, true)
        XCTAssertEqual(channelController.updateDraftMessage_mentionedGroupIds, ["engineering"])
        XCTAssertEqual(channelController.updateDraftMessage_mentionedRoles, ["admin"])
    }
    
    func test_messageComposerVM_updateDraftReply() {
        // Given
        let channelController = makeChannelController()
        let messageController = ChatMessageControllerSUI_Mock.mock(
            chatClient: chatClient,
            cid: .unique,
            messageId: .unique
        )
        let viewModel = makeComposerDraftsViewModel(
            channelController: channelController,
            messageController: messageController
        )
        let quotedMessage = ChatMessage.mock(id: .unique, cid: .unique, text: "Quoted message", author: .mock(id: .unique))
        
        // When
        viewModel.text = "Draft reply @here @channel @admin @Engineering"
        viewModel.mentionsHere = true
        viewModel.mentionsChannel = true
        viewModel.mentionedRoles = ["admin"]
        viewModel.mentionedGroups = [
            UserGroup(id: "engineering", name: "Engineering", createdAt: .init(), updatedAt: .init())
        ]
        viewModel.updateDraftMessage(quotedMessage: quotedMessage)
        
        // Then
        XCTAssertEqual(messageController.updateDraftReply_text, "Draft reply @here @channel @admin @Engineering")
        XCTAssertEqual(messageController.updateDraftReply_callCount, 1)
        XCTAssertEqual(messageController.updateDraftReply_mentionedHere, true)
        XCTAssertEqual(messageController.updateDraftReply_mentionedChannel, true)
        XCTAssertEqual(messageController.updateDraftReply_mentionedGroupIds, ["engineering"])
        XCTAssertEqual(messageController.updateDraftReply_mentionedRoles, ["admin"])
    }
    
    func test_messageComposerVM_whenTextErased_shouldDeleteDraftMessage() {
        // Given
        let draftMessage = DraftMessage.mock(text: "text")
        let channelController = makeChannelController()
        channelController.channel_mock = .mock(cid: channelController.cid!, draftMessage: draftMessage)
        let viewModel = makeComposerDraftsViewModel(
            channelController: channelController,
            messageController: nil
        )
        viewModel.text = "text"

        // When
        viewModel.text = ""
        
        // Then
        XCTAssertEqual(channelController.deleteDraftMessage_callCount, 1)
    }
    
    func test_messageComposerVM_whenTextErased_deleteDraftReply() {
        // Given
        let channelController = makeChannelController()
        let messageController = ChatMessageControllerSUI_Mock.mock(
            chatClient: chatClient,
            cid: .unique,
            messageId: .unique
        )
        let draftMessage = DraftMessage.mock(text: "reply")
        messageController.message_mock = .mock(draftReply: draftMessage)
        let viewModel = makeComposerDraftsViewModel(
            channelController: channelController,
            messageController: messageController
        )
        viewModel.text = "reply"

        // When
        viewModel.text = ""
        
        // Then
        XCTAssertEqual(messageController.deleteDraftReply_callCount, 1)
    }

    func test_messageComposerVM_whenMessagePublished_deleteDraftMessage() {
        // Given
        let channelController = makeChannelController()
        let draftMessage = DraftMessage.mock(text: "text")
        channelController.channel_mock = .mock(cid: channelController.cid!, draftMessage: draftMessage)
        let viewModel = makeComposerDraftsViewModel(
            channelController: channelController,
            messageController: nil
        )
        viewModel.text = "text"

        // When
        viewModel.sendMessage()
        
        // Then
        let expectation = XCTestExpectation(description: "Text cleared")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            XCTAssertEqual(channelController.deleteDraftMessage_callCount, 1)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_messageComposerVM_whenMessagePublished_deleteDraftReply() {
        // Given
        let channelController = makeChannelController()
        let messageController = ChatMessageControllerSUI_Mock.mock(
            chatClient: chatClient,
            cid: .unique,
            messageId: .unique
        )
        let draftMessage = DraftMessage.mock(text: "reply")
        messageController.message_mock = .mock(draftReply: draftMessage)
        let viewModel = makeComposerDraftsViewModel(
            channelController: channelController,
            messageController: messageController
        )
        viewModel.text = "reply"

        // When
        viewModel.sendMessage()
        
        // Then
        let expectation = XCTestExpectation(description: "Text cleared")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            XCTAssertEqual(messageController.deleteDraftReply_callCount, 1)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_messageComposerVM_draftMessageUpdatedEvent() throws {
        // Given
        let channelController = makeChannelController()
        channelController.channel_mock = .mock(cid: .unique, draftMessage: .mock(text: "Draft"))
        let viewModel = makeComposerDraftsViewModel(
            channelController: channelController,
            messageController: nil
        )

        // When
        let draftMessage = DraftMessage.mock(text: "Draft from event")
        channelController.channel_mock = .mock(cid: .unique, draftMessage: draftMessage)
        let cid = try XCTUnwrap(channelController.cid)
        let event = DraftUpdatedEvent(cid: cid, channel: .mock(cid: cid), draftMessage: draftMessage, createdAt: .unique)
        viewModel.eventsController(viewModel.eventsController, didReceiveEvent: event)
        
        // Then
        XCTAssertEqual(viewModel.text, "Draft from event")
    }
    
    func test_messageComposerVM_draftReplyUpdatedEvent() throws {
        // Given
        let channelController = makeChannelController()
        let messageController = ChatMessageControllerSUI_Mock.mock(
            chatClient: chatClient,
            cid: channelController.cid!,
            messageId: .unique
        )
        messageController.message_mock = .mock(draftReply: .mock(text: "Draft"))
        let viewModel = makeComposerDraftsViewModel(
            channelController: channelController,
            messageController: messageController
        )
        
        // When
        let draftMessage = DraftMessage.mock(
            threadId: messageController.messageId,
            text: "Draft reply from event"
        )
        messageController.message_mock = .mock(draftReply: draftMessage)
        let cid = try XCTUnwrap(channelController.cid)
        let event = DraftUpdatedEvent(cid: cid, channel: .mock(cid: cid), draftMessage: draftMessage, createdAt: .unique)
        viewModel.eventsController(viewModel.eventsController, didReceiveEvent: event)
        
        // Then
        XCTAssertEqual(viewModel.text, "Draft reply from event")
    }

    func test_messageComposerVM_draftReplyUpdatedEventFromOtherThread_shouldNotUpdate() throws {
        // Given
        let channelController = makeChannelController()
        let messageController = ChatMessageControllerSUI_Mock.mock(
            chatClient: chatClient,
            cid: channelController.cid!,
            messageId: .unique
        )
        messageController.message_mock = .mock(draftReply: .mock(text: "Draft"))
        let viewModel = makeComposerDraftsViewModel(
            channelController: channelController,
            messageController: messageController
        )
        viewModel.fillDraftMessage()

        // When
        let draftMessage = DraftMessage.mock(
            threadId: .unique,
            text: "Draft reply from event"
        )
        messageController.message_mock = .mock(draftReply: draftMessage)
        let cid = try XCTUnwrap(channelController.cid)
        let event = DraftUpdatedEvent(cid: cid, channel: .mock(cid: cid), draftMessage: draftMessage, createdAt: .unique)
        viewModel.eventsController(viewModel.eventsController, didReceiveEvent: event)

        // Then
        XCTAssertEqual(viewModel.text, "Draft")
    }

    func test_messageComposerVM_whenLastAssetRemoved_shouldDeleteDraft() {
        // Given
        let channelController = makeChannelController()
        let draftMessage = DraftMessage.mock(text: "")
        channelController.channel_mock = .mock(cid: .unique, draftMessage: draftMessage)
        let viewModel = makeComposerDraftsViewModel(
            channelController: channelController,
            messageController: nil
        )
        let asset = defaultAsset
        viewModel.imageTapped(asset)

        // When
        viewModel.imageTapped(asset) // Remove the asset by tapping again

        // Then
        XCTAssertEqual(channelController.deleteDraftMessage_callCount, 1)
    }

    func test_messageComposerVM_whenLastFileRemoved_shouldDeleteDraft() {
        // Given
        let channelController = makeChannelController()
        let draftMessage = DraftMessage.mock(text: "")
        channelController.channel_mock = .mock(cid: .unique, draftMessage: draftMessage)
        let viewModel = makeComposerDraftsViewModel(
            channelController: channelController,
            messageController: nil
        )
        viewModel.composerAssets = [.addedFile(mockURL)]

        // When
        viewModel.removeAttachment(with: mockURL.absoluteString)

        // Then
        XCTAssertEqual(channelController.deleteDraftMessage_callCount, 1)
    }

    func test_messageComposerVM_whenLastVoiceRecordingRemoved_shouldDeleteDraft() {
        // Given
        let channelController = makeChannelController()
        let draftMessage = DraftMessage.mock(text: "")
        channelController.channel_mock = .mock(cid: .unique, draftMessage: draftMessage)
        let viewModel = makeComposerDraftsViewModel(
            channelController: channelController,
            messageController: nil
        )
        let recording = AddedVoiceRecording(url: mockURL, duration: 1.0, waveform: [0.5])
        viewModel.addedVoiceRecordings = [recording]

        // When
        viewModel.removeAttachment(with: mockURL.absoluteString)

        // Then
        XCTAssertEqual(channelController.deleteDraftMessage_callCount, 1)
    }

    func test_messageComposerVM_whenLastCustomAttachmentRemoved_shouldDeleteDraft() {
        // Given
        let channelController = makeChannelController()
        let draftMessage = DraftMessage.mock(text: "")
        channelController.channel_mock = .mock(cid: .unique, draftMessage: draftMessage)
        let viewModel = makeComposerDraftsViewModel(
            channelController: channelController,
            messageController: nil
        )
        let attachment = CustomAttachment(id: .unique, content: .mockFile)
        viewModel.customAttachmentTapped(attachment)

        // When
        viewModel.customAttachmentTapped(attachment) // Remove by tapping again

        // Then
        XCTAssertEqual(channelController.deleteDraftMessage_callCount, 1)
    }

    func test_messageComposerVM_whenRemovingAttachment_withTextPresent_shouldNotDeleteDraft() {
        // Given
        let channelController = makeChannelController()
        let draftMessage = DraftMessage.mock(text: "Hello")
        channelController.channel_mock = .mock(cid: .unique, draftMessage: draftMessage)
        let viewModel = makeComposerDraftsViewModel(
            channelController: channelController,
            messageController: nil
        )
        viewModel.text = "Hello"
        let asset = defaultAsset
        viewModel.imageTapped(asset)

        // When
        viewModel.imageTapped(asset) // Remove the asset by tapping again

        // Then
        XCTAssertEqual(channelController.deleteDraftMessage_callCount, 0)
    }

    // MARK: - stopPreviewPlaybackIfNeeded

    func test_stopPreviewPlaybackIfNeeded_stopsAudioPlayer_whenPlayerLoadedWithPendingRecording() {
        // Given
        let mockPlayer = MockAudioPlayer()
        streamChat?.utils._audioPlayer = mockPlayer
        let viewModel = makeComposerViewModel()
        viewModel.pendingAudioRecording = AddedVoiceRecording(url: mockURL, duration: 1, waveform: [])
        simulatePlayerLoaded(viewModel: viewModel, player: mockPlayer, assetLocation: mockURL)

        // When
        viewModel.stopPreviewPlaybackIfNeeded()

        // Then
        XCTAssertTrue(mockPlayer.stopWasCalled)
    }

    func test_stopPreviewPlaybackIfNeeded_stopsAudioPlayer_whenPlayerLoadedWithAddedRecording() {
        // Given
        let mockPlayer = MockAudioPlayer()
        streamChat?.utils._audioPlayer = mockPlayer
        let viewModel = makeComposerViewModel()
        viewModel.addedVoiceRecordings = [AddedVoiceRecording(url: mockURL, duration: 1, waveform: [])]
        simulatePlayerLoaded(viewModel: viewModel, player: mockPlayer, assetLocation: mockURL)

        // When
        viewModel.stopPreviewPlaybackIfNeeded()

        // Then
        XCTAssertTrue(mockPlayer.stopWasCalled)
    }

    func test_stopPreviewPlaybackIfNeeded_doesNotStopAudioPlayer_whenNoRecordings() {
        // Given
        let mockPlayer = MockAudioPlayer()
        streamChat?.utils._audioPlayer = mockPlayer
        let viewModel = makeComposerViewModel()
        viewModel.pendingAudioRecording = nil
        viewModel.addedVoiceRecordings = []

        // When
        viewModel.stopPreviewPlaybackIfNeeded()

        // Then
        XCTAssertFalse(mockPlayer.stopWasCalled)
    }

    func test_stopPreviewPlaybackIfNeeded_doesNotStopAudioPlayer_whenPlayerLoadedWithUnrelatedURL() {
        // Given — the composer has local recordings, but the shared player is
        // playing a message-list voice message (unrelated URL). The composer
        // must not stop the player and break that unrelated playback.
        let mockPlayer = MockAudioPlayer()
        streamChat?.utils._audioPlayer = mockPlayer
        let viewModel = makeComposerViewModel()
        viewModel.addedVoiceRecordings = [AddedVoiceRecording(url: mockURL, duration: 1, waveform: [])]
        let unrelatedURL = URL(fileURLWithPath: "/tmp/unrelated-message-list-voice.aac")
        simulatePlayerLoaded(viewModel: viewModel, player: mockPlayer, assetLocation: unrelatedURL)

        // When
        viewModel.stopPreviewPlaybackIfNeeded()

        // Then
        XCTAssertFalse(mockPlayer.stopWasCalled)
    }

    func test_stopPreviewPlaybackIfNeeded_doesNotStopAudioPlayer_whenPlayerHasNoLoadedAsset() {
        // Given — local recordings exist but the player has not loaded any
        // asset yet (currentPlaybackURL is nil).
        let mockPlayer = MockAudioPlayer()
        streamChat?.utils._audioPlayer = mockPlayer
        let viewModel = makeComposerViewModel()
        viewModel.pendingAudioRecording = AddedVoiceRecording(url: mockURL, duration: 1, waveform: [])

        // When
        viewModel.stopPreviewPlaybackIfNeeded()

        // Then
        XCTAssertFalse(mockPlayer.stopWasCalled)
    }

    func test_discardRecording_stopsAudioPlayer_whenPlayerLoadedWithPendingRecording() {
        // Given
        let mockPlayer = MockAudioPlayer()
        streamChat?.utils._audioPlayer = mockPlayer
        let viewModel = makeComposerViewModel()
        viewModel.recordingState = .locked
        viewModel.pendingAudioRecording = AddedVoiceRecording(url: mockURL, duration: 1, waveform: [])
        simulatePlayerLoaded(viewModel: viewModel, player: mockPlayer, assetLocation: mockURL)

        // When
        viewModel.discardRecording()

        // Then
        XCTAssertTrue(mockPlayer.stopWasCalled)
    }

    func test_confirmRecording_stopsAudioPlayer_whenPlayerLoadedWithPendingRecording() {
        // Given
        let mockPlayer = MockAudioPlayer()
        streamChat?.utils._audioPlayer = mockPlayer
        let viewModel = makeComposerViewModel()
        viewModel.recordingState = .stopped
        viewModel.pendingAudioRecording = AddedVoiceRecording(url: mockURL, duration: 1, waveform: [])
        simulatePlayerLoaded(viewModel: viewModel, player: mockPlayer, assetLocation: mockURL)

        // When
        viewModel.confirmRecording()

        // Then
        XCTAssertTrue(mockPlayer.stopWasCalled)
    }

    func test_sendMessage_stopsAudioPlayer_whenPlayerLoadedWithAddedRecording() {
        // Given
        let mockPlayer = MockAudioPlayer()
        streamChat?.utils._audioPlayer = mockPlayer
        let viewModel = makeComposerViewModel()
        viewModel.addedVoiceRecordings = [AddedVoiceRecording(url: mockURL, duration: 1, waveform: [])]
        viewModel.text = "test"
        simulatePlayerLoaded(viewModel: viewModel, player: mockPlayer, assetLocation: mockURL)

        // When
        viewModel.sendMessage()

        // Then
        XCTAssertTrue(mockPlayer.stopWasCalled)
    }

    /// Drives the view model's `AudioPlayingDelegate` callback so `currentPlaybackURL`
    /// reflects what the shared player has loaded — required by the gating in
    /// `stopPreviewPlaybackIfNeeded`.
    private func simulatePlayerLoaded(
        viewModel: MessageComposerViewModel,
        player: AudioPlaying,
        assetLocation: URL?
    ) {
        let context = AudioPlaybackContext(
            assetLocation: assetLocation,
            duration: 0,
            currentTime: 0,
            state: .paused,
            rate: .zero,
            isSeeking: false
        )
        viewModel.audioPlayer(player, didUpdateContext: context)
    }

    // MARK: - Deferred editedMessage/quotedMessage reset

    func test_sendMessage_doesNotImmediatelyClearEditedMessage() {
        // Given
        var editedMessage: ChatMessage? = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Edited",
            author: .mock(id: .unique)
        )
        let editedBinding = Binding<ChatMessage?>(
            get: { editedMessage },
            set: { editedMessage = $0 }
        )
        let viewModel = MessageComposerViewModel(
            channelController: makeChannelController(),
            messageController: nil,
            editedMessage: editedBinding
        )
        viewModel.text = "updated text"

        // When
        viewModel.sendMessage()

        // Then — editedMessage must NOT be cleared synchronously, preventing a
        // brief ConfirmEdit → Send → Mic flash in the trailing composer button.
        XCTAssertNotNil(
            editedMessage,
            "editedMessage should not be cleared immediately after sendMessage()"
        )
    }

    func test_sendMessage_doesNotImmediatelyClearQuotedMessage() {
        // Given
        var quotedMessage: ChatMessage? = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Quoted",
            author: .mock(id: .unique)
        )
        let quotedBinding = Binding<ChatMessage?>(
            get: { quotedMessage },
            set: { quotedMessage = $0 }
        )
        let viewModel = MessageComposerViewModel(
            channelController: makeChannelController(),
            messageController: nil,
            quotedMessage: quotedBinding
        )
        viewModel.text = "reply text"

        // When
        viewModel.sendMessage()

        // Then — quotedMessage must NOT be cleared synchronously.
        XCTAssertNotNil(
            quotedMessage,
            "quotedMessage should not be cleared immediately after sendMessage()"
        )
    }

    // MARK: - sendRecording

    func test_sendRecording_whenRecording_setsShouldSendOnRecordingFinish() {
        let viewModel = makeComposerViewModel()
        viewModel.recordingState = .recording

        viewModel.sendRecording()

        XCTAssertTrue(viewModel.shouldSendOnRecordingFinish)
    }

    func test_sendRecording_whenNotRecording_doesNotSetShouldSendOnRecordingFinish() {
        let viewModel = makeComposerViewModel()
        viewModel.recordingState = .initial

        viewModel.sendRecording()

        XCTAssertFalse(viewModel.shouldSendOnRecordingFinish)
    }

    func test_discardRecording_resetsShouldSendOnRecordingFinish() {
        let viewModel = makeComposerViewModel()
        viewModel.shouldSendOnRecordingFinish = true

        viewModel.discardRecording()

        XCTAssertFalse(viewModel.shouldSendOnRecordingFinish)
    }

    // MARK: - saveRecording

    func test_saveRecording_whenRecording_setsShouldSendOnRecordingFinishToFalse() {
        // Given
        let viewModel = makeComposerViewModel()
        viewModel.recordingState = .recording
        viewModel.shouldSendOnRecordingFinish = true

        // When
        viewModel.saveRecording()

        // Then
        XCTAssertFalse(viewModel.shouldSendOnRecordingFinish)
    }

    func test_saveRecording_whenNotRecording_doesNothing() {
        // Given
        let viewModel = makeComposerViewModel()
        viewModel.recordingState = .initial
        viewModel.shouldSendOnRecordingFinish = true

        // When
        viewModel.saveRecording()

        // Then
        XCTAssertTrue(viewModel.shouldSendOnRecordingFinish)
    }

    // MARK: - private

    private func makeComposerDraftsViewModel(
        channelController: ChatChannelController,
        messageController: ChatMessageController?
    ) -> MessageComposerViewModel {
        let viewModel = MessageComposerViewModel(
            channelController: channelController,
            messageController: messageController
        )
        viewModel.utils = .init(messageListConfig: .init(draftMessagesEnabled: true))
        return viewModel
    }

    private func makeComposerViewModel() -> MessageComposerViewModel {
        MessageComposerTestUtils.makeComposerViewModel(chatClient: chatClient)
    }

    private func makeUserGroup(name: String) -> UserGroup {
        UserGroup(id: .unique, name: name, createdAt: .init(), updatedAt: .init())
    }

    private func populateAllMentionTypes(in viewModel: MessageComposerViewModel) {
        viewModel.checkForMentionedUsers(
            commandId: "mentions",
            extraData: ["mentionSuggestion": MentionSuggestion.user(.mock(id: .unique, name: "Martin"))]
        )
        viewModel.checkForMentionedUsers(
            commandId: "mentions",
            extraData: ["mentionSuggestion": MentionSuggestion.role(Role(name: "admin"))]
        )
        viewModel.checkForMentionedUsers(
            commandId: "mentions",
            extraData: ["mentionSuggestion": MentionSuggestion.group(makeUserGroup(name: "Dream Team"))]
        )
        viewModel.checkForMentionedUsers(
            commandId: "mentions",
            extraData: ["mentionSuggestion": MentionSuggestion.here]
        )
        viewModel.checkForMentionedUsers(
            commandId: "mentions",
            extraData: ["mentionSuggestion": MentionSuggestion.channel]
        )
    }

    private func makeGiphyCommand() -> ComposerCommand {
        let displayInfo = CommandDisplayInfo(
            displayName: "Giphy",
            icon: UIImage(systemName: "photo") ?? UIImage(),
            format: "/giphy [text]",
            isInstant: true
        )
        return ComposerCommand(
            id: "/giphy",
            typingSuggestion: TypingSuggestion.empty,
            displayInfo: displayInfo
        )
    }
    
    private func makeChannelController(
        messages: [ChatMessage] = []
    ) -> ChatChannelController_Mock {
        MessageComposerTestUtils.makeChannelController(
            chatClient: chatClient,
            messages: messages
        )
    }

    private func makeChannelForCooldown(
        cooldownDuration: Int,
        lastMessageFromCurrentUser: ChatMessage?,
        ownCapabilities: Set<ChannelCapability> = [.sendMessage, .uploadFile]
    ) -> ChatChannel {
        ChatChannel(
            cid: .unique,
            name: nil,
            imageURL: nil,
            isHidden: false,
            config: .mock(),
            ownCapabilities: ownCapabilities,
            lastActiveMembers: [],
            currentlyTypingUsers: [],
            lastActiveWatchers: [],
            unreadCount: .noUnread,
            cooldownDuration: cooldownDuration,
            extraData: [:],
            latestMessages: lastMessageFromCurrentUser.map { [$0] } ?? [],
            lastMessageFromCurrentUser: lastMessageFromCurrentUser,
            pinnedMessages: [],
            pendingMessages: [],
            muteDetails: nil,
            draftMessage: nil,
            activeLiveLocations: [],
            pushPreference: nil
        )
    }
    
    private func generateURL() -> URL {
        NSURL.fileURL(
            withPath: NSTemporaryDirectory() + UUID().uuidString + ".png"
        )
    }
    
    private func writeMockData(for url: URL) {
        let data = UIImage(systemName: "checkmark")?.pngData()
        try? data?.write(to: url)
    }
}

enum MessageComposerTestUtils {
    @MainActor static func makeComposerViewModel(chatClient: ChatClient) -> MessageComposerViewModel {
        let channelController = makeChannelController(chatClient: chatClient)
        let viewModel = MessageComposerViewModel(
            channelController: channelController,
            messageController: nil
        )
        return viewModel
    }
    
    static func makeChannelController(
        chatClient: ChatClient,
        messages: [ChatMessage] = []
    ) -> ChatChannelController_Mock {
        ChatChannelTestHelpers.makeChannelController(
            chatClient: chatClient,
            messages: messages
        )
    }
}
