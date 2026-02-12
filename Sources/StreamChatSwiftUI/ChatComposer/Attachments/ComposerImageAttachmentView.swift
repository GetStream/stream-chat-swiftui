//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct ComposerImageAttachmentView: View {
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    let imageSize: CGFloat = 72
    let attachment: AddedAsset
    let onDiscardAttachment: (String) -> Void

    var body: some View {
        Image(uiImage: attachment.image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: imageSize, height: imageSize)
            .clipped()
            .cornerRadius(tokens.messageBubbleRadiusAttachment)
            .overlay(
                RoundedRectangle(cornerRadius: tokens.messageBubbleRadiusAttachment)
                    .strokeBorder(Color(colors.borderCoreOpacity10), lineWidth: 1)
            )
            .id(attachment.id)
            .dismissButtonOverlayModifier {
                onDiscardAttachment(attachment.id)
            }
    }
}
