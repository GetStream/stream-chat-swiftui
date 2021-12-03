//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for an added file displayed in the composer input.
public struct AddedFileAttachmentsView: View {
    @Injected(\.colors) private var colors
    
    var addedFileURLs: [URL]
    var onDiscardAttachment: (String) -> Void
    
    public var body: some View {
        VStack {
            ForEach(0..<addedFileURLs.count, id: \.self) { i in
                let url = addedFileURLs[i]
                FileAttachmentDisplayView(
                    url: url,
                    title: url.lastPathComponent,
                    sizeString: sizeString(for: url)
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
    
    private func sizeString(for url: URL) -> String {
        _ = url.startAccessingSecurityScopedResource()
        if let file = try? AttachmentFile(url: url) {
            url.stopAccessingSecurityScopedResource()
            return file.sizeString
        }
        
        return ""
    }
}
