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
            description: L10n.Composer.Images.noAccessLibrary,
            buttonText: L10n.Composer.Images.accessSettings,
            onTap: {
                openSettings()
            }
        )
    }
}
