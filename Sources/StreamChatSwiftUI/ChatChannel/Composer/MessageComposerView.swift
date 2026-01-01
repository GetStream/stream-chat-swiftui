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
        VStack(spacing: 0) {
            if quotedMessage != nil {
                factory.makeQuotedMessageHeaderView(
                    quotedMessage: $quotedMessage
                )
                .transition(.identity)
            } else if editedMessage != nil {
                factory.makeEditedMessageHeaderView(
                    editedMessage: $editedMessage
                )
                .transition(.identity)
            }

            HStack(alignment: .bottom) {
                factory.makeLeadingComposerView(
                    state: $viewModel.pickerTypeState,
                    channelConfig: channelConfig
                )
                .environmentObject(viewModel)

                factory.makeComposerInputView(
                    text: $viewModel.text,
                    selectedRangeLocation: $viewModel.selectedRangeLocation,
                    command: $viewModel.composerCommand,
                    addedAssets: viewModel.addedAssets,
                    addedFileURLs: viewModel.addedFileURLs,
                    addedCustomAttachments: viewModel.addedCustomAttachments,
                    quotedMessage: $quotedMessage,
                    maxMessageLength: channelConfig?.maxMessageLength,
                    cooldownDuration: viewModel.cooldownDuration,
                    onCustomAttachmentTap: viewModel.customAttachmentTapped(_:),
                    shouldScroll: viewModel.inputComposerShouldScroll,
                    removeAttachmentWithId: viewModel.removeAttachment(with:)
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
                    enabled: viewModel.sendButtonEnabled,
                    cooldownDuration: viewModel.cooldownDuration
                ) {
                    viewModel.sendMessage(
                        quotedMessage: quotedMessage,
                        editedMessage: editedMessage
                    ) {
                        // Calling onMessageSent() before erasing the edited and quoted message
                        // so that onMessageSent can use them for state handling.
                        onMessageSent()
                        quotedMessage = nil
                        editedMessage = nil
                    }
                }
                .environmentObject(viewModel)
                .alert(isPresented: $viewModel.errorShown) {
                    Alert.defaultErrorAlert
                }
            }
            .padding(.all, 8)
            .opacity(viewModel.recordingState.showsComposer ? 1 : 0)
            .overlay(
                ZStack {
                    if case let .recording(location) = viewModel.recordingState {
                        factory.makeComposerRecordingView(
                            viewModel: viewModel,
                            gestureLocation: location
                        )
                        .frame(height: 60)
                    } else if viewModel.recordingState == .locked || viewModel.recordingState == .stopped {
                        factory.makeComposerRecordingLockedView(viewModel: viewModel)
                            .frame(height: recordingViewHeight)
                    } else if viewModel.recordingState == .showingTip {
                        factory.makeComposerRecordingTipView()
                            .offset(y: -composerHeight + 12)
                    } else {
                        EmptyView()
                    }
                }
            )
            .frame(height: viewModel.recordingState.showsComposer ? nil : recordingViewHeight)

            if viewModel.sendInChannelShown {
                factory.makeSendInChannelView(
                    showReplyInChannel: $viewModel.showReplyInChannel,
                    isDirectMessage: viewModel.isDirectChannel
                )
            }

            factory.makeAttachmentPickerView(
                attachmentPickerState: $viewModel.pickerState,
                filePickerShown: $viewModel.filePickerShown,
                cameraPickerShown: $viewModel.cameraPickerShown,
                addedFileURLs: $viewModel.addedFileURLs,
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
                popupHeight: popupSize
            )
            .environmentObject(viewModel)
        }
        .background(
            GeometryReader { proxy in
                let frame = proxy.frame(in: .local)
                let height = frame.height
                Color.clear.preference(key: HeightPreferenceKey.self, value: height)
            }
        )
        .onPreferenceChange(HeightPreferenceKey.self) { value in
            if let value = value, value != composerHeight {
                self.composerHeight = value
            }
        }
        .onReceive(keyboardWillChangePublisher) { visible in
            if visible && !keyboardShown {
                if viewModel.composerCommand == nil && !editedMessageWillShow {
                    withAnimation(.easeInOut(duration: 0.02)) {
                        viewModel.pickerTypeState = .expanded(.none)
                    }
                } else if editedMessageWillShow {
                    // When editing a message, the keyboard will show.
                    // If the attachment picker is open, we should dismiss it.
                    viewModel.pickerTypeState = .expanded(.none)
                }
            }
            keyboardShown = visible
            editedMessageWillShow = false
        }
        .onReceive(keyboardHeight) { height in
            if height > 0 && height != popupSize {
                self.popupSize = height - bottomSafeArea
            }
        }
        .overlay(
            viewModel.showCommandsOverlay ?
                factory.makeCommandsContainerView(
                    suggestions: viewModel.suggestions,
                    handleCommand: { commandInfo in
                        viewModel.handleCommand(
                            for: $viewModel.text,
                            selectedRangeLocation: $viewModel.selectedRangeLocation,
                            command: $viewModel.composerCommand,
                            extraData: commandInfo
                        )
                    }
                )
                .offset(y: -composerHeight)
                .animation(nil) : nil,
            alignment: .bottom
        )
        .modifier(factory.makeComposerViewModifier())
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
        .accessibilityElement(children: .contain)
    }
}

/// View for the composer's input (text and media).
public struct ComposerInputView<Factory: ViewFactory>: View, KeyboardReadable {
    @EnvironmentObject var viewModel: MessageComposerViewModel
    
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.images) private var images
    @Injected(\.utils) private var utils

    var factory: Factory
    @Binding var text: String
    @Binding var selectedRangeLocation: Int
    @Binding var command: ComposerCommand?
    var addedAssets: [AddedAsset]
    var addedFileURLs: [URL]
    var addedCustomAttachments: [CustomAttachment]
    var quotedMessage: Binding<ChatMessage?>
    var maxMessageLength: Int?
    var cooldownDuration: Int
    var onCustomAttachmentTap: (CustomAttachment) -> Void
    var removeAttachmentWithId: (String) -> Void

    @State var textHeight: CGFloat = TextSizeConstants.minimumHeight
    @State var keyboardShown = false

    public init(
        factory: Factory,
        text: Binding<String>,
        selectedRangeLocation: Binding<Int>,
        command: Binding<ComposerCommand?>,
        addedAssets: [AddedAsset],
        addedFileURLs: [URL],
        addedCustomAttachments: [CustomAttachment],
        quotedMessage: Binding<ChatMessage?>,
        maxMessageLength: Int? = nil,
        cooldownDuration: Int,
        onCustomAttachmentTap: @escaping (CustomAttachment) -> Void,
        removeAttachmentWithId: @escaping (String) -> Void
    ) {
        self.factory = factory
        _text = text
        _selectedRangeLocation = selectedRangeLocation
        _command = command
        self.addedAssets = addedAssets
        self.addedFileURLs = addedFileURLs
        self.addedCustomAttachments = addedCustomAttachments
        self.quotedMessage = quotedMessage
        self.maxMessageLength = maxMessageLength
        self.cooldownDuration = cooldownDuration
        self.onCustomAttachmentTap = onCustomAttachmentTap
        self.removeAttachmentWithId = removeAttachmentWithId
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
    
    var inputPaddingsConfig: PaddingsConfig {
        utils.composerConfig.inputPaddingsConfig
    }

    public var body: some View {
        VStack {
            if let quotedMessage = quotedMessage.wrappedValue {
                factory.makeQuotedMessageView(
                    quotedMessage: quotedMessage,
                    fillAvailableSpace: true,
                    isInComposer: true,
                    scrolledId: .constant(nil)
                )
                .environment(\.channelTranslationLanguage, viewModel.channelController.channel?.membership?.language)
            }

            if !addedAssets.isEmpty {
                AddedImageAttachmentsView(
                    images: addedAssets,
                    onDiscardAttachment: removeAttachmentWithId
                )
                .transition(.scale)
                .animation(.default)
            }

            if !addedFileURLs.isEmpty {
                if !addedAssets.isEmpty {
                    Divider()
                }

                AddedFileAttachmentsView(
                    addedFileURLs: addedFileURLs,
                    onDiscardAttachment: removeAttachmentWithId
                )
                .padding(.trailing, 8)
            }
            
            if !viewModel.addedVoiceRecordings.isEmpty {
                AddedVoiceRecordingsView(
                    addedVoiceRecordings: viewModel.addedVoiceRecordings,
                    onDiscardAttachment: removeAttachmentWithId
                )
                .padding(.trailing, 8)
                .padding(.top, 8)
            }

            if !addedCustomAttachments.isEmpty {
                factory.makeCustomAttachmentPreviewView(
                    addedCustomAttachments: addedCustomAttachments,
                    onCustomAttachmentTap: onCustomAttachmentTap
                )
            }

            HStack {
                if let command = command,
                   let displayInfo = command.displayInfo,
                   displayInfo.isInstant == true {
                    HStack(spacing: 0) {
                        Image(uiImage: images.smallBolt)
                            .renderingMode(.template)
                            .foregroundColor(Color(colors.staticColorText))
                        Text(displayInfo.displayName.uppercased())
                    }
                    .padding(.horizontal, 8)
                    .font(fonts.footnoteBold)
                    .frame(height: 24)
                    .background(colors.tintColor)
                    .foregroundColor(Color(colors.staticColorText))
                    .cornerRadius(16)
                }

                factory.makeComposerTextInputView(
                    text: $text,
                    height: $textHeight,
                    selectedRangeLocation: $selectedRangeLocation,
                    placeholder: isInCooldown ? L10n.Composer.Placeholder.slowMode : (isChannelFrozen ? L10n.Composer.Placeholder.messageDisabled : L10n.Composer.Placeholder.message),
                    editable: !isInputDisabled,
                    maxMessageLength: maxMessageLength,
                    currentHeight: textFieldHeight
                )
                .environmentObject(viewModel)
                .accessibilityIdentifier("ComposerTextInputView")
                .accessibilityElement(children: .contain)
                .frame(height: textFieldHeight)
                .overlay(
                    command?.displayInfo?.isInstant == true ?
                        HStack {
                            Spacer()
                            Button {
                                self.command = nil
                            } label: {
                                DiscardButtonView(
                                    color: Color(colors.background7)
                                )
                            }
                        }
                        : nil
                )
            }
            .frame(height: textFieldHeight)
        }
        .padding(.vertical, shouldAddVerticalPadding ? inputPaddingsConfig.vertical : 0)
        .padding(.leading, inputPaddingsConfig.leading)
        .padding(.trailing, inputPaddingsConfig.trailing)
        .background(composerInputBackground)
        .overlay(
            RoundedRectangle(cornerRadius: TextSizeConstants.cornerRadius)
                .stroke(Color(keyboardShown ? highlightedBorder : colors.innerBorder))
        )
        .clipShape(
            RoundedRectangle(cornerRadius: TextSizeConstants.cornerRadius)
        )
        .onReceive(keyboardWillChangePublisher) { visible in
            keyboardShown = visible
        }
        .accessibilityIdentifier("ComposerInputView")
    }

    private var composerInputBackground: Color {
        var colors = colors
        return Color(colors.composerInputBackground)
    }
    
    private var highlightedBorder: UIColor {
        var colors = colors
        return colors.composerInputHighlightedBorder
    }

    private var shouldAddVerticalPadding: Bool {
        !addedFileURLs.isEmpty || !addedAssets.isEmpty
    }

    private var isInCooldown: Bool {
        cooldownDuration > 0
    }

    private var isChannelFrozen: Bool {
        !viewModel.isSendMessageEnabled
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
