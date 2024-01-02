//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for an added file displayed in the composer input.
public struct AddedFileAttachmentsView: View {

    @Injected(\.colors) private var colors

    var addedFileURLs: [URL]
    var onDiscardAttachment: (String) -> Void

    public init(addedFileURLs: [URL], onDiscardAttachment: @escaping (String) -> Void) {
        self.addedFileURLs = addedFileURLs
        self.onDiscardAttachment = onDiscardAttachment
    }

    public var body: some View {
        VStack {
            ForEach(0..<addedFileURLs.count, id: \.self) { i in
                let url = addedFileURLs[i]
                FileAttachmentDisplayView(
                    url: url,
                    title: url.lastPathComponent,
                    sizeString: url.sizeString
                )
                .padding(.all, 8)
                .padding(.trailing, 8)
                .background(Color(colors.background))
                .roundWithBorder()
                .id(url)
                .overlay(
                    DiscardAttachmentButton(
                        attachmentIdentifier: url.absoluteString,
                        onDiscard: onDiscardAttachment
                    )
                )
            }
        }
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
