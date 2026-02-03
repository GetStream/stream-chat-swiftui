//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// A container view for displaying quoted messages in the message list.
/// This view handles the tap gesture to scroll to the original message.
public struct ChatQuotedMessageView: View {
    @Injected(\.tokens) private var tokens
    
    private let viewModel: QuotedMessageViewModel
    @Binding private var scrolledId: String?

    /// Creates a chat quoted message view.
    /// - Parameters:
    ///   - viewModel: The view model containing the quoted message data.
    ///   - scrolledId: A binding to the scrolled message ID for navigation to the quoted message.
    public init(
        viewModel: QuotedMessageViewModel,
        scrolledId: Binding<String?>
    ) {
        self.viewModel = viewModel
        self._scrolledId = scrolledId
    }

    public var body: some View {
        QuotedMessageView(viewModel: viewModel)
            .padding(tokens.spacingXs)
            .onTapGesture {
                scrolledId = viewModel.messageId
            }
            .accessibilityAction {
                scrolledId = viewModel.messageId
            }
            .accessibilityIdentifier("ChatQuotedMessageView")
    }
}
