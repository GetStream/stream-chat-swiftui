//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Combine
import Photos
import StreamChat
import SwiftUI

/// View model for the `MessageComposerView`.
open class MessageComposerViewModel: ObservableObject {
    @Injected(\.chatClient) private var chatClient
    @Injected(\.utils) internal var utils

    var attachmentsConverter = MessageAttachmentsConverter()
    var composerAssets: ComposerAssets {
        ComposerAssets(
            mediaAssets: addedAssets,
            fileAssets: addedFileURLs.map { FileAddedAsset(url: $0, payload: addedRemoteFileURLs[$0]) },
            voiceAssets: addedVoiceRecordings,
            customAssets: addedCustomAttachments
        )
    }

    @Published public var pickerState: AttachmentPickerState = .photos {
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
    
    @Published public private(set) var imageAssets: PHFetchResult<PHAsset>?
    @Published public private(set) var addedAssets = [AddedAsset]() {
        didSet {
            checkPickerSelectionState()

            if shouldDeleteDraftMessage(oldValue: oldValue) {
                deleteDraftMessage()
            }
        }
    }
    
    @Published public var text = "" {
        didSet {
            if text != "" {
                checkTypingSuggestions()
                if pickerTypeState != .collapsed {
                    if composerCommand == nil && (abs(text.count - oldValue.count) < 10) {
                        withAnimation {
                            pickerTypeState = .collapsed
                        }
                    } else {
                        pickerTypeState = .collapsed
                    }
                }
                channelController.sendKeystrokeEvent()
            } else {
                if composerCommand?.displayInfo?.isInstant == false {
                    composerCommand = nil
                }
                selectedRangeLocation = 0
                suggestions = [String: Any]()
                mentionedUsers = Set<ChatUser>()

                if shouldDeleteDraftMessage(oldValue: oldValue) {
                    deleteDraftMessage()
                }
            }
        }
    }

    @Published public var selectedRangeLocation: Int = 0

    /// An helper property to store additional information of file attachments.
    private var addedRemoteFileURLs: [URL: FileAttachmentPayload] = [:]
    @Published public var addedFileURLs = [URL]() {
        didSet {
            if totalAttachmentsCount > chatClient.config.maxAttachmentCountPerMessage
                || !checkAttachmentSize(with: addedFileURLs.last) {
                addedFileURLs.removeLast()
            }
            checkPickerSelectionState()

            if shouldDeleteDraftMessage(oldValue: oldValue) {
                deleteDraftMessage()
            }
        }
    }
    
    @Published public var addedVoiceRecordings = [AddedVoiceRecording]() {
        didSet {
            checkPickerSelectionState()

            if shouldDeleteDraftMessage(oldValue: oldValue) {
                deleteDraftMessage()
            }
        }
    }

    @Published public var addedCustomAttachments = [CustomAttachment]() {
        didSet {
            checkPickerSelectionState()

            if shouldDeleteDraftMessage(oldValue: oldValue) {
                deleteDraftMessage()
            }
        }
    }
    
    @Published public var pickerTypeState: PickerTypeState = .expanded(.none) {
        didSet {
            switch pickerTypeState {
            case let .expanded(attachmentPickerType):
                overlayShown = attachmentPickerType == .media || attachmentPickerType == .custom
                if attachmentPickerType == .instantCommands {
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
    
    @Published public private(set) var overlayShown = false {
        didSet {
            if overlayShown == true {
                resignFirstResponder()
            }
        }
    }

    @Published public var composerCommand: ComposerCommand? {
        didSet {
            if oldValue?.id != composerCommand?.id &&
                composerCommand?.displayInfo?.isInstant == true {
                clearCommandText()
            }
            if oldValue != nil && composerCommand == nil {
                pickerTypeState = .expanded(.none)
            }
        }
    }

    public var draftMessage: DraftMessage? {
        if let messageController {
            return messageController.message?.draftReply
        }
        return channelController.channel?.draftMessage
    }

    @Published public var filePickerShown = false
    @Published public var cameraPickerShown = false
    @Published public var errorShown = false
    @Published public var showReplyInChannel = false
    @Published public var suggestions = [String: Any]()
    @Published public var cooldownDuration: Int = 0
    @Published public var attachmentSizeExceeded: Bool = false
    @Published public var recordingState: RecordingState = .initial {
        didSet {
            if case let .recording(location) = recordingState {
                if location.y < RecordingConstants.lockMaxDistance {
                    recordingState = .locked
                } else if location.x < RecordingConstants.cancelMaxDistance {
                    audioRecordingInfo = .initial
                    recordingState = .initial
                    stopRecording()
                }
            } else if recordingState == .showingTip {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    self?.recordingState = .initial
                }
            }
        }
    }
    
    @Published public var audioRecordingInfo = AudioRecordingInfo.initial

    public let channelController: ChatChannelController
    public var messageController: ChatMessageController?
    public let eventsController: EventsController
    public var quotedMessage: Binding<ChatMessage?>?
    public var waveformTargetSamples: Int = 100
    public internal(set) var pendingAudioRecording: AddedVoiceRecording?

    public var canSendPoll: Bool {
        channelController.channel?.config.pollsEnabled == true
            && channelController.channel?.canSendPoll == true
            && messageController == nil
    }

    internal lazy var audioRecorder: AudioRecording = {
        let audioRecorder = utils.audioRecorder
        audioRecorder.subscribe(self)
        return audioRecorder
    }()
    
    internal lazy var audioAnalysisFactory: AudioAnalysisEngine? = try? .init(
        assetPropertiesLoader: StreamAssetPropertyLoader()
    )
    
    private var timer: Timer?
    private var cooldownPeriod = 0
    private var isSlowModeDisabled: Bool {
        channelController.channel?.ownCapabilities.contains("skip-slow-mode") == true
    }
    
    private var cancellables = Set<AnyCancellable>()
    public lazy var commandsHandler = utils
        .commandsConfig
        .makeCommandsHandler(
            with: channelController
        )
    
    public var mentionedUsers = Set<ChatUser>()
    
    private var messageText: String {
        if let composerCommand = composerCommand,
           let displayInfo = composerCommand.displayInfo,
           displayInfo.isInstant == true {
            return "\(composerCommand.id) \(text)"
        } else {
            return adjustedText
        }
    }
    
    var adjustedText: String {
        utils.composerConfig.adjustMessageOnSend(text)
    }
    
    private var totalAttachmentsCount: Int {
        addedAssets.count +
            addedCustomAttachments.count +
            addedFileURLs.count
    }
    
    private var canAddAdditionalAttachments: Bool {
        totalAttachmentsCount < chatClient.config.maxAttachmentCountPerMessage
    }

    public init(
        channelController: ChatChannelController,
        messageController: ChatMessageController?,
        eventsController: EventsController? = nil,
        quotedMessage: Binding<ChatMessage?>? = nil
    ) {
        self.channelController = channelController
        self.messageController = messageController
        self.eventsController = eventsController ?? channelController.client.eventsController()
        self.quotedMessage = quotedMessage

        self.eventsController.delegate = self

        listenToCooldownUpdates()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    /// Populates the composer with the edited message.
    public func fillEditedMessage(_ editedMessage: ChatMessage?) {
        guard let message = editedMessage else {
            clearInputData()
            return
        }

        text = message.text
        mentionedUsers = message.mentionedUsers
        showReplyInChannel = message.showReplyInChannel
        selectedRangeLocation = message.text.count
        attachmentsConverter.attachmentsToAssets(message.allAttachments) { [weak self] assets in
            self?.updateComposerAssets(assets)
        }
    }

    /// Populates the draft message in the composer with the current controller's draft information.
    public func fillDraftMessage() {
        guard let draft = draftMessage else {
            return
        }

        let message = ChatMessage(draft)
        text = message.text
        mentionedUsers = message.mentionedUsers
        quotedMessage?.wrappedValue = message.quotedMessage
        showReplyInChannel = message.showReplyInChannel
        selectedRangeLocation = message.text.count
        attachmentsConverter.attachmentsToAssets(message.allAttachments) { [weak self] assets in
            self?.updateComposerAssets(assets)
        }
    }

    /// Updates the draft message locally and on the server.
    public func updateDraftMessage(
        quotedMessage: ChatMessage?,
        isSilent: Bool = false,
        extraData: [String: RawJSON] = [:]
    ) {
        guard utils.messageListConfig.draftMessagesEnabled && sendButtonEnabled else {
            return
        }
        let attachments = try? convertAddedAssetsToPayloads()
        let mentionedUserIds = mentionedUsers.map(\.id)
        let availableCommands = channelController.channel?.config.commands ?? []
        let command = availableCommands.first { composerCommand?.id == "/\($0.name)" }

        if let messageController = messageController {
            messageController.updateDraftReply(
                text: messageText,
                isSilent: isSilent,
                attachments: attachments ?? [],
                mentionedUserIds: mentionedUserIds,
                quotedMessageId: quotedMessage?.id,
                showReplyInChannel: showReplyInChannel,
                command: command,
                extraData: extraData
            )
            return
        }

        channelController.updateDraftMessage(
            text: messageText,
            isSilent: isSilent,
            attachments: attachments ?? [],
            mentionedUserIds: mentionedUserIds,
            quotedMessageId: quotedMessage?.id,
            command: command,
            extraData: extraData
        )
    }

    /// Deletes the draft message locally and on the server if it exists.
    public func deleteDraftMessage() {
        guard draftMessage != nil else {
            return
        }

        if let messageController = messageController {
            messageController.deleteDraftReply()
        } else {
            channelController.deleteDraftMessage()
        }
    }

    open func sendMessage(
        quotedMessage: ChatMessage?,
        editedMessage: ChatMessage?,
        isSilent: Bool = false,
        skipPush: Bool = false,
        skipEnrichUrl: Bool = false,
        extraData: [String: RawJSON] = [:],
        completion: @escaping () -> Void
    ) {
        defer {
            checkChannelCooldown()
        }

        if let composerCommand = composerCommand, composerCommand.id != "instantCommands" {
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
        
        clearRemovedMentions()
        let mentionedUserIds = mentionedUsers.map(\.id)
        
        if let editedMessage = editedMessage {
            edit(
                message: editedMessage,
                attachments: try? convertAddedAssetsToPayloads(),
                completion: completion
            )
            return
        }
        
        do {
            let attachments = try convertAddedAssetsToPayloads()
            if let messageController = messageController {
                messageController.createNewReply(
                    text: messageText,
                    attachments: attachments,
                    mentionedUserIds: mentionedUserIds,
                    showReplyInChannel: showReplyInChannel,
                    isSilent: isSilent,
                    quotedMessageId: quotedMessage?.id,
                    skipPush: skipPush,
                    skipEnrichUrl: skipEnrichUrl,
                    extraData: extraData
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
                    isSilent: isSilent,
                    attachments: attachments,
                    mentionedUserIds: mentionedUserIds,
                    quotedMessageId: quotedMessage?.id,
                    skipPush: skipPush,
                    skipEnrichUrl: skipEnrichUrl,
                    extraData: extraData
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
    
    /// A Boolean value indicating whether sending message is enabled.
    public var isSendMessageEnabled: Bool {
        channelController.channel?.canSendMessage ?? true
    }

    public var sendButtonEnabled: Bool {
        if let composerCommand = composerCommand,
           let handler = commandsHandler.commandHandler(for: composerCommand) {
            return handler
                .canBeExecuted(composerCommand: composerCommand)
        }
        
        return !addedAssets.isEmpty ||
            !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !addedFileURLs.isEmpty ||
            !addedCustomAttachments.isEmpty ||
            !addedVoiceRecordings.isEmpty
    }
    
    public var sendInChannelShown: Bool {
        messageController != nil
    }
    
    public var isDirectChannel: Bool {
        channelController.channel?.isDirectMessageChannel ?? false
    }
    
    public var showCommandsOverlay: Bool {
        // Mentions are really not commands, but at the moment this flag controls
        // if the mentions are displayed or not, so if the command is related to mentions
        // then we need to ignore if commands are available or not.
        let isMentionsSuggestions = composerCommand?.id == "mentions"
        if isMentionsSuggestions {
            return true
        }
        let commandAvailable = composerCommand != nil
        let configuredCommandsAvailable = channelController.channel?.config.commands.count ?? 0 > 0
        return commandAvailable && configuredCommandsAvailable
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
        
        if addedVoiceRecordings.count > 2 {
            return true
        }
        
        return false
    }
    
    public func imageTapped(_ addedAsset: AddedAsset) {
        var images = [AddedAsset]()
        var imageRemoved = false
        for image in addedAssets {
            if image.id != addedAsset.id {
                images.append(image)
            } else {
                imageRemoved = true
            }
        }
        
        if !imageRemoved && canAddAttachment(with: addedAsset.url) {
            images.append(addedAsset)
        }
        
        addedAssets = images
    }
    
    public func imagePasted(_ image: UIImage) {
        guard let imageURL = try? image.saveAsJpgToTemporaryUrl() else {
            log.error("Failed to write image to local temporary file")
            return
        }
        let addedImage = AddedAsset(
            image: image,
            id: UUID().uuidString,
            url: imageURL,
            type: .image
        )
        addedAssets.append(addedImage)
    }
    
    public func removeAttachment(with id: String) {
        if id.isURL, let url = URL(string: id) {
            var urls = [URL]()
            for added in addedFileURLs {
                if url != added {
                    urls.append(added)
                }
            }
            if addedFileURLs.count == urls.count {
                var addedRecordings = [AddedVoiceRecording]()
                for added in addedVoiceRecordings {
                    if added.url != url {
                        addedRecordings.append(added)
                    }
                }
                addedVoiceRecordings = addedRecordings
            } else {
                addedFileURLs = urls
            }
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
    
    public func cameraImageAdded(_ image: AddedAsset) {
        if canAddAttachment(with: image.url) {
            addedAssets.append(image)
        }
        pickerState = .photos
    }
    
    public func isImageSelected(with id: String) -> Bool {
        for image in addedAssets {
            if image.id == id {
                return true
            }
        }
        
        return false
    }
    
    public func customAttachmentTapped(_ attachment: CustomAttachment) {
        var temp = [CustomAttachment]()
        var attachmentRemoved = false
        for existing in addedCustomAttachments {
            if existing.id != attachment.id {
                temp.append(existing)
            } else {
                attachmentRemoved = true
            }
        }
        
        if !attachmentRemoved && canAddAdditionalAttachments {
            temp.append(attachment)
        }
        
        addedCustomAttachments = temp
    }
    
    public func isCustomAttachmentSelected(_ attachment: CustomAttachment) -> Bool {
        for existing in addedCustomAttachments {
            if existing.id == attachment.id {
                return true
            }
        }
        
        return false
    }
    
    public func askForPhotosPermission() {
        PHPhotoLibrary.requestAuthorization { [weak self] (status) in
            guard let self else { return }
            switch status {
            case .authorized, .limited:
                log.debug("Access to photos granted.")
                self.fetchAssets()
            case .denied, .restricted, .notDetermined:
                DispatchQueue.main.async { [weak self] in
                    self?.imageAssets = PHFetchResult<PHAsset>()
                }
                log.debug("Access to photos is denied or not determined, showing the no permissions screen.")
            @unknown default:
                log.debug("Unknown authorization status.")
            }
        }
    }
    
    public func handleCommand(
        for text: Binding<String>,
        selectedRangeLocation: Binding<Int>,
        command: Binding<ComposerCommand?>,
        extraData: [String: Any]
    ) {
        let commandId = command.wrappedValue?.id
        commandsHandler.handleCommand(
            for: text,
            selectedRangeLocation: selectedRangeLocation,
            command: command,
            extraData: extraData
        )
        checkForMentionedUsers(
            commandId: commandId,
            extraData: extraData
        )
    }

    /// Converts all added assets to payloads.
    open func convertAddedAssetsToPayloads() throws -> [AnyAttachmentPayload] {
        try attachmentsConverter.assetsToPayloads(composerAssets)
    }

    // MARK: - private

    private func updateComposerAssets(_ assets: ComposerAssets) {
        addedAssets = assets.mediaAssets
        addedFileURLs = assets.fileAssets.map(\.url)
        addedRemoteFileURLs = assets.fileAssets.reduce(into: [:]) { result, asset in
            result[asset.url] = asset.payload
        }
        addedVoiceRecordings = assets.voiceAssets
        addedCustomAttachments = assets.customAssets
    }

    /// Checks if the previous value of the content in the composer was not empty and the current value is empty.
    private func shouldDeleteDraftMessage(oldValue: any Collection) -> Bool {
        !oldValue.isEmpty && !sendButtonEnabled
    }

    private func fetchAssets() {
        let fetchOptions = PHFetchOptions()
        let supportedTypes = utils.composerConfig.gallerySupportedTypes
        var predicate: NSPredicate?
        if supportedTypes == .images {
            predicate = NSPredicate(format: "mediaType = \(PHAssetMediaType.image.rawValue)")
        } else if supportedTypes == .videos {
            predicate = NSPredicate(format: "mediaType = \(PHAssetMediaType.video.rawValue)")
        }
        if let predicate {
            fetchOptions.predicate = predicate
        }
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let assets = PHAsset.fetchAssets(with: fetchOptions)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            self?.imageAssets = assets
        }
    }

    public func checkForMentionedUsers(
        commandId: String?,
        extraData: [String: Any]
    ) {
        guard commandId == "mentions",
              let user = extraData["chatUser"] as? ChatUser else {
            return
        }
        mentionedUsers.insert(user)
    }
    
    public func clearRemovedMentions() {
        for user in mentionedUsers {
            if !text.contains("@\(user.mentionText)") {
                mentionedUsers.remove(user)
            }
        }
    }
    
    private func edit(
        message: ChatMessage,
        attachments: [AnyAttachmentPayload]?,
        completion: @escaping () -> Void
    ) {
        guard let channelId = channelController.channel?.cid else {
            return
        }
        let messageController = chatClient.messageController(
            cid: channelId,
            messageId: message.id
        )

        var newAttachments = attachments ?? []
        let fallbackAttachments = utils.composerConfig.attachmentPayloadConverter(message)
        if !fallbackAttachments.isEmpty {
            newAttachments = fallbackAttachments
        }

        messageController.editMessage(
            text: adjustedText,
            attachments: newAttachments
        ) { [weak self] error in
            if error != nil {
                self?.errorShown = true
            } else {
                completion()
            }
        }
        
        clearInputData()
    }
    
    public func clearInputData() {
        addedAssets = []
        addedFileURLs = []
        addedVoiceRecordings = []
        addedCustomAttachments = []
        composerCommand = nil
        mentionedUsers = Set<ChatUser>()
        clearText()
    }
    
    private func checkPickerSelectionState() {
        if !addedAssets.isEmpty || !addedFileURLs.isEmpty {
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
    
    private func listenToCooldownUpdates() {
        channelController.channelChangePublisher.sink { [weak self] _ in
            guard self?.isSlowModeDisabled == false else { return }
            let cooldownDuration = self?.channelController.channel?.cooldownDuration ?? 0
            if self?.cooldownPeriod == cooldownDuration {
                return
            }
            self?.cooldownPeriod = cooldownDuration
            self?.checkChannelCooldown()
        }
        .store(in: &cancellables)
    }

    public func checkChannelCooldown() {
        let duration = channelController.channel?.cooldownDuration ?? 0
        if duration > 0 && timer == nil && !isSlowModeDisabled {
            cooldownDuration = duration
            timer = Timer.scheduledTimer(
                withTimeInterval: 1,
                repeats: true,
                block: { [weak self] _ in
                    self?.cooldownDuration -= 1
                    if self?.cooldownDuration == 0 {
                        self?.timer?.invalidate()
                        self?.timer = nil
                    }
                }
            )
            timer?.fire()
        }
    }
    
    private func clearText() {
        // This is needed because of autocompleting text from the keyboard.
        // The update of the text is done in the next cycle, so it overrides
        // the setting of this value to empty string.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.text = ""
        }
    }

    /// Same as clearText() but it just clears the command id.
    private func clearCommandText() {
        guard composerCommand != nil else { return }
        let currentText = text
        if let value = getValueOfCommand(currentText) {
            text = value
            return
        }
        text = ""
    }

    private func getValueOfCommand(_ currentText: String) -> String? {
        let pattern = "/\\S+\\s+(.*)"
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let range = NSRange(currentText.startIndex..<currentText.endIndex, in: currentText)

            if let match = regex.firstMatch(in: currentText, range: range) {
                let valueRange = match.range(at: 1)

                if let range = Range(valueRange, in: currentText) {
                    return String(currentText[range])
                }
            }
        }
        return nil
    }

    private func canAddAttachment(with url: URL) -> Bool {
        if !canAddAdditionalAttachments {
            return false
        }
        
        return checkAttachmentSize(with: url)
    }
    
    private func checkAttachmentSize(with url: URL?) -> Bool {
        guard let url = url else { return true }
        
        _ = url.startAccessingSecurityScopedResource()
        
        do {
            let fileSize = try AttachmentFile(url: url).size
            let canAdd = fileSize < chatClient.maxAttachmentSize(for: url)
            attachmentSizeExceeded = !canAdd
            return canAdd
        } catch {
            // If for some reason we can't access the file size, we delegate
            // the decision to the server.
            return true
        }
    }
    
    @objc
    private func applicationWillEnterForeground() {
        if (imageAssets?.count ?? 0) > 0 {
            fetchAssets()
        }
    }
}

extension MessageComposerViewModel: EventsControllerDelegate {
    public func eventsController(_ controller: EventsController, didReceiveEvent event: any Event) {
        if let event = event as? DraftUpdatedEvent {
            let isFromSameThread = messageController?.messageId == event.draftMessage.threadId
            let isFromSameChannel = channelController.cid == event.cid && messageController == nil
            if isFromSameThread || isFromSameChannel {
                fillDraftMessage()
            }
        }
    }
}

// The assets added to the composer.
struct ComposerAssets {
    // Image and Video Assets.
    var mediaAssets: [AddedAsset] = []
    // File Assets.
    var fileAssets: [FileAddedAsset] = []
    // Voice Assets.
    var voiceAssets: [AddedVoiceRecording] = []
    // Custom Assets.
    var customAssets: [CustomAttachment] = []
}

// A asset containing file information.
// If it has a payload, it means that the file is already uploaded to the server.
struct FileAddedAsset {
    var url: URL
    var payload: FileAttachmentPayload?
}

// The converter responsible to map attachments to assets and vice versa.
class MessageAttachmentsConverter {
    @Injected(\.utils) var utils

    /// Converts the added assets to payloads.
    func assetsToPayloads(_ assets: ComposerAssets) throws -> [AnyAttachmentPayload] {
        let mediaAssets = assets.mediaAssets
        let fileAssets = assets.fileAssets
        let voiceAssets = assets.voiceAssets
        let customAssets = assets.customAssets

        var attachments = try mediaAssets.map { try $0.toAttachmentPayload() }
        attachments += try fileAssets.map { file in
            _ = file.url.startAccessingSecurityScopedResource()
            if let filePayload = file.payload {
                return AnyAttachmentPayload(payload: filePayload)
            }
            return try AnyAttachmentPayload(localFileURL: file.url, attachmentType: .file)
        }
        attachments += try voiceAssets.map { recording in
            _ = recording.url.startAccessingSecurityScopedResource()
            var localMetadata = AnyAttachmentLocalMetadata()
            localMetadata.duration = recording.duration
            localMetadata.waveformData = recording.waveform
            return try AnyAttachmentPayload(
                localFileURL: recording.url,
                attachmentType: .voiceRecording,
                localMetadata: localMetadata
            )
        }

        attachments += customAssets.map { attachment in
            attachment.content
        }
        return attachments
    }

    /// Converts the attachments to assets asynchronously.
    func attachmentsToAssets(
        _ attachments: [AnyChatMessageAttachment],
        completion: @escaping (ComposerAssets) -> Void
    ) {
        let group = DispatchGroup()
        attachmentsToAssets(attachments, with: group, completion: completion)
    }

    /// Converts the attachments to assets asynchronously or synchronously,
    /// depending if a DispatchGroup is provided or not.
    ///
    /// For the most part, a DispatchGroup should always be used.
    /// The synchronously version is mostly used for testing at the moment.
    func attachmentsToAssets(
        _ attachments: [AnyChatMessageAttachment],
        with group: DispatchGroup?,
        completion: @escaping (ComposerAssets) -> Void
    ) {
        var addedAssets = ComposerAssets()

        attachments.forEach { attachment in
            group?.enter()

            switch attachment.type {
            case .image:
                imageAttachmentToAddedAsset(attachment) { asset in
                    guard let addedAsset = asset else {
                        group?.leave()
                        return
                    }
                    addedAssets.mediaAssets.append(addedAsset)
                    group?.leave()
                }
            case .video:
                guard let asset = videoAttachmentToAddedAsset(attachment) else { break }
                addedAssets.mediaAssets.append(asset)
                group?.leave()
            case .file:
                guard let fileAsset = fileAttachmentToAddedAsset(attachment) else { break }
                addedAssets.fileAssets.append(fileAsset)
                group?.leave()
            case .voiceRecording:
                guard let addedVoiceRecording = attachment.toAddedVoiceRecording() else { break }
                addedAssets.voiceAssets.append(addedVoiceRecording)
                group?.leave()
            case .linkPreview, .audio, .giphy, .unknown:
                break
            default:
                guard let customAttachment = customAttachmentToAddedAsset(attachment) else { break }
                addedAssets.customAssets.append(customAttachment)
                group?.leave()
            }
        }

        if let group {
            group.notify(queue: .main) {
                completion(addedAssets)
            }
        } else {
            completion(addedAssets)
        }
    }

    private func fileAttachmentToAddedAsset(
        _ attachment: AnyChatMessageAttachment
    ) -> FileAddedAsset? {
        guard let filePayload = attachment.attachment(payloadType: FileAttachmentPayload.self) else {
            return nil
        }
        if let localUrl = attachment.uploadingState?.localFileURL {
            return FileAddedAsset(url: localUrl)
        }
        return FileAddedAsset(
            url: filePayload.assetURL,
            payload: filePayload.payload
        )
    }

    private func videoAttachmentToAddedAsset(
        _ attachment: AnyChatMessageAttachment
    ) -> AddedAsset? {
        guard let videoAttachment = attachment.attachment(payloadType: VideoAttachmentPayload.self) else {
            return nil
        }
        guard let thumbnail = attachment.imageThumbnail(for: videoAttachment.payload) else {
            return nil
        }

        if let localUrl = attachment.uploadingState?.localFileURL {
            return AddedAsset(
                image: thumbnail,
                id: videoAttachment.id.rawValue,
                url: localUrl,
                type: .video,
                extraData: videoAttachment.extraData ?? [:]
            )
        }

        return AddedAsset(
            image: thumbnail,
            id: videoAttachment.id.rawValue,
            url: videoAttachment.videoURL,
            type: .video,
            extraData: videoAttachment.extraData ?? [:],
            payload: videoAttachment.payload
        )
    }

    private func imageAttachmentToAddedAsset(
        _ attachment: AnyChatMessageAttachment,
        completion: @escaping (AddedAsset?) -> Void
    ) {
        guard let imageAttachment = attachment.attachment(payloadType: ImageAttachmentPayload.self) else {
            return completion(nil)
        }

        if let localFileUrl = attachment.uploadingState?.localFileURL,
           let imageData = try? Data(contentsOf: localFileUrl),
           let image = UIImage(data: imageData) {
            let imageAsset = AddedAsset(
                image: image,
                id: imageAttachment.id.rawValue,
                url: localFileUrl,
                type: .image,
                extraData: imageAttachment.extraData ?? [:]
            )
            completion(imageAsset)
            return
        }

        utils.imageLoader.loadImage(
            url: imageAttachment.imageURL,
            imageCDN: utils.imageCDN,
            resize: false,
            preferredSize: nil
        ) { result in
            if let image = try? result.get() {
                let imageAsset = AddedAsset(
                    image: image,
                    id: imageAttachment.id.rawValue,
                    url: imageAttachment.imageURL,
                    type: .image,
                    extraData: imageAttachment.extraData ?? [:],
                    payload: imageAttachment.payload
                )
                completion(imageAsset)
                return
            }
            completion(nil)
        }
    }

    private func customAttachmentToAddedAsset(
        _ attachment: AnyChatMessageAttachment
    ) -> CustomAttachment? {
        guard let anyAttachmentPayload = [attachment].toAnyAttachmentPayload().first else {
            return nil
        }
        return CustomAttachment(
            id: attachment.id.rawValue,
            content: anyAttachmentPayload
        )
    }
}
