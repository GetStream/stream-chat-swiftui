//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Photos
import SwiftUI

/// View for the attachment picker.
public struct AttachmentPickerView<Factory: ViewFactory>: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
        
    var viewFactory: Factory
    @Binding var selectedPickerState: AttachmentPickerState
    @Binding var filePickerShown: Bool
    @Binding var cameraPickerShown: Bool
    @Binding var addedFileURLs: [URL]
    var onPickerStateChange: (AttachmentPickerState) -> Void
    var photoLibraryAssets: PHFetchResult<PHAsset>?
    var onAssetTap: (AddedAsset) -> Void
    var isAssetSelected: (String) -> Bool
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
                    viewFactory.makePhotoAttachmentPickerView(
                        assets: collection,
                        onAssetTap: onAssetTap,
                        isAssetSelected: isAssetSelected
                    )
                } else {
                    viewFactory.makeAssetsAccessPermissionView()
                }
                
            } else if selectedPickerState == .files {
                viewFactory.makeFilePickerView(
                    filePickerShown: $filePickerShown,
                    addedFileURLs: $addedFileURLs
                )
            } else {
                viewFactory.makeCameraPickerView(
                    selected: $selectedPickerState,
                    cameraPickerShown: $cameraPickerShown,
                    cameraImageAdded: cameraImageAdded
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
    @Injected(\.colors) var colors
    
    var selected: AttachmentPickerState
    var onTap: (AttachmentPickerState) -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: 24) {
            AttachmentPickerButton(
                iconName: "photo",
                pickerType: .photos,
                isSelected: selected == .photos,
                onTap: onTap
            )
            
            AttachmentPickerButton(
                iconName: "folder",
                pickerType: .files,
                isSelected: selected == .files,
                onTap: onTap
            )
            
            AttachmentPickerButton(
                iconName: "camera",
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
struct AttachmentPickerButton: View {
    @Injected(\.colors) var colors
    
    var iconName: String
    var pickerType: AttachmentPickerState
    var isSelected: Bool
    var onTap: (AttachmentPickerState) -> Void
    
    var body: some View {
        Button {
            onTap(pickerType)
        } label: {
            Image(systemName: iconName)
                .foregroundColor(
                    isSelected ? Color(colors.highlightedAccentBackground)
                        : Color(colors.textLowEmphasis)
                )
        }
    }
}
