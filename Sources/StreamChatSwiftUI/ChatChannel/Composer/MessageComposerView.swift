//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Main view for the message composer.
public struct MessageComposerView<Factory: ViewFactory>: View, KeyboardReadable {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    
    // Initial popup size, before the keyboard is shown.
    @State private var popupSize: CGFloat = 350
    @State private var composerHeight: CGFloat = 0
    @State private var keyboardShown = false
    
    private var factory: Factory
    private var channelConfig: ChannelConfig?
    @Binding var quotedMessage: ChatMessage?
    @Binding var editedMessage: ChatMessage?
    
    public init(
        viewFactory: Factory,
        viewModel: MessageComposerViewModel? = nil,
        channelController: ChatChannelController,
        messageController: ChatMessageController?,
        quotedMessage: Binding<ChatMessage?>,
        editedMessage: Binding<ChatMessage?>,
        onMessageSent: @escaping () -> Void
    ) {
        factory = viewFactory
        channelConfig = channelController.channel?.config
        _viewModel = StateObject(
            wrappedValue: viewModel ?? ViewModelsFactory.makeMessageComposerViewModel(
                with: channelController,
                messageController: messageController
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
                                
                factory.makeTrailingComposerView(
                    enabled: viewModel.sendButtonEnabled,
                    cooldownDuration: viewModel.cooldownDuration
                ) {
                    viewModel.sendMessage(
                        quotedMessage: quotedMessage,
                        editedMessage: editedMessage
                    ) {
                        quotedMessage = nil
                        editedMessage = nil
                        onMessageSent()
                    }
                }
            }
            .padding(.all, 8)
            
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
                if viewModel.composerCommand == nil {
                    withAnimation(.easeInOut(duration: 0.02)) {
                        viewModel.pickerTypeState = .expanded(.none)
                    }
                }
            }
            keyboardShown = visible
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
        .alert(isPresented: $viewModel.errorShown) {
            Alert.defaultErrorAlert
        }
        .onChange(of: editedMessage) { _ in
            viewModel.text = editedMessage?.text ?? ""
        }
    }
}

/// View for the composer's input (text and media).
public struct ComposerInputView<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.images) private var images
    
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
        VStack {
            if let quotedMessage = quotedMessage.wrappedValue {
                factory.makeQuotedMessageView(
                    quotedMessage: quotedMessage,
                    fillAvailableSpace: true,
                    isInComposer: true,
                    scrolledId: .constant(nil)
                )
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
                        Text(displayInfo.displayName.uppercased())
                    }
                    .padding(.horizontal, 8)
                    .font(fonts.footnoteBold)
                    .frame(height: 24)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
                
                ComposerTextInputView(
                    text: $text,
                    height: $textHeight,
                    selectedRangeLocation: $selectedRangeLocation,
                    placeholder: isInCooldown ? L10n.Composer.Placeholder.slowMode : L10n.Composer.Placeholder.message,
                    editable: !isInCooldown,
                    maxMessageLength: maxMessageLength,
                    currentHeight: textFieldHeight
                )
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
        .padding(.vertical, shouldAddVerticalPadding ? 8 : 0)
        .padding(.leading, 8)
        .background(composerInputBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(colors.innerBorder))
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
    }
    
    private var composerInputBackground: Color {
        var colors = colors
        return Color(colors.composerInputBackground)
    }
    
    private var shouldAddVerticalPadding: Bool {
        !addedFileURLs.isEmpty || !addedAssets.isEmpty
    }
    
    private var isInCooldown: Bool {
        cooldownDuration > 0
    }
}
