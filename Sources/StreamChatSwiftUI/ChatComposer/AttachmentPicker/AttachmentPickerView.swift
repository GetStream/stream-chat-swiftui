//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Photos
import StreamChat
import StreamChatCommonUI
import SwiftUI

/// Enum for the picker type state.
public enum PickerTypeState: Equatable, Sendable {
    /// Picker is expanded, with a selected `AttachmentPickerType`.
    case expanded(AttachmentPickerType)
}

/// Attachment picker type.
public enum AttachmentPickerType: Sendable {
    /// None is selected.
    case none
    /// Media (images, files, videos) is selected.
    case media
    /// Instant commands are selected.
    case instantCommands
    /// Custom attachment picker type.
    case custom
}

/// View for the attachment picker.
public struct AttachmentPickerView<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    var viewFactory: Factory
    @Binding var selectedPickerState: AttachmentPickerState
    @Binding var filePickerShown: Bool
    @Binding var cameraPickerShown: Bool
    var onFilesPicked: @MainActor ([URL]) -> Void
    var onPickerStateChange: @MainActor (AttachmentPickerState) -> Void
    var photoLibraryAssets: PHFetchResult<PHAsset>?
    var onAssetTap: @MainActor (AddedAsset) -> Void
    var onCustomAttachmentTap: @MainActor (CustomAttachment) -> Void
    var isAssetSelected: @MainActor (String) -> Bool
    var addedCustomAttachments: [CustomAttachment]
    var cameraImageAdded: @MainActor (AddedAsset) -> Void
    var askForAssetsAccessPermissions: () -> Void

    var isDisplayed: Bool
    var height: CGFloat
    var selectedAssetIds: [String]?
    
    var channelController: ChatChannelController
    var messageController: ChatMessageController?
    var canSendPoll: Bool
    var instantCommands: [CommandHandler]
    var onCommandSelected: @MainActor (ComposerCommand) -> Void
    
    public init(
        viewFactory: Factory,
        selectedPickerState: Binding<AttachmentPickerState>,
        filePickerShown: Binding<Bool>,
        cameraPickerShown: Binding<Bool>,
        onFilesPicked: @escaping @MainActor ([URL]) -> Void,
        onPickerStateChange: @escaping @MainActor (AttachmentPickerState) -> Void,
        photoLibraryAssets: PHFetchResult<PHAsset>? = nil,
        onAssetTap: @escaping @MainActor (AddedAsset) -> Void,
        onCustomAttachmentTap: @escaping @MainActor (CustomAttachment) -> Void,
        isAssetSelected: @escaping @MainActor (String) -> Bool,
        addedCustomAttachments: [CustomAttachment],
        cameraImageAdded: @escaping @MainActor (AddedAsset) -> Void,
        askForAssetsAccessPermissions: @escaping () -> Void,
        isDisplayed: Bool,
        height: CGFloat,
        selectedAssetIds: [String]? = nil,
        channelController: ChatChannelController,
        messageController: ChatMessageController?,
        canSendPoll: Bool,
        instantCommands: [CommandHandler],
        onCommandSelected: @escaping @MainActor (ComposerCommand) -> Void
    ) {
        self.viewFactory = viewFactory
        _selectedPickerState = selectedPickerState
        _filePickerShown = filePickerShown
        _cameraPickerShown = cameraPickerShown
        self.onFilesPicked = onFilesPicked
        self.onPickerStateChange = onPickerStateChange
        self.photoLibraryAssets = photoLibraryAssets
        self.onAssetTap = onAssetTap
        self.onCustomAttachmentTap = onCustomAttachmentTap
        self.isAssetSelected = isAssetSelected
        self.addedCustomAttachments = addedCustomAttachments
        self.cameraImageAdded = cameraImageAdded
        self.askForAssetsAccessPermissions = askForAssetsAccessPermissions
        self.isDisplayed = isDisplayed
        self.height = height
        self.selectedAssetIds = selectedAssetIds
        self.channelController = channelController
        self.messageController = messageController
        self.canSendPoll = canSendPoll
        self.instantCommands = instantCommands
        self.onCommandSelected = onCommandSelected
    }

    public var body: some View {
        VStack(spacing: 0) {
            viewFactory.makeAttachmentTypePickerView(
                options: AttachmentTypePickerViewOptions(
                    selected: selectedPickerState,
                    canSendPoll: canSendPoll,
                    onPickerStateChange: onPickerStateChange
                )
            )

            if selectedPickerState == .photos {
                viewFactory.makeAttachmentMediaPickerView(
                    options: AttachmentMediaPickerViewOptions(
                        photoLibraryAssets: photoLibraryAssets,
                        onAssetTap: onAssetTap,
                        isAssetSelected: isAssetSelected,
                        selectedAssetIds: selectedAssetIds
                    )
                )

            } else if selectedPickerState == .files {
                viewFactory.makeAttachmentFilePickerView(
                    options: AttachmentFilePickerViewOptions(
                        filePickerShown: $filePickerShown,
                        onFilesPicked: onFilesPicked
                    )
                )
            } else if selectedPickerState == .camera {
                viewFactory.makeAttachmentCameraPickerView(
                    options: AttachmentCameraPickerViewOptions(
                        cameraPickerShown: $cameraPickerShown,
                        cameraImageAdded: cameraImageAdded
                    )
                )
            } else if selectedPickerState == .polls {
                viewFactory.makeAttachmentPollPickerView(
                    options: AttachmentPollPickerViewOptions(
                        channelController: channelController,
                        messageController: messageController
                    )
                )
            } else if selectedPickerState == .commands {
                viewFactory.makeAttachmentCommandsPickerView(
                    options: AttachmentCommandsPickerViewOptions(
                        instantCommands: instantCommands,
                        onCommandSelected: onCommandSelected
                    )
                )
            } else if selectedPickerState == .custom {
                viewFactory.makeCustomAttachmentPickerView(
                    options: CustomAttachmentPickerViewOptions(
                        addedCustomAttachments: addedCustomAttachments,
                        onCustomAttachmentTap: onCustomAttachmentTap
                    )
                )
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .frame(height: height)
        .background(Color(colors.backgroundCoreElevation1))
        .onChange(of: isDisplayed) { newValue in
            if newValue {
                askForAssetsAccessPermissions()
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("AttachmentPickerView")
    }
}
