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
        GeometryReader { proxy in
            scrollView(minHeight: proxy.size.height)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(colors.backgroundCoreElevation1))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("AttachmentPickerPromptView")
    }

    @ViewBuilder
    private func scrollView(minHeight: CGFloat) -> some View {
        // The prompt is hosted in a fixed-height area (roughly the keyboard
        // height) that never grows with Dynamic Type, so at larger sizes the
        // content needs to scroll rather than clip or overflow the panel.
        // `minHeight` keeps it vertically centered when everything fits.
        let scrollView = ScrollView {
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
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: 300)
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
            .frame(maxWidth: .infinity)
            .padding(.horizontal, tokens.spacing2xl)
            .padding(.bottom, 60)
            .frame(minHeight: minHeight)
        }

        // Only allow scrolling/bounce once the content actually overflows
        // the available height, instead of always being interactively
        // scrollable even when everything already fits on screen.
        if #available(iOS 16.4, *) {
            scrollView.scrollBounceBehavior(.basedOnSize)
        } else {
            scrollView
        }
    }
}
