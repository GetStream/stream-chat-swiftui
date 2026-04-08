//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// A reusable view to prompt the user of any action in the attachment picker.
public struct AttachmentPickerPromptView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    private let image: Image
    private let text: String
    private let buttonText: String
    private let onTap: @MainActor () -> Void

    public init(
        image: Image,
        description: String,
        buttonText: String,
        onTap: @escaping @MainActor () -> Void
    ) {
        self.image = image
        self.text = description
        self.buttonText = buttonText
        self.onTap = onTap
    }

    public var body: some View {
        VStack(spacing: tokens.spacingMd) {
            VStack(spacing: tokens.spacingSm) {
                image
                    .customizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(Color(colors.textTertiary))

                Text(text)
                    .font(fonts.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(colors.textTertiary))
                    .frame(width: 200)
            }

            StreamTextButton(
                role: .secondary,
                style: .outline,
                size: .medium,
                action: onTap
            ) {
                Text(buttonText)
                    .font(fonts.bodyBold)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, tokens.spacing2xl)
        .padding(.bottom, 60)
        .background(Color(colors.backgroundCoreElevation1))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("AttachmentPickerPromptView")
    }
}
