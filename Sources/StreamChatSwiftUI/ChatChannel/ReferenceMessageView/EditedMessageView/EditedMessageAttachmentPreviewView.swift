//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// A factory view that creates the appropriate attachment preview for an edited message.
///
/// This view examines the view model's thumbnail data and renders the corresponding
/// preview view (image, video thumbnail, or file icon).
public struct EditedMessageAttachmentPreviewView: View {
    private let viewModel: EditedMessageViewModel
    
    /// Creates an attachment preview from an edited message view model.
    /// - Parameter viewModel: The view model containing the attachment data.
    public init(viewModel: EditedMessageViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        if let thumbnail = viewModel.thumbnail {
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
