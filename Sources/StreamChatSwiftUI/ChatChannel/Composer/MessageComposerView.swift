//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Main view for the message composer.
public struct MessageComposerView<Factory: ViewFactory>: View, KeyboardReadable {
    @Injected(\.colors) var colors
    
    // Initial popup size, before the keyboard is shown.
    @State private var popupSize: CGFloat = 350
    
    private var factory: Factory
    
    public init(
        viewFactory: Factory,
        channelController: ChatChannelController,
        onMessageSent: @escaping () -> Void
    ) {
        factory = viewFactory
        _viewModel = StateObject(
            wrappedValue: ViewModelsFactory.makeMessageComposerViewModel(with: channelController)
        )
        self.onMessageSent = onMessageSent
    }
    
    @StateObject var viewModel: MessageComposerViewModel
        
    var onMessageSent: () -> Void
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom) {
                factory.makeLeadingComposerView(state: $viewModel.pickerTypeState)

                factory.makeComposerInputView(
                    text: $viewModel.text,
                    addedAssets: viewModel.addedAssets,
                    addedFileURLs: viewModel.addedFileURLs,
                    addedCustomAttachments: viewModel.addedCustomAttachments,
                    onCustomAttachmentTap: viewModel.customAttachmentTapped(_:),
                    shouldScroll: viewModel.inputComposerShouldScroll,
                    removeAttachmentWithId: viewModel.removeAttachment(with:)
                )
                                
                factory.makeTrailingComposerView(enabled: viewModel.sendButtonEnabled) {
                    viewModel.sendMessage {
                        onMessageSent()
                    }
                }
            }
            .padding(.all, 8)
            
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
        .onReceive(keyboardPublisher) { visible in
            if visible {
                withAnimation(.easeInOut(duration: 0.02)) {
                    viewModel.pickerTypeState = .expanded(.none)
                }
            }
        }
        .onReceive(keyboardHeight) { height in
            if height > 0 {
                self.popupSize = height - bottomSafeArea
            }
        }
        .alert(isPresented: $viewModel.errorShown) {
            Alert.defaultErrorAlert
        }
    }
}

/// View for the composer's input (text and media).
public struct ComposerInputView<Factory: ViewFactory>: View {
    @Injected(\.colors) var colors
    
    var factory: Factory
    @Binding var text: String
    var addedAssets: [AddedAsset]
    var addedFileURLs: [URL]
    var addedCustomAttachments: [CustomAttachment]
    var onCustomAttachmentTap: (CustomAttachment) -> Void
    
    var removeAttachmentWithId: (String) -> Void
    
    @State var textHeight: CGFloat = 34
    
    var textFieldHeight: CGFloat {
        let minHeight: CGFloat = 34
        let maxHeight: CGFloat = 70
            
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
            
            ComposerTextInputView(
                text: $text,
                height: $textHeight,
                placeholder: L10n.Composer.Placeholder.message
            )
            .frame(height: textFieldHeight)
        }
        .padding(.vertical, shouldAddVerticalPadding ? 8 : 0)
        .padding(.leading, 8)
        .background(Color(colors.background))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(colors.innerBorder))
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
    }
    
    private var shouldAddVerticalPadding: Bool {
        !addedFileURLs.isEmpty || !addedAssets.isEmpty
    }
}
