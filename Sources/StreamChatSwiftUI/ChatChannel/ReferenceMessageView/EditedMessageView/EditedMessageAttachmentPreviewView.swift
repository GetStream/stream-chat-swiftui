//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// A factory view that creates the appropriate attachment preview for an edited message.
///
/// This view examines the view model's attachment data and renders the corresponding
/// preview view (image, video thumbnail, or file icon) based on the attachment kind.
public struct EditedMessageAttachmentPreviewView: View {
    private let viewModel: EditedMessageViewModel
    
    /// Creates an attachment preview from an edited message view model.
    /// - Parameter viewModel: The view model containing the attachment data.
    public init(viewModel: EditedMessageViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        if let url = viewModel.imagePreviewURL {
            MessageImagePreviewView(url: url)
        } else if let url = viewModel.videoPreviewURL {
            MessageVideoPreviewView(thumbnailURL: url)
        } else if let url = viewModel.filePreviewURL {
            MessageFilePreviewView(fileURL: url)
        }
    }
}
