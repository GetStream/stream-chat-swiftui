//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import XCTest
@testable import StreamChatSwiftUI
@testable import StreamChat

class MessageComposerViewModel_Tests: XCTestCase {
    
    private let testImage = UIImage(systemName: "checkmark")!
    private let testURL = URL(string: "https://example.com")!
    private lazy var defaultAsset = AddedAsset(
        image: testImage,
        id: .unique,
        url: testURL,
        type: .image
    )

    private var chatClient: ChatClient = {
        let client = ChatClient.mock()
        client.currentUserId = .unique
        return client
    }()
    
    private var streamChat: StreamChat?
        
    override func setUp() {
        super.setUp()
        streamChat = StreamChat(chatClient: chatClient)
    }
    
    func test_messageComposerVM_sendButtonDisabled() {
        // Given
        let viewModel = makeComposerViewModel()
        
        // When
        let buttonEnabled = viewModel.sendButtonEnabled
        
        // Then
        XCTAssert(buttonEnabled == false)
    }
    
    func test_messageComposerVM_sendButtonEnabled_textChange() {
        // Given
        let viewModel = makeComposerViewModel()
        
        // When
        viewModel.text = "test"
        let buttonEnabled = viewModel.sendButtonEnabled
        
        // Then
        XCTAssert(buttonEnabled == true)
        XCTAssert(viewModel.pickerTypeState == .collapsed)
    }
    
    func test_messageComposerVM_sendButtonEnabled_addedAsset() {
        // Given
        let viewModel = makeComposerViewModel()
        
        // When
        viewModel.imageTapped(defaultAsset)
        let buttonEnabled = viewModel.sendButtonEnabled
        
        // Then
        XCTAssert(buttonEnabled == true)
        XCTAssert(viewModel.addedAssets.count == 1)
    }
    
    func test_messageComposerVM_sendButtonEnabled_addedFile() {
        // Given
        let viewModel = makeComposerViewModel()
        
        // When
        viewModel.addedFileURLs.append(testURL)
        let buttonEnabled = viewModel.sendButtonEnabled
        
        // Then
        XCTAssert(buttonEnabled == true)
        XCTAssert(viewModel.addedFileURLs.count == 1)
    }
    
    func test_messageComposerVM_sendButtonEnabled_addedCustomAttachment() {
        // Given
        let viewModel = makeComposerViewModel()
        let attachment = CustomAttachment(id: .unique, content: .mockFile)
        
        // When
        viewModel.customAttachmentTapped(attachment)
        let buttonEnabled = viewModel.sendButtonEnabled
        
        // Then
        XCTAssert(buttonEnabled == true)
        XCTAssert(viewModel.addedCustomAttachments.count == 1)
    }
    
    func test_messageComposerVM_changePickerState() {
        // Given
        let viewModel = makeComposerViewModel()
        
        // When
        viewModel.change(pickerState: .custom)
        
        // Then
        XCTAssert(viewModel.pickerState == .custom)
    }
    
    func test_messageComposerVM_inputComposerNotScrollable() {
        // Given
        let viewModel = makeComposerViewModel()
        
        // When
        viewModel.imageTapped(defaultAsset)
        let inputComposerScrollable = viewModel.inputComposerShouldScroll
        
        // Then
        XCTAssert(inputComposerScrollable == false)
    }
    
    func test_messageComposerVM_inputComposerScrollableAttachments() {
        // Given
        let viewModel = makeComposerViewModel()
        let attachments = [
            CustomAttachment(id: .unique, content: .mockFile),
            CustomAttachment(id: .unique, content: .mockImage),
            CustomAttachment(id: .unique, content: .mockVideo),
            CustomAttachment(id: .unique, content: .mockVideo)
        ]
        
        // When
        viewModel.addedCustomAttachments = attachments
        let inputComposerScrollable = viewModel.inputComposerShouldScroll
        
        // Then
        XCTAssert(inputComposerScrollable == true)
    }
    
    func test_messageComposerVM_inputComposerScrollableFiles() {
        // Given
        let viewModel = makeComposerViewModel()
        let attachments = [testURL, testURL, testURL]
        
        // When
        viewModel.addedFileURLs = attachments
        let inputComposerScrollable = viewModel.inputComposerShouldScroll
        
        // Then
        XCTAssert(inputComposerScrollable == true)
    }
    
    func test_messageComposerVM_imageRemovalByTappingTwice() {
        // Given
        let viewModel = makeComposerViewModel()
        
        // When
        viewModel.imageTapped(defaultAsset) // added to the attachments list
        viewModel.imageTapped(defaultAsset) // removed from the attachments list
        
        // Then
        XCTAssert(viewModel.addedAssets.count == 0)
    }
    
    func test_messageComposerVM_removeFileAttachment() {
        // Given
        let viewModel = makeComposerViewModel()
        
        // When
        viewModel.addedFileURLs = [testURL]
        viewModel.removeAttachment(with: testURL.absoluteString)
        
        // Then
        XCTAssert(viewModel.addedFileURLs.count == 0)
    }
    
    func test_messageComposerVM_removeImageAttachment() {
        // Given
        let viewModel = makeComposerViewModel()
        
        // When
        viewModel.imageTapped(defaultAsset)
        viewModel.removeAttachment(with: defaultAsset.id)
        
        // Then
        XCTAssert(viewModel.addedAssets.count == 0)
    }
    
    func test_messageComposerVM_cameraImageAdded() {
        // Given
        let viewModel = makeComposerViewModel()
        
        // When
        viewModel.cameraImageAdded(defaultAsset)
        
        // Then
        XCTAssert(viewModel.addedAssets.count == 1)
        XCTAssert(viewModel.pickerState == .photos)
    }
    
    func test_messageComposerVM_imageIsSelected() {
        // Given
        let viewModel = makeComposerViewModel()
        
        // When
        viewModel.imageTapped(defaultAsset)
        let imageIsSelected = viewModel.isImageSelected(with: defaultAsset.id)
        
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
        XCTAssert(viewModel.addedCustomAttachments.count == 0)
    }
    
    func test_messageComposerVM_cameraPickerShown() {
        // Given
        let viewModel = makeComposerViewModel()
        
        // When
        viewModel.pickerState = .camera
        
        // Then
        XCTAssert(viewModel.cameraPickerShown == true)
    }
    
    func test_messageComposerVM_filePickerShown() {
        // Given
        let viewModel = makeComposerViewModel()
        
        // When
        viewModel.pickerState = .files
        
        // Then
        XCTAssert(viewModel.filePickerShown == true)
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
        viewModel.addedFileURLs = [testURL]
        viewModel.sendMessage {
            // Then
            XCTAssert(viewModel.errorShown == false)
            XCTAssert(viewModel.text == "")
            XCTAssert(viewModel.addedAssets.isEmpty)
            XCTAssert(viewModel.addedFileURLs.isEmpty)
        }
    }
    
    //MARK: - private
    
    private func makeComposerViewModel() -> MessageComposerViewModel {
        let channelController = makeChannelController()
        let viewModel = MessageComposerViewModel(channelController: channelController)
        return viewModel
    }
    
    private func makeChannelController(
        messages: [ChatMessage] = []
    ) -> ChatChannelController_Mock {
        return ChatChannelTestHelpers.makeChannelController(
            chatClient: chatClient,
            messages: messages
        )
    }

}

extension PickerTypeState: Equatable {
    
    public static func == (lhs: PickerTypeState, rhs: PickerTypeState) -> Bool {
        if case let .expanded(type1) = lhs,
           case let .expanded(type2) = rhs {
            return type1 == type2
        }
        
        if case .collapsed = lhs, case .collapsed = rhs {
            return true
        }
        
        return false
        
    }
    
    
    
    
}
