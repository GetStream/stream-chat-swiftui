//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// A view that creates the appropriate attachment preview for a reference message.
///
/// This view examines the thumbnail data and renders the corresponding
/// preview view (image, video thumbnail, or file icon).
public struct ReferenceMessageAttachmentPreviewView: View {
    private let thumbnail: MessageAttachmentPreviewThumbnail?
    
    /// Creates an attachment preview from a thumbnail.
    /// - Parameter thumbnail: The thumbnail to display.
    public init(thumbnail: MessageAttachmentPreviewThumbnail?) {
        self.thumbnail = thumbnail
    }

    public var body: some View {
        if let thumbnail {
            thumbnailView(for: thumbnail)
        }
    }
    
    @ViewBuilder
    private func thumbnailView(for thumbnail: MessageAttachmentPreviewThumbnail) -> some View {
        if let url = thumbnail.url {
            if thumbnail.isImage {
                MessageImagePreviewView(url: url)
            } else if thumbnail.isVideo {
                MessageVideoPreviewView(thumbnailURL: url)
            } else if thumbnail.isFile {
                MessageFilePreviewView(fileURL: url)
            }
        }
    }
}
