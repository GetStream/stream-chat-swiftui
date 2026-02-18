//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Prompt view displayed when the user has not granted access to the camera.
struct CameraAccessDeniedPromptView: View {
    @Injected(\.images) private var images

    var body: some View {
        AttachmentPickerPromptView(
            image: Image(uiImage: images.attachmentPickerCameraIcon),
            description: L10n.Composer.Camera.noAccess,
            buttonText: L10n.Composer.Camera.accessSettings,
            onTap: {
                openSettings()
            }
        )
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
