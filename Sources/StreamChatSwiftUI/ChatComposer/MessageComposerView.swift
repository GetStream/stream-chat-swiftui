//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Main view for the message composer.
public struct MessageComposerView<Factory: ViewFactory>: View, KeyboardReadable {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.utils) private var utils
    @Injected(\.tokens) private var tokens

    // Initial popup size, before the keyboard is shown.
    @State private var popupSize: CGFloat = 350
    @State private var composerHeight: CGFloat = 0
    @State private var keyboardShown = false
    @State private var editedMessageWillShow = false

    private var factory: Factory
    private var channelConfig: ChannelConfig?
    @Binding var quotedMessage: ChatMessage?
    @Binding var editedMessage: ChatMessage?

    private let recordingViewHeight: CGFloat = 80

    public init(
        viewFactory: Factory,
        viewModel: MessageComposerViewModel? = nil,
        channelController: ChatChannelController,
        messageController: ChatMessageController? = nil,
        quotedMessage: Binding<ChatMessage?>,
        editedMessage: Binding<ChatMessage?>,
        onMessageSent: @escaping () -> Void
    ) {
        factory = viewFactory
        channelConfig = channelController.channel?.config
        _viewModel = StateObject(
            wrappedValue: viewModel ?? ViewModelsFactory.makeMessageComposerViewModel(
                with: channelController,
                messageController: messageController,
                quotedMessage: quotedMessage
            )
        )
        _quotedMessage = quotedMessage
        _editedMessage = editedMessage
        self.onMessageSent = onMessageSent
    }

    @StateObject var viewModel: MessageComposerViewModel

    var onMessageSent: () -> Void

    public var body: some View {
        VStack(spacing: tokens.spacingSm) {
            HStack(alignment: .bottom, spacing: tokens.spacingXs) {
                factory.makeLeadingComposerView(
                    options: LeadingComposerViewOptions(
                        state: $viewModel.pickerTypeState,
                        channelConfig: channelConfig,
                        isCommandActive: viewModel.composerCommand?.displayInfo?.isInstant == true
                    )
                )

                factory.makeComposerInputView(
                    options: ComposerInputViewOptions(
                        channelController: viewModel.channelController,
                        text: $viewModel.text,
                        selectedRangeLocation: $viewModel.selectedRangeLocation,
                        command: $viewModel.composerCommand,
                        recordingState: $viewModel.recordingState,
                        composerAssets: viewModel.composerAssets,
                        addedCustomAttachments: viewModel.addedCustomAttachments,
                        addedVoiceRecordings: viewModel.addedVoiceRecordings,
                        quotedMessage: $quotedMessage,
                        editedMessage: $editedMessage,
                        maxMessageLength: channelConfig?.maxMessageLength,
                        cooldownDuration: viewModel.cooldownDuration,
                        hasContent: viewModel.hasContent,
                        canSendMessage: viewModel.canSendMessage,
                        onCustomAttachmentTap: viewModel.customAttachmentTapped(_:),
                        removeAttachmentWithId: viewModel.removeAttachment(with:),
                        sendMessage: sendMessage,
                        onImagePasted: viewModel.imagePasted,
                        startRecording: viewModel.startRecording,
                        stopRecording: viewModel.stopRecording,
                        sendInChannelShown: viewModel.sendInChannelShown,
                        showReplyInChannel: $viewModel.showReplyInChannel,
                        isDirectMessage: viewModel.isDirectChannel
                    )
                )
                .environmentObject(viewModel)
                .alert(isPresented: $viewModel.attachmentSizeExceeded) {
                    Alert(
                        title: Text(L10n.Attachment.MaxSize.title),
                        message: Text(L10n.Attachment.MaxSize.message),
                        dismissButton: .cancel(Text(L10n.Alert.Actions.ok))
                    )
                }

                factory.makeTrailingComposerView(
                    options: TrailingComposerViewOptions(
                        enabled: viewModel.hasContent,
                        cooldownDuration: viewModel.cooldownDuration,
                        onTap: sendMessage
                    )
                )
                .environmentObject(viewModel)
                .alert(isPresented: $viewModel.errorShown) {
                    Alert.defaultErrorAlert
                }
            }
            .padding(.top, tokens.spacingMd)
            .padding(.horizontal, tokens.spacingMd)
            .opacity(viewModel.recordingState.showsComposer ? 1 : 0)
            .overlay(
                ZStack {
                    if case let .recording(location) = viewModel.recordingState {
                        factory.makeComposerRecordingView(
                            options: ComposerRecordingViewOptions(
                                viewModel: viewModel,
                                gestureLocation: location
                            )
                        )
                        .frame(height: 60)
                    } else if viewModel.recordingState == .locked || viewModel.recordingState == .stopped {
                        factory.makeComposerRecordingLockedView(
                            options: ComposerRecordingLockedViewOptions(viewModel: viewModel)
                        )
                        .frame(height: recordingViewHeight)
                    } else if viewModel.recordingState == .showingTip {
                        factory.makeComposerRecordingTipView(options: ComposerRecordingTipViewOptions())
                            .offset(y: -composerHeight + 12)
                    } else {
                        EmptyView()
                    }
                }
            )
            .frame(height: viewModel.recordingState.showsComposer ? nil : recordingViewHeight)

            factory.makeAttachmentPickerView(
                options: AttachmentPickerViewOptions(
                    attachmentPickerState: $viewModel.pickerState,
                    filePickerShown: $viewModel.filePickerShown,
                    cameraPickerShown: $viewModel.cameraPickerShown,
                    onFilesPicked: viewModel.addFileURLs,
                    onPickerStateChange: viewModel.change(pickerState:),
                    photoLibraryAssets: viewModel.imageAssets,
                    onAssetTap: viewModel.imageTapped(_:),
                    onCustomAttachmentTap: viewModel.customAttachmentTapped(_:),
                    isAssetSelected: viewModel.isImageSelected(with:),
                    addedCustomAttachments: viewModel.addedCustomAttachments,
                    cameraImageAdded: viewModel.cameraImageAdded(_:),
                    askForAssetsAccessPermissions: viewModel.askForPhotosPermission,
                    isDisplayed: viewModel.overlayShown,
                    height: viewModel.overlayShown ? popupSize : 0,
                    popupHeight: popupSize,
                    selectedAssetIds: viewModel.composerAssets.compactMap {
                        if case .addedAsset(let asset) = $0 { return asset.id }
                        return nil
                    },
                    channelController: viewModel.channelController,
                    messageController: viewModel.messageController,
                    canSendPoll: viewModel.canSendPoll,
                    instantCommands: viewModel.instantCommands,
                    onCommandSelected: { command in
                        viewModel.pickerTypeState = .expanded(.none)
                        viewModel.composerCommand = command
                        viewModel.handleCommand(
                            for: $viewModel.text,
                            selectedRangeLocation: $viewModel.selectedRangeLocation,
                            command: $viewModel.composerCommand,
                            extraData: ["instantCommand": command]
                        )
                        becomeFirstResponder()
                    }
                )
            )
            .offset(y: viewModel.overlayShown ? 0 : popupSize)
            .opacity(viewModel.overlayShown ? 1 : 0)
            .animation(.easeInOut(duration: 0.25))
        }
        .background(
            GeometryReader { proxy in
                let frame = proxy.frame(in: .local)
                let height = frame.height
                Color.clear.preference(key: HeightPreferenceKey.self, value: height)
            }
        )
        .onPreferenceChange(HeightPreferenceKey.self) { value in
            if let value, value != composerHeight {
                composerHeight = value
            }
        }
        .onReceive(keyboardWillChangePublisher) { visible in
            if visible && !keyboardShown {
                if viewModel.composerCommand == nil && !editedMessageWillShow {
                    DispatchQueue.main.async {
                        var transaction = Transaction()
                        transaction.disablesAnimations = true
                        withTransaction(transaction) {
                            viewModel.pickerTypeState = .expanded(.none)
                        }
                    }
                } else if editedMessageWillShow {
                    // When editing a message, the keyboard will show.
                    // If the attachment picker is open, we should dismiss it.
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) {
                        viewModel.pickerTypeState = .expanded(.none)
                    }
                }
            }
            keyboardShown = visible
            editedMessageWillShow = false
        }
        .onReceive(keyboardHeight) { height in
            if height > 0 && height != popupSize {
                popupSize = height - bottomSafeArea
            }
        }
        
        .modifier(factory.styles.makeComposerViewModifier(options: ComposerViewModifierOptions()))
        .background(
            Group {
                if viewModel.showSuggestionsOverlay {
                    factory.makeSuggestionsContainerView(
                        options: SuggestionsContainerViewOptions(
                            suggestions: viewModel.suggestions,
                            handleCommand: { commandInfo in
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    viewModel.handleCommand(
                                        for: $viewModel.text,
                                        selectedRangeLocation: $viewModel.selectedRangeLocation,
                                        command: $viewModel.composerCommand,
                                        extraData: commandInfo
                                    )
                                }
                            }
                        )
                    )
                    .transition(.opacity.combined(with: .offset(y: 8)))
                }
            }
            .animation(.easeInOut(duration: 0.2), value: viewModel.showSuggestionsOverlay)
            .offset(y: -composerHeight),
            alignment: .bottom
        )
        .snackBar(
            text: $viewModel.snackBarText,
            bottomOffset: composerHeight + tokens.spacingMd
        )
        .onChange(of: editedMessage) { _ in
            viewModel.fillEditedMessage(editedMessage)
            if editedMessage != nil {
                becomeFirstResponder()
                editedMessageWillShow = true
            }
        }
        .onAppear(perform: {
            viewModel.fillDraftMessage()
        })
        .onDisappear(perform: {
            if editedMessage == nil {
                viewModel.updateDraftMessage(quotedMessage: quotedMessage)
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: .commandsOverlayHiddenNotification)) { _ in
            guard utils.messageListConfig.hidesCommandsOverlayOnMessageListTap else {
                return
            }
            viewModel.composerCommand = nil
        }
        .onReceive(NotificationCenter.default.publisher(for: .attachmentPickerHiddenNotification)) { _ in
            guard utils.messageListConfig.hidesAttachmentsPickersOnMessageListTap else {
                return
            }
            viewModel.pickerTypeState = .expanded(.none)
        }
        .preference(key: FloatingComposerHeightPreferenceKey.self, value: composerHeight)
        .accessibilityElement(children: .contain)
    }

    public func sendMessage() {
        // Calling onMessageSent() before erasing the edited and quoted message
        // so that onMessageSent can use them for state handling.
        onMessageSent()
        viewModel.sendMessage(
            quotedMessage: quotedMessage,
            editedMessage: editedMessage
        ) {
            quotedMessage = nil
            editedMessage = nil
        }
    }
}

/// View for the composer's input (text and media).
public struct ComposerInputView<Factory: ViewFactory>: View, KeyboardReadable {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.images) private var images
    @Injected(\.utils) private var utils
    @Injected(\.tokens) private var tokens

    var factory: Factory
    var channelController: ChatChannelController
    @Binding var text: String
    @Binding var selectedRangeLocation: Int
    @Binding var command: ComposerCommand?
    @Binding var recordingState: RecordingState
    var composerAssets: [ComposerAsset]
    var addedCustomAttachments: [CustomAttachment]
    var addedVoiceRecordings: [AddedVoiceRecording]
    var quotedMessage: Binding<ChatMessage?>
    var editedMessage: Binding<ChatMessage?>
    var maxMessageLength: Int?
    var cooldownDuration: Int
    var hasContent: Bool
    var canSendMessage: Bool
    var onCustomAttachmentTap: @MainActor (CustomAttachment) -> Void
    var removeAttachmentWithId: (String) -> Void
    var sendMessage: @MainActor () -> Void
    var onImagePasted: @MainActor (UIImage) -> Void
    var startRecording: @MainActor () -> Void
    var stopRecording: @MainActor () -> Void
    var sendInChannelShown: Bool
    @Binding var showReplyInChannel: Bool
    var isDirectMessage: Bool

    @State var textHeight: CGFloat = TextSizeConstants.defaultInputViewHeight
    @State var keyboardShown = false

    public init(
        factory: Factory,
        channelController: ChatChannelController,
        text: Binding<String>,
        selectedRangeLocation: Binding<Int>,
        command: Binding<ComposerCommand?>,
        recordingState: Binding<RecordingState>,
        composerAssets: [ComposerAsset],
        addedCustomAttachments: [CustomAttachment],
        addedVoiceRecordings: [AddedVoiceRecording],
        quotedMessage: Binding<ChatMessage?>,
        editedMessage: Binding<ChatMessage?>,
        maxMessageLength: Int? = nil,
        cooldownDuration: Int,
        hasContent: Bool,
        canSendMessage: Bool,
        onCustomAttachmentTap: @escaping @MainActor (CustomAttachment) -> Void,
        removeAttachmentWithId: @escaping (String) -> Void,
        sendMessage: @escaping @MainActor () -> Void,
        onImagePasted: @escaping @MainActor (UIImage) -> Void,
        startRecording: @escaping @MainActor () -> Void,
        stopRecording: @escaping @MainActor () -> Void,
        sendInChannelShown: Bool = false,
        showReplyInChannel: Binding<Bool> = .constant(false),
        isDirectMessage: Bool = false
    ) {
        self.factory = factory
        self.channelController = channelController
        self.addedVoiceRecordings = addedVoiceRecordings
        _text = text
        _selectedRangeLocation = selectedRangeLocation
        _command = command
        _recordingState = recordingState
        self.composerAssets = composerAssets
        self.addedCustomAttachments = addedCustomAttachments
        self.canSendMessage = canSendMessage
        self.hasContent = hasContent
        self.quotedMessage = quotedMessage
        self.editedMessage = editedMessage
        self.maxMessageLength = maxMessageLength
        self.cooldownDuration = cooldownDuration
        self.onCustomAttachmentTap = onCustomAttachmentTap
        self.removeAttachmentWithId = removeAttachmentWithId
        self.sendMessage = sendMessage
        self.onImagePasted = onImagePasted
        self.startRecording = startRecording
        self.stopRecording = stopRecording
        self.sendInChannelShown = sendInChannelShown
        _showReplyInChannel = showReplyInChannel
        self.isDirectMessage = isDirectMessage
    }

    var textFieldHeight: CGFloat {
        let minHeight: CGFloat = TextSizeConstants.minimumHeight
        let maxHeight: CGFloat = TextSizeConstants.maximumHeight

        if textHeight < minHeight {
            return minHeight
        }

        if textHeight > maxHeight {
            return maxHeight
        }

        return textHeight
    }

    public var body: some View {
        VStack(spacing: tokens.spacingXxs) {
            referenceMessageView
                .padding(.top, tokens.spacingXxs)

            attachmentsTray
                .padding(.top, tokens.spacingXxs)
                .padding(.leading, tokens.spacingXs)

            inputView
                .padding(.leading, tokens.spacingXs)
        }
        .modifier(
            factory.styles.makeComposerInputViewModifier(
                options: .init(keyboardShown: keyboardShown)
            )
        )
        .onReceive(keyboardWillChangePublisher) { visible in
            keyboardShown = visible
        }
    }

    private var inputView: some View {
        HStack(alignment: .bottom) {
            VStack(spacing: 0) {
                HStack(alignment: .bottom, spacing: tokens.spacingXxs) {
                    if let command,
                       let displayInfo = command.displayInfo,
                       displayInfo.isInstant == true {
                        CommandChipView(
                            displayName: displayInfo.displayName,
                            onDismiss: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    self.command = nil
                                }
                            }
                        )
                        .padding(.leading, tokens.spacingXxs)
                        .padding(.bottom, tokens.spacingXs)
                    }

                    factory.makeComposerTextInputView(
                        options: ComposerTextInputViewOptions(
                            text: $text,
                            height: $textHeight,
                            selectedRangeLocation: $selectedRangeLocation,
                            placeholder: placeholderText,
                            editable: !isInputDisabled,
                            maxMessageLength: maxMessageLength,
                            currentHeight: textFieldHeight,
                            onImagePasted: onImagePasted
                        )
                    )
                    .accessibilityIdentifier("ComposerTextInputView")
                    .accessibilityElement(children: .contain)
                }
                .frame(height: textFieldHeight)
                .padding(.vertical, tokens.spacingXxs)

                if sendInChannelShown {
                    factory.makeSendInChannelView(
                        options: SendInChannelViewOptions(
                            showReplyInChannel: $showReplyInChannel
                        )
                    )
                }
            }

            factory.makeComposerInputTrailingView(
                options: .init(
                    text: $text,
                    recordingState: $recordingState,
                    composerInputState: composerInputState,
                    startRecording: startRecording,
                    stopRecording: stopRecording,
                    sendMessage: sendMessage
                )
            )
            .padding(.trailing, tokens.spacingXs)
            .padding(.bottom, tokens.spacingXs)
        }
    }

    private var referenceMessageView: some View {
        Group {
            if let editedMessage = editedMessage.wrappedValue {
                factory.makeComposerEditedMessageView(
                    options: .init(
                        editedMessage: editedMessage,
                        onDismiss: {
                            withAnimation {
                                self.editedMessage.wrappedValue = nil
                            }
                        }
                    )
                )
            } else if let quotedMessage = quotedMessage.wrappedValue {
                factory.makeComposerQuotedMessageView(
                    options: .init(
                        quotedMessage: quotedMessage,
                        onDismiss: {
                            withAnimation {
                                self.quotedMessage.wrappedValue = nil
                            }
                        }
                    )
                )
            }
        }
    }

    private var attachmentsTray: some View {
        Group {
            if !composerAssets.isEmpty {
                ComposerAttachmentsContainerView(
                    assets: composerAssets,
                    onDiscardAttachment: removeAttachmentWithId
                )
                .transition(.scale)
                .animation(.default)
            }

            if !addedVoiceRecordings.isEmpty {
                AddedVoiceRecordingsView(
                    addedVoiceRecordings: addedVoiceRecordings,
                    onDiscardAttachment: removeAttachmentWithId
                )
                .padding(.trailing, 8)
                .padding(.top, 8)
            }

            if !addedCustomAttachments.isEmpty {
                factory.makeCustomAttachmentPreviewView(
                    options: CustomAttachmentPreviewViewOptions(
                        addedCustomAttachments: addedCustomAttachments,
                        onCustomAttachmentTap: onCustomAttachmentTap
                    )
                )
            }
        }
    }

    private var composerInputState: MessageComposerInputState {
        if isInCooldown {
            return .slowMode(cooldownDuration: cooldownDuration)
        }

        if editedMessage.wrappedValue != nil {
            return .editing(hasContent: hasContent)
        }

        if command?.displayInfo?.isInstant == true {
            return .creating(hasContent: hasContent)
        }

        if utils.composerConfig.isVoiceRecordingEnabled && !hasContent {
            return .allowAudioRecording
        }

        return .creating(hasContent: hasContent)
    }

    private var isInCooldown: Bool {
        cooldownDuration > 0
    }

    private var placeholderText: String {
        if isInCooldown {
            return L10n.Composer.Placeholder.slowMode(cooldownDuration)
        }

        if isChannelFrozen {
            return L10n.Composer.Placeholder.messageDisabled
        }

        if let command,
           let displayInfo = command.displayInfo,
           displayInfo.isInstant == true,
           let placeholder = displayInfo.placeholder {
            return placeholder
        }

        return L10n.Composer.Placeholder.message
    }

    private var isChannelFrozen: Bool {
        !canSendMessage
    }

    private var isInputDisabled: Bool {
        isInCooldown || isChannelFrozen
    }
}

// MARK: - Notification Names

extension Notification.Name {
    /// Notification sent when the attachments picker should be hidden.
    static let attachmentPickerHiddenNotification = Notification.Name("attachmentPickerHiddenNotification")

    /// Notification sent when the commands overlay should be hidden.
    static let commandsOverlayHiddenNotification = Notification.Name("commandsOverlayHiddenNotification")
}
