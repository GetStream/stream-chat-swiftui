//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// A view that creates the appropriate attachment preview for a reference message.
///
/// This view examines the view model's thumbnail data and renders the corresponding
/// preview view (image, video thumbnail, or file icon).
public struct ReferenceMessageAttachmentPreviewView: View {
    private let thumbnail: MessageAttachmentPreviewThumbnail?
    
    /// Creates an attachment preview from a reference message view model.
    /// - Parameter viewModel: The view model containing the attachment data.
    public init(viewModel: ReferenceMessageViewModel) {
        self.thumbnail = viewModel.thumbnail
    }
    
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
        if thumbnail.isImage, let url = thumbnail.url {
            MessageImagePreviewView(url: url)
        } else if thumbnail.isVideo, let url = thumbnail.url {
            MessageVideoPreviewView(thumbnailURL: url)
        } else if thumbnail.isFile, let url = thumbnail.url {
            MessageFilePreviewView(fileURL: url)
        }
    }
}
