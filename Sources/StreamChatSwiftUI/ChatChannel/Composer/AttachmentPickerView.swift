//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Photos
import StreamChat
import SwiftUI

/// View for the attachment picker.
public struct AttachmentPickerView<Factory: ViewFactory>: View {
    @EnvironmentObject var viewModel: MessageComposerViewModel
    
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    var viewFactory: Factory
    @Binding var selectedPickerState: AttachmentPickerState
    @Binding var filePickerShown: Bool
    @Binding var cameraPickerShown: Bool
    @Binding var addedFileURLs: [URL]
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

    public init(
        viewFactory: Factory,
        selectedPickerState: Binding<AttachmentPickerState>,
        filePickerShown: Binding<Bool>,
        cameraPickerShown: Binding<Bool>,
        addedFileURLs: Binding<[URL]>,
        onPickerStateChange: @escaping @MainActor (AttachmentPickerState) -> Void,
        photoLibraryAssets: PHFetchResult<PHAsset>? = nil,
        onAssetTap: @escaping @MainActor (AddedAsset) -> Void,
        onCustomAttachmentTap: @escaping @MainActor (CustomAttachment) -> Void,
        isAssetSelected: @escaping @MainActor (String) -> Bool,
        addedCustomAttachments: [CustomAttachment],
        cameraImageAdded: @escaping @MainActor (AddedAsset) -> Void,
        askForAssetsAccessPermissions: @escaping () -> Void,
        isDisplayed: Bool,
        height: CGFloat
    ) {
        self.viewFactory = viewFactory
        _selectedPickerState = selectedPickerState
        _filePickerShown = filePickerShown
        _cameraPickerShown = cameraPickerShown
        _addedFileURLs = addedFileURLs
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
    }

    public var body: some View {
        VStack(spacing: 0) {
            viewFactory.makeAttachmentSourcePickerView(
                options: AttachmentSourcePickerViewOptions(
                    selected: selectedPickerState,
                    onPickerStateChange: onPickerStateChange
                )
            )
            .environmentObject(viewModel)

            if selectedPickerState == .photos {
                if let assets = photoLibraryAssets {
                    let collection = PHFetchResultCollection(fetchResult: assets)
                    if !collection.isEmpty {
                        viewFactory.makePhotoAttachmentPickerView(
                            options: PhotoAttachmentPickerViewOptions(
                                assets: collection,
                                onAssetTap: onAssetTap,
                                isAssetSelected: isAssetSelected
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
                        addedFileURLs: $addedFileURLs
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
                        channelController: viewModel.channelController,
                        messageController: viewModel.messageController
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
    @EnvironmentObject var viewModel: MessageComposerViewModel
    
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images

    var selected: AttachmentPickerState
    var onTap: (AttachmentPickerState) -> Void

    public init(
        selected: AttachmentPickerState,
        onTap: @escaping (AttachmentPickerState) -> Void
    ) {
        self.selected = selected
        self.onTap = onTap
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 24) {
            AttachmentPickerButton(
                icon: images.attachmentPickerPhotos,
                pickerType: .photos,
                isSelected: selected == .photos,
                onTap: onTap
            )
            .accessibilityIdentifier("attachmentPickerPhotos")

            AttachmentPickerButton(
                icon: images.attachmentPickerFolder,
                pickerType: .files,
                isSelected: selected == .files,
                onTap: onTap
            )
            .accessibilityLabel(L10n.Composer.Picker.file)
            .accessibilityIdentifier("attachmentPickerFiles")

            AttachmentPickerButton(
                icon: images.attachmentPickerCamera,
                pickerType: .camera,
                isSelected: selected == .camera,
                onTap: onTap
            )
            .accessibilityIdentifier("attachmentPickerCamera")
            
            if viewModel.canSendPoll {
                AttachmentPickerButton(
                    icon: images.attachmentPickerPolls,
                    pickerType: .polls,
                    isSelected: selected == .polls,
                    onTap: onTap
                )
                .accessibilityLabel(L10n.Composer.Polls.createPoll)
                .accessibilityIdentifier("attachmentPickerPolls")
            }

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
public struct AttachmentPickerButton: View {
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
                .frame(width: 22)
                .foregroundColor(
                    isSelected ? Color(colors.highlightedAccentBackground)
                        : Color(colors.textLowEmphasis)
                )
        }
    }
}
