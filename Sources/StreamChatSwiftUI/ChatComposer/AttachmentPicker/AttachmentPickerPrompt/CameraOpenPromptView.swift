//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import AVFoundation
import StreamChat
import SwiftUI

/// Prompt view for the camera tab. Displays either the
/// "open camera" UI or the "access denied" UI depending on the
/// current authorization status.
struct CameraOpenPromptView<Factory: ViewFactory>: View {
    @Injected(\.images) private var images

    var factory: Factory

    @Binding var cameraPickerShown: Bool
    var cameraImageAdded: @MainActor (AddedAsset) -> Void

    @State private var cameraStatus: AVAuthorizationStatus

    init(
        factory: Factory,
        cameraPickerShown: Binding<Bool>,
        cameraImageAdded: @escaping @MainActor (AddedAsset) -> Void,
        initialCameraStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    ) {
        self.factory = factory
        _cameraPickerShown = cameraPickerShown
        self.cameraImageAdded = cameraImageAdded
        _cameraStatus = State(initialValue: initialCameraStatus)
    }

    var body: some View {
        Group {
            if cameraStatus == .denied || cameraStatus == .restricted {
                accessDeniedContent
            } else {
                openCameraContent
            }
        }
    }

    // MARK: - Private

    private var accessDeniedContent: some View {
        AttachmentPickerPromptView(
            image: Image(uiImage: images.attachmentPickerCameraIcon),
            description: L10n.Composer.Camera.noAccess,
            buttonText: L10n.Composer.Camera.accessSettings,
            onTap: {
                openSettings()
            }
        )
    }

    private var openCameraContent: some View {
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
        .onAppear {
            openCamera()
        }
    }

    private func openCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            cameraPickerShown = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        cameraPickerShown = true
                    } else {
                        cameraStatus = .denied
                    }
                }
            }
        default:
            break
        }
    }
}
