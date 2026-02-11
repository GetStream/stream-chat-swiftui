//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// File attachment preview for messages.
public struct MessageFilePreviewView: View {
    @Injected(\.images) private var images

    let fileExtension: String

    /// Creates a file attachment preview with the given file extension.
    /// - Parameter fileExtension: The file extension (e.g., "pdf", "doc", "zip").
    public init(fileExtension: String) {
        self.fileExtension = fileExtension.lowercased()
    }

    /// Creates a file attachment preview from a file URL.
    /// - Parameter fileURL: The URL of the file to preview.
    public init(fileURL: URL) {
        self.fileExtension = fileURL.pathExtension.lowercased()
    }

    public var body: some View {
        Image(uiImage: fileIcon)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 40, height: 40)
    }

    private var fileIcon: UIImage {
        images.fileIconPreviews[fileExtension] ?? images.iconOther
    }
}
