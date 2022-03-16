//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Photos
import StreamChat
import SwiftUI

/// View for the attachment picker.
public struct AttachmentPickerView<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
        
    var viewFactory: Factory
    @Binding var selectedPickerState: AttachmentPickerState
    @Binding var filePickerShown: Bool
    @Binding var cameraPickerShown: Bool
    @Binding var addedFileURLs: [URL]
    var onPickerStateChange: (AttachmentPickerState) -> Void
    var photoLibraryAssets: PHFetchResult<PHAsset>?
    var onAssetTap: (AddedAsset) -> Void
    var onCustomAttachmentTap: (CustomAttachment) -> Void
    var isAssetSelected: (String) -> Bool
    var addedCustomAttachments: [CustomAttachment]
    var cameraImageAdded: (AddedAsset) -> Void
    var askForAssetsAccessPermissions: () -> Void
    
    var isDisplayed: Bool
    var height: CGFloat
    
    public var body: some View {
        VStack(spacing: 0) {
            viewFactory.makeAttachmentSourcePickerView(
                selected: selectedPickerState,
                onPickerStateChange: onPickerStateChange
            )
            
            if selectedPickerState == .photos {
                if let assets = photoLibraryAssets,
                   let collection = PHFetchResultCollection(fetchResult: assets) {
                    if !collection.isEmpty {
                        viewFactory.makePhotoAttachmentPickerView(
                            assets: collection,
                            onAssetTap: onAssetTap,
                            isAssetSelected: isAssetSelected
                        )
                    } else {
                        viewFactory.makeAssetsAccessPermissionView()
                    }
                } else {
                    LoadingView()
                }
                
            } else if selectedPickerState == .files {
                viewFactory.makeFilePickerView(
                    filePickerShown: $filePickerShown,
                    addedFileURLs: $addedFileURLs
                )
            } else if selectedPickerState == .camera {
                viewFactory.makeCameraPickerView(
                    selected: $selectedPickerState,
                    cameraPickerShown: $cameraPickerShown,
                    cameraImageAdded: cameraImageAdded
                )
            } else if selectedPickerState == .custom {
                viewFactory.makeCustomAttachmentView(
                    addedCustomAttachments: addedCustomAttachments,
                    onCustomAttachmentTap: onCustomAttachmentTap
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
    }
}

/// View for picking the source of the attachment (photo, files or camera).
struct AttachmentSourcePickerView: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    
    var selected: AttachmentPickerState
    var onTap: (AttachmentPickerState) -> Void
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 24) {
            AttachmentPickerButton(
                icon: images.attachmentPickerPhotos,
                pickerType: .photos,
                isSelected: selected == .photos,
                onTap: onTap
            )
            
            AttachmentPickerButton(
                icon: images.attachmentPickerFolder,
                pickerType: .files,
                isSelected: selected == .files,
                onTap: onTap
            )
            
            AttachmentPickerButton(
                icon: images.attachmentPickerCamera,
                pickerType: .camera,
                isSelected: selected == .camera,
                onTap: onTap
            )
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(Color(colors.background1))
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
