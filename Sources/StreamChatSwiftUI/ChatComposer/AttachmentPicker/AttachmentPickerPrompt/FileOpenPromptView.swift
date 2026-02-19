//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Prompt view displayed when the file tab is selected,
/// allowing the user to open the native file picker.
struct FileOpenPromptView<Factory: ViewFactory>: View {
    @Injected(\.images) private var images

    var factory: Factory
    @Binding var filePickerShown: Bool
    @MainActor var onFilesPicked: ([URL]) -> Void

    var body: some View {
        AttachmentPickerPromptView(
            image: Image(uiImage: images.attachmentPickerDocumentIcon),
            description: L10n.Composer.Files.selectFiles,
            buttonText: L10n.Composer.Files.openFiles,
            onTap: {
                filePickerShown = true
            }
        )
        .sheet(isPresented: $filePickerShown) {
            factory.makeAttachmentFilePickerView(
                options: .init(onFilesPicked: { urls in
                    onFilesPicked(urls)
                })
            )
        }
        .onAppear {
            filePickerShown = true
        }
    }
}
