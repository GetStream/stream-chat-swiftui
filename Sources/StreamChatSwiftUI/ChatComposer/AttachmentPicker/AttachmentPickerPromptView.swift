//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChatCommonUI
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
        VStack(spacing: tokens.spacingXs) {
            VStack(spacing: tokens.spacingXs) {
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            StreamTextButton(
                role: .secondary,
                style: .outline,
                size: .large,
                action: onTap
            ) {
                Text(buttonText)
                    .font(fonts.bodyBold)
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, minHeight: 48, maxHeight: 48, alignment: .center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, tokens.spacing2xl)
        .padding(.bottom, tokens.spacing3xl)
        .background(Color(colors.backgroundCoreElevation1))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("AttachmentPickerPromptView")
    }
}
