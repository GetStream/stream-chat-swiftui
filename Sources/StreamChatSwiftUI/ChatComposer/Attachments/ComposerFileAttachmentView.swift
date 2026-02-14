//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for a single file attachment displayed in the composer input.
struct ComposerFileAttachmentView: View {
    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    let url: URL
    let onDiscardAttachment: (String) -> Void

    var body: some View {
        HStack(spacing: tokens.spacingSm) {
            fileIcon
            VStack(alignment: .leading, spacing: tokens.spacingXxs) {
                Text(url.lastPathComponent)
                    .font(fonts.footnoteBold)
                    .lineLimit(1)
                    .foregroundColor(Color(colors.text))
                Text(url.sizeString)
                    .font(fonts.caption1)
                    .lineLimit(1)
                    .foregroundColor(Color(colors.textLowEmphasis))
            }
            Spacer()
        }
        .padding(.top, tokens.spacingMd)
        .padding(.leading, tokens.spacingMd)
        .padding(.bottom, tokens.spacingMd)
        .padding(.trailing, tokens.spacingSm)
        .background(Color(colors.background))
        .cornerRadius(tokens.radiusLg)
        .overlay(
            RoundedRectangle(cornerRadius: tokens.radiusLg)
                .strokeBorder(Color(colors.borderCoreOpacity10), lineWidth: 1)
        )
        .id(url)
        .dismissButtonOverlayModifier {
            onDiscardAttachment(url.absoluteString)
        }
        .frame(width: 260)
    }

    private var fileIcon: some View {
        Image(uiImage: previewImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 40)
            .accessibilityHidden(true)
    }

    private var previewImage: UIImage {
        let iconName = url.pathExtension
        return images.fileIconPreviews[iconName] ?? images.fileFallback
    }
}

private extension URL {
    var sizeString: String {
        _ = startAccessingSecurityScopedResource()
        if let file = try? AttachmentFile(url: self) {
            stopAccessingSecurityScopedResource()
            return file.sizeString
        }
        return ""
    }
}
