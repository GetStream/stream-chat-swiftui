//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for added file attachments displayed in the composer input.
public struct AddedFileAttachmentsView: View {
    @Injected(\.tokens) private var tokens

    var addedFileURLs: [URL]
    var onDiscardAttachment: (String) -> Void

    public init(addedFileURLs: [URL], onDiscardAttachment: @escaping (String) -> Void) {
        self.addedFileURLs = addedFileURLs
        self.onDiscardAttachment = onDiscardAttachment
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: tokens.spacingXs) {
                ForEach(addedFileURLs, id: \.self) { url in
                    ComposerFileAttachmentView(
                        url: url,
                        onDiscardAttachment: onDiscardAttachment
                    )
                    .padding(tokens.spacingXxs)
                }
            }
            .padding(.trailing, tokens.spacingXs)
        }
        .padding(.top, tokens.spacingXs)
    }
}

extension URL {
    var sizeString: String {
        _ = startAccessingSecurityScopedResource()
        if let file = try? AttachmentFile(url: self) {
            stopAccessingSecurityScopedResource()
            return file.sizeString
        }

        return ""
    }
}
