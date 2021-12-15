//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Photos
import StreamChat
import SwiftUI

/// View model for the `MessageComposerView`.
public class MessageComposerViewModel: ObservableObject {
    @Injected(\.chatClient) private var chatClient
    
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
            }
        }
    }
    
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
                overlayShown = attachmentPickerType != .none
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
    
    @Published var filePickerShown = false
    @Published var cameraPickerShown = false
    @Published var errorShown = false
    @Published var showReplyInChannel = false
    
    private let channelController: ChatChannelController
    private var messageController: ChatMessageController?
    
    public init(
        channelController: ChatChannelController,
        messageController: ChatMessageController?
    ) {
        self.channelController = channelController
        self.messageController = messageController
    }
    
    public func sendMessage(
        quotedMessage: ChatMessage?,
        completion: @escaping () -> Void
    ) {
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
                    text: text,
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
                    text: text,
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
            
            text = ""
            addedAssets = []
            addedFileURLs = []
            addedCustomAttachments = []
        } catch {
            errorShown = true
        }
    }
    
    public var sendButtonEnabled: Bool {
        !addedAssets.isEmpty ||
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
        if isURL(string: id), let url = URL(string: id) {
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
    
    // MARK: - private
    
    private func checkPickerSelectionState() {
        if (!addedAssets.isEmpty || !addedFileURLs.isEmpty) {
            pickerTypeState = .collapsed
        }
    }
    
    private func isURL(string: String) -> Bool {
        let types: NSTextCheckingResult.CheckingType = [.link]
        let detector = try? NSDataDetector(types: types.rawValue)
        
        guard (detector != nil && !string.isEmpty) else {
            return false
        }
        
        if detector!.numberOfMatches(
            in: string,
            options: NSRegularExpression.MatchingOptions(rawValue: 0),
            range: NSMakeRange(0, string.count)
        ) > 0 {
            return true
        }
        
        return false
    }
}

/// Enum describing the attachment picker's state.
public enum AttachmentPickerState {
    case files
    case photos
    case camera
    case custom
}

/// Struct representing an asset added to the composer.
public struct AddedAsset: Identifiable {
    public let image: UIImage
    public let id: String
    public let url: URL
    public let type: AssetType
    public var extraData: [String: Any] = [:]
}

/// Type of asset added to the composer.
public enum AssetType {
    case image
    case video
}

public struct CustomAttachment: Identifiable, Equatable {
    
    public static func == (lhs: CustomAttachment, rhs: CustomAttachment) -> Bool {
        lhs.id == rhs.id
    }
    
    public let id: String
    public let content: AnyAttachmentPayload
    
    public init(id: String, content: AnyAttachmentPayload) {
        self.id = id
        self.content = content
    }
}
