//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import AVFoundation
import StreamChat
import SwiftUI

/// Prompt view displayed when the camera tab is selected,
/// allowing the user to open the camera.
struct CameraOpenPromptView<Factory: ViewFactory>: View {
    @Injected(\.images) private var images

    var factory: Factory

    @Binding var cameraPickerShown: Bool
    var cameraImageAdded: @MainActor (AddedAsset) -> Void

    var body: some View {
        AttachmentPickerPromptView(
            image: Image(uiImage: images.attachmentPickerCameraIcon),
            description: L10n.Composer.Camera.takePhoto,
            buttonText: L10n.Composer.Camera.openCamera,
            onTap: {
                openCamera()
            }
        )
        .fullScreenCover(isPresented: $cameraPickerShown) {
            factory.makeAttachmentCameraPickerView(
                options: .init(
                    cameraImageAdded: cameraImageAdded
                )
            )
        }
    }

    private func openCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            cameraPickerShown = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        cameraPickerShown = true
                    }
                }
            }
        default:
            break
        }
    }
}
