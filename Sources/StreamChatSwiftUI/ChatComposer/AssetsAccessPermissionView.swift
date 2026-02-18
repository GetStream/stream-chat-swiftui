//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View displayed when there's no access permission to the photo library.
struct AssetsAccessPermissionView: View {
    @Injected(\.images) private var images

    var body: some View {
        AttachmentAccessPermissionView(
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
