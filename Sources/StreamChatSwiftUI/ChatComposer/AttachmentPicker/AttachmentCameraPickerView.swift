//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View displayed when the camera picker is shown.
struct AttachmentCameraPickerView: View {
    @Binding var selectedPickerState: AttachmentPickerState
    @Binding var cameraPickerShown: Bool

    var cameraImageAdded: (AddedAsset) -> Void

    var body: some View {
        Spacer()
            .fullScreenCover(isPresented: $cameraPickerShown, onDismiss: {
                selectedPickerState = .photos
            }) {
                AttachmentImagePickerView(sourceType: .camera) { addedImage in
                    cameraImageAdded(addedImage)
                }
                .edgesIgnoringSafeArea(.all)
            }
    }
}
