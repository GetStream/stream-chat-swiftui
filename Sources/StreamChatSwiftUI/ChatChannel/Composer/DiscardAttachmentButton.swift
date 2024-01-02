//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Button used for discarding attachments.
public struct DiscardAttachmentButton: View {

    var attachmentIdentifier: String
    var onDiscard: (String) -> Void

    public init(attachmentIdentifier: String, onDiscard: @escaping (String) -> Void) {
        self.attachmentIdentifier = attachmentIdentifier
        self.onDiscard = onDiscard
    }

    public var body: some View {
        TopRightView {
            Button(action: {
                withAnimation {
                    onDiscard(attachmentIdentifier)
                }
            }, label: {
                DiscardButtonView()
            })
        }
    }
}
