//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Photos
import StreamChat
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
            viewFactory.makeAttachmentSourcePickerView(
                options: AttachmentSourcePickerViewOptions(
                    selected: selectedPickerState,
                    canSendPoll: canSendPoll,
                    onPickerStateChange: onPickerStateChange
                )
            )

            if selectedPickerState == .photos {
                if let assets = photoLibraryAssets {
                    let collection = PHFetchResultCollection(fetchResult: assets)
                    if !collection.isEmpty {
                        viewFactory.makePhotoAttachmentPickerView(
                            options: PhotoAttachmentPickerViewOptions(
                                assets: collection,
                                onAssetTap: onAssetTap,
                                isAssetSelected: isAssetSelected,
                                selectedAssetIds: selectedAssetIds
                            )
                        )
                        .edgesIgnoringSafeArea(.bottom)
                    } else {
                        viewFactory.makeAssetsAccessPermissionView(options: AssetsAccessPermissionViewOptions())
                    }
                } else {
                    LoadingView()
                }

            } else if selectedPickerState == .files {
                viewFactory.makeFilePickerView(
                    options: FilePickerViewOptions(
                        filePickerShown: $filePickerShown,
                        onFilesPicked: onFilesPicked
                    )
                )
            } else if selectedPickerState == .camera {
                viewFactory.makeCameraPickerView(
                    options: CameraPickerViewOptions(
                        selected: $selectedPickerState,
                        cameraPickerShown: $cameraPickerShown,
                        cameraImageAdded: cameraImageAdded
                    )
                )
            } else if selectedPickerState == .polls {
                viewFactory.makeComposerPollView(
                    options: ComposerPollViewOptions(
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
                viewFactory.makeCustomAttachmentView(
                    options: CustomComposerAttachmentViewOptions(
                        addedCustomAttachments: addedCustomAttachments,
                        onCustomAttachmentTap: onCustomAttachmentTap
                    )
                )
            }
        }
        .frame(height: height)
        .background(Color(colors.background1))
        .onChange(of: isDisplayed) { newValue in
            if newValue {
                askForAssetsAccessPermissions()
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("AttachmentPickerView")
    }
}

/// View for picking the source of the attachment (photo, files or camera).
public struct AttachmentSourcePickerView: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images

    var selected: AttachmentPickerState
    var canSendPoll: Bool
    var onTap: (AttachmentPickerState) -> Void

    public init(
        selected: AttachmentPickerState,
        canSendPoll: Bool,
        onTap: @escaping (AttachmentPickerState) -> Void
    ) {
        self.selected = selected
        self.onTap = onTap
        self.canSendPoll = canSendPoll
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 24) {
            AttachmentTypePickerButton(
                icon: images.attachmentPickerPhotos,
                pickerType: .photos,
                isSelected: selected == .photos,
                onTap: onTap
            )
            .accessibilityIdentifier("attachmentPickerPhotos")

            AttachmentTypePickerButton(
                icon: images.attachmentPickerFolder,
                pickerType: .files,
                isSelected: selected == .files,
                onTap: onTap
            )
            .accessibilityLabel(L10n.Composer.Picker.file)
            .accessibilityIdentifier("attachmentPickerFiles")

            AttachmentTypePickerButton(
                icon: images.attachmentPickerCamera,
                pickerType: .camera,
                isSelected: selected == .camera,
                onTap: onTap
            )
            .accessibilityIdentifier("attachmentPickerCamera")
            
            if canSendPoll {
                AttachmentTypePickerButton(
                    icon: images.attachmentPickerPolls,
                    pickerType: .polls,
                    isSelected: selected == .polls,
                    onTap: onTap
                )
                .accessibilityLabel(L10n.Composer.Polls.createPoll)
                .accessibilityIdentifier("attachmentPickerPolls")
            }

            AttachmentTypePickerButton(
                icon: images.commands,
                pickerType: .commands,
                isSelected: selected == .commands,
                onTap: onTap
            )
            .accessibilityLabel(L10n.Composer.Suggestions.Commands.header)
            .accessibilityIdentifier("attachmentPickerCommands")

            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(Color(colors.background1))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("AttachmentSourcePickerView")
    }
}

/// Button used for picking of attachment types.
public struct AttachmentTypePickerButton: View {
    @Injected(\.colors) private var colors

    var icon: UIImage
    var pickerType: AttachmentPickerState
    var isSelected: Bool
    var onTap: (AttachmentPickerState) -> Void

    public init(
        icon: UIImage,
        pickerType: AttachmentPickerState,
        isSelected: Bool,
        onTap: @escaping (AttachmentPickerState) -> Void
    ) {
        self.icon = icon
        self.pickerType = pickerType
        self.isSelected = isSelected
        self.onTap = onTap
    }

    public var body: some View {
        Button {
            onTap(pickerType)
        } label: {
            Image(uiImage: icon)
                .customizable()
                .frame(maxWidth: 20, maxHeight: 20)
                .foregroundColor(
                    isSelected ? Color(colors.highlightedAccentBackground)
                        : Color(colors.textLowEmphasis)
                )
        }
    }
}
