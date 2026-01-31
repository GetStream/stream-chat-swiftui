//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// A quoted message view used to display a reference to another message within a chat.
public struct ChatQuotedMessageView: View {
    @Injected(\.tokens) private var tokens

    private let viewModel: QuotedMessageViewModel
    
    /// Creates a quoted message view from a view model.
    /// - Parameter viewModel: The view model containing the quoted message data.
    public init(viewModel: QuotedMessageViewModel) {
        self.viewModel = viewModel
    }
    
    /// Creates a quoted message view from a `ChatMessage`.
    /// - Parameter message: The quoted message to display.
    public init(message: ChatMessage) {
        self.viewModel = QuotedMessageViewModel(message: message)
    }

    public var body: some View {
        referenceMessageView
            .padding(.horizontal, tokens.spacingSm)
            .padding(.vertical, tokens.spacingXs)
            .frame(height: 56)
            .modifier(ReferenceMessageViewBackgroundModifier(
                isSentByCurrentUser: viewModel.isSentByCurrentUser
            ))
    }

    @ViewBuilder
    private var referenceMessageView: some View {
        ReferenceMessageView(
            title: viewModel.title,
            subtitle: viewModel.subtitle,
            subtitleIcon: subtitleIcon,
            isSentByCurrentUser: viewModel.isSentByCurrentUser
        ) {
            attachmentPreview
        }
    }
    
    private var subtitleIcon: UIImage? {
        guard let iconName = viewModel.subtitleIconName else {
            return nil
        }
        return UIImage(
            systemName: iconName,
            withConfiguration: UIImage.SymbolConfiguration(weight: .regular)
        )
    }
    
    @ViewBuilder
    private var attachmentPreview: some View {
        if let url = viewModel.imagePreviewURL {
            ReferenceMessageImagePreviewView(url: url)
        } else if let url = viewModel.videoThumbnailURL {
            ReferenceMessageVideoPreviewView(thumbnailURL: url)
        } else if let fileExtension = viewModel.fileExtension {
            ReferenceMessageFilePreviewView(fileExtension: fileExtension)
        }
    }
}
