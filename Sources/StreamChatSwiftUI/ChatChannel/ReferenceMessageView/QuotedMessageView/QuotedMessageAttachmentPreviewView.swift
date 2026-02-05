//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// A view that creates the appropriate attachment preview for a quoted message.
///
/// This is a convenience wrapper around `ReferenceMessageAttachmentPreviewView`
/// that accepts a `QuotedMessageViewModel`.
public struct QuotedMessageAttachmentPreviewView: View {
    private let viewModel: QuotedMessageViewModel
    
    /// Creates an attachment preview from a quoted message view model.
    /// - Parameter viewModel: The view model containing the attachment data.
    public init(viewModel: QuotedMessageViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ReferenceMessageAttachmentPreviewView(viewModel: viewModel)
    }
}
