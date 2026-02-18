//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Prompt view displayed when the user has not granted access to the photo library.
struct PhotoLibraryAccessPromptView: View {
    @Injected(\.images) private var images

    var body: some View {
        AttachmentPickerPromptView(
            image: Image(uiImage: images.attachmentPickerPhotosIcon),
            text: L10n.Composer.Images.noAccessLibrary,
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
