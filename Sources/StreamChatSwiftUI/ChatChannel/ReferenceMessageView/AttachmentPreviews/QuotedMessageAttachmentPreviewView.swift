//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// A factory view that creates the appropriate attachment preview for a quoted message.
///
/// This view examines the view model's attachment data and renders the corresponding
/// preview view (image, video thumbnail, or file icon).
public struct QuotedMessageAttachmentPreviewView: View {
    private let viewModel: QuotedMessageViewModel
    
    /// Creates an attachment preview from a quoted message view model.
    /// - Parameter viewModel: The view model containing the attachment data.
    public init(viewModel: QuotedMessageViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        if let url = viewModel.imagePreviewURL {
            QuotedMessageImagePreviewView(url: url)
        } else if let url = viewModel.videoThumbnailURL {
            QuotedMessageVideoPreviewView(thumbnailURL: url)
        } else if let fileExtension = viewModel.fileExtension {
            QuotedMessageFilePreviewView(fileExtension: fileExtension)
        }
    }
}
