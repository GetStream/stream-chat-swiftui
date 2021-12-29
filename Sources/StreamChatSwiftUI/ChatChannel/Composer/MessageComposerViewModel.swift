//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Combine
import Photos
import StreamChat
import SwiftUI

/// View model for the `MessageComposerView`.
public class MessageComposerViewModel: ObservableObject {
    @Injected(\.chatClient) private var chatClient
    @Injected(\.utils) private var utils
    
    @Published var pickerState: AttachmentPickerState = .photos {
        didSet {
            if pickerState == .camera {
                withAnimation {
                    cameraPickerShown = true
                }
            } else if pickerState == .files {
                withAnimation {
                    filePickerShown = true
                }
            }
        }
    }
    
    @Published private(set) var imageAssets: PHFetchResult<PHAsset>?
    @Published private(set) var addedAssets = [AddedAsset]() {
        didSet {
            checkPickerSelectionState()
        }
    }
    
    @Published var text = "" {
        didSet {
            if text != "" {
                pickerTypeState = .collapsed
                channelController.sendKeystrokeEvent()
                checkTypingSuggestions()
            } else {
                if composerCommand?.displayInfo?.isInstant == false {
                    composerCommand = nil
                }
                selectedRangeLocation = 0
                suggestions = [String: Any]()
            }
        }
    }

    @Published var selectedRangeLocation: Int = 0
    
    @Published var addedFileURLs = [URL]() {
        didSet {
            checkPickerSelectionState()
        }
    }

    @Published var addedCustomAttachments = [CustomAttachment]() {
        didSet {
            checkPickerSelectionState()
        }
    }
    
    @Published var pickerTypeState: PickerTypeState = .expanded(.none) {
        didSet {
            switch pickerTypeState {
            case let .expanded(attachmentPickerType):
                overlayShown = attachmentPickerType == .media
                if attachmentPickerType == .giphy {
                    composerCommand = ComposerCommand(
                        id: "instantCommands",
                        typingSuggestion: TypingSuggestion.empty,
                        displayInfo: nil
                    )
                    showTypingSuggestions()
                } else {
                    composerCommand = nil
                }
            case .collapsed:
                log.debug("Collapsed state shown, no changes to overlay.")
            }
        }
    }
    
    @Published private(set) var overlayShown = false {
        didSet {
            if overlayShown == true {
                resignFirstResponder()
            }
        }
    }

    @Published var composerCommand: ComposerCommand? {
        didSet {
            if oldValue?.id != composerCommand?.id &&
                composerCommand?.displayInfo?.isInstant == true {
                // This is needed because of autocompleting text from the keyboard.
                // The update of the text is done in the next cycle, so it overrides
                // the setting of this value to empty string.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
                    self?.text = ""
                }
            }
            if oldValue != nil && composerCommand == nil {
                pickerTypeState = .expanded(.none)
            }
        }
    }
    
    @Published var filePickerShown = false
    @Published var cameraPickerShown = false
    @Published var errorShown = false
    @Published var showReplyInChannel = false
    @Published var suggestions = [String: Any]()
    
    private let channelController: ChatChannelController
    private var messageController: ChatMessageController?
    
    private var cancellables = Set<AnyCancellable>()
    private lazy var commandsHandler = utils
        .commandsConfig
        .makeCommandsHandler(
            with: channelController
        )
    
    private var messageText: String {
        if let composerCommand = composerCommand,
           let displayInfo = composerCommand.displayInfo,
           displayInfo.isInstant == true {
            return "\(composerCommand.id) \(text)"
        } else {
            return text
        }
    }
    
    public init(
        channelController: ChatChannelController,
        messageController: ChatMessageController?
    ) {
        self.channelController = channelController
        self.messageController = messageController
    }
    
    public func sendMessage(
        quotedMessage: ChatMessage?,
        editedMessage: ChatMessage?,
        completion: @escaping () -> Void
    ) {
        if let composerCommand = composerCommand {
            commandsHandler.executeOnMessageSent(
                composerCommand: composerCommand
            ) { [weak self] _ in
                self?.clearInputData()
                completion()
            }
            
            if composerCommand.replacesMessageSent {
                return
            }
        }
        
        if let editedMessage = editedMessage {
            edit(message: editedMessage, completion: completion)
            return
        }
        
        do {
            var attachments = try addedAssets.map { added in
                try AnyAttachmentPayload(
                    localFileURL: added.url,
                    attachmentType: added.type == .video ? .video : .image
                )
            }
            
            attachments += try addedFileURLs.map { url in
                _ = url.startAccessingSecurityScopedResource()
                return try AnyAttachmentPayload(localFileURL: url, attachmentType: .file)
            }
            
            attachments += addedCustomAttachments.map { attachment in
                attachment.content
            }
            
            if let messageController = messageController {
                messageController.createNewReply(
                    text: messageText,
                    attachments: attachments,
                    showReplyInChannel: showReplyInChannel,
                    quotedMessageId: quotedMessage?.id
                ) { [weak self] in
                    switch $0 {
                    case .success:
                        completion()
                    case .failure:
                        self?.errorShown = true
                    }
                }
            } else {
                channelController.createNewMessage(
                    text: messageText,
                    attachments: attachments,
                    quotedMessageId: quotedMessage?.id
                ) { [weak self] in
                    switch $0 {
                    case .success:
                        completion()
                    case .failure:
                        self?.errorShown = true
                    }
                }
            }
            
            clearInputData()
        } catch {
            errorShown = true
        }
    }
    
    public var sendButtonEnabled: Bool {
        if let composerCommand = composerCommand,
           let handler = commandsHandler.canShowSuggestions(for: composerCommand) {
            return handler
                .canBeExecuted(composerCommand: composerCommand)
        }
        
        return !addedAssets.isEmpty ||
            !text.isEmpty ||
            !addedFileURLs.isEmpty ||
            !addedCustomAttachments.isEmpty
    }
    
    public var sendInChannelShown: Bool {
        messageController != nil
    }
    
    public var isDirectChannel: Bool {
        channelController.channel?.isDirectMessageChannel ?? false
    }
    
    public func change(pickerState: AttachmentPickerState) {
        if pickerState != self.pickerState {
            self.pickerState = pickerState
        }
    }
    
    public var inputComposerShouldScroll: Bool {
        if addedCustomAttachments.count > 3 {
            return true
        }
        
        if addedFileURLs.count > 2 {
            return true
        }
        
        if addedFileURLs.count == 2 && !addedAssets.isEmpty {
            return true
        }
        
        return false
    }
    
    func imageTapped(_ addedAsset: AddedAsset) {
        var images = [AddedAsset]()
        var imageRemoved = false
        for image in addedAssets {
            if image.id != addedAsset.id {
                images.append(image)
            } else {
                imageRemoved = true
            }
        }
        
        if !imageRemoved {
            images.append(addedAsset)
        }
        
        addedAssets = images
    }
    
    func removeAttachment(with id: String) {
        if id.isURL, let url = URL(string: id) {
            var urls = [URL]()
            for added in addedFileURLs {
                if url != added {
                    urls.append(added)
                }
            }
            addedFileURLs = urls
        } else {
            var images = [AddedAsset]()
            for image in addedAssets {
                if image.id != id {
                    images.append(image)
                }
            }
            addedAssets = images
        }
    }
    
    func cameraImageAdded(_ image: AddedAsset) {
        addedAssets.append(image)
        pickerState = .photos
    }
    
    func isImageSelected(with id: String) -> Bool {
        for image in addedAssets {
            if image.id == id {
                return true
            }
        }
        
        return false
    }
    
    func customAttachmentTapped(_ attachment: CustomAttachment) {
        var temp = [CustomAttachment]()
        var attachmentRemoved = false
        for existing in addedCustomAttachments {
            if existing.id != attachment.id {
                temp.append(existing)
            } else {
                attachmentRemoved = true
            }
        }
        
        if !attachmentRemoved {
            temp.append(attachment)
        }
        
        addedCustomAttachments = temp
    }
    
    func isCustomAttachmentSelected(_ attachment: CustomAttachment) -> Bool {
        for existing in addedCustomAttachments {
            if existing.id == attachment.id {
                return true
            }
        }
        
        return false
    }
    
    func askForPhotosPermission() {
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized, .limited:
                log.debug("Access to photos granted.")
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                DispatchQueue.main.async { [unowned self] in
                    self.imageAssets = PHAsset.fetchAssets(with: fetchOptions)
                }
            case .denied, .restricted:
                log.debug("Access to photos is denied, showing the no permissions screen.")
            case .notDetermined:
                log.debug("Access to photos is still not determined.")
            @unknown default:
                log.debug("Unknown authorization status.")
            }
        }
    }
    
    func handleCommand(
        for text: Binding<String>,
        selectedRangeLocation: Binding<Int>,
        command: Binding<ComposerCommand?>,
        extraData: [String: Any]
    ) {
        commandsHandler.handleCommand(
            for: text,
            selectedRangeLocation: selectedRangeLocation,
            command: command,
            extraData: extraData
        )
    }
    
    // MARK: - private
    
    private func mentionText(for user: ChatUser) -> String {
        if let name = user.name, !name.isEmpty {
            return name
        } else {
            return user.id
        }
    }
    
    private func edit(
        message: ChatMessage,
        completion: @escaping () -> Void
    ) {
        guard let channelId = channelController.channel?.cid else {
            return
        }
        let messageController = chatClient.messageController(
            cid: channelId,
            messageId: message.id
        )
        
        messageController.editMessage(text: text) { [weak self] error in
            if error != nil {
                self?.errorShown = true
            } else {
                completion()
            }
        }
        
        clearInputData()
    }
    
    private func clearInputData() {
        text = ""
        addedAssets = []
        addedFileURLs = []
        addedCustomAttachments = []
        composerCommand = nil
    }
    
    private func checkPickerSelectionState() {
        if (!addedAssets.isEmpty || !addedFileURLs.isEmpty) {
            pickerTypeState = .collapsed
        }
    }
    
    private func checkTypingSuggestions() {
        if composerCommand?.displayInfo?.isInstant == true {
            let typingSuggestion = TypingSuggestion(
                text: text,
                locationRange: NSRange(
                    location: 0,
                    length: selectedRangeLocation
                )
            )
            composerCommand?.typingSuggestion = typingSuggestion
            showTypingSuggestions()
            return
        }
        composerCommand = commandsHandler.canHandleCommand(
            in: text,
            caretLocation: selectedRangeLocation
        )
        
        showTypingSuggestions()
    }
    
    private func showTypingSuggestions() {
        if let composerCommand = composerCommand {
            commandsHandler.showSuggestions(for: composerCommand)
                .sink { _ in
                    log.debug("Finished showing suggestions")
                } receiveValue: { [weak self] suggestionInfo in
                    withAnimation {
                        self?.suggestions[suggestionInfo.key] = suggestionInfo.value
                    }
                }
                .store(in: &cancellables)
        }
    }
}
