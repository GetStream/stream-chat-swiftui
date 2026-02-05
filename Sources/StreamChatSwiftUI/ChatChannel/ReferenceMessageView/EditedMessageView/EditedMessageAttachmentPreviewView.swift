//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// A view that creates the appropriate attachment preview for an edited message.
///
/// This is a convenience wrapper around `ReferenceMessageAttachmentPreviewView`
/// that accepts an `EditedMessageViewModel`.
public struct EditedMessageAttachmentPreviewView: View {
    private let viewModel: EditedMessageViewModel
    
    /// Creates an attachment preview from an edited message view model.
    /// - Parameter viewModel: The view model containing the attachment data.
    public init(viewModel: EditedMessageViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ReferenceMessageAttachmentPreviewView(viewModel: viewModel)
    }
}
