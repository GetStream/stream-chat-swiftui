//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Reusable annotation row displayed above the message bubble.
///
/// Layout: `Icon | title (semibold) | [• subtitle] | [• button]`
/// The `•` separator only appears before subtitle/button when a title precedes it.
public struct MessageAnnotationView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    @Environment(\.sizeCategory) private var sizeCategory

    let icon: UIImage
    let title: String?
    let subtitle: String?
    let buttonTitle: String?
    let buttonAction: (@MainActor () -> Void)?
    /// When true, the `textOnAccent` color is used instead of the default darker text color.
    let usesInvertedStyle: Bool

    public init(
        icon: UIImage,
        title: String?,
        subtitle: String? = nil,
        buttonTitle: String? = nil,
        buttonAction: (@MainActor () -> Void)? = nil,
        usesInvertedStyle: Bool = false
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
        self.usesInvertedStyle = usesInvertedStyle
    }

    private var resolvedTextColor: Color {
        usesInvertedStyle ? colors.textOnAccent.toColor : colors.textPrimary.toColor
    }

    public var body: some View {
        HStack(spacing: tokens.spacingXxs) {
            Image(uiImage: icon)
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: tokens.iconSizeSm, height: tokens.iconSizeSm)
                .padding(.horizontal, tokens.spacingXxxs)
                .accessibilityHidden(true)
            if let title {
                Text(title)
                    .font(fonts.footnote.weight(.semibold))
                    .lineLimit(1)
            }
            if let subtitle {
                if title != nil {
                    Text("•")
                        .font(fonts.footnote)
                }
                Text(subtitle)
                    .font(fonts.footnote)
            }
            if let buttonTitle, let buttonAction {
                if title != nil {
                    Text("•")
                        .font(fonts.footnote)
                }
                Button(action: buttonAction) {
                    buttonText(buttonTitle)
                }
            }
        }
        .foregroundColor(resolvedTextColor)
    }

    @ViewBuilder
    private func buttonText(_ buttonTitle: String) -> some View {
        let text = Text(buttonTitle)
            .font(fonts.footnote)
            .foregroundColor(usesInvertedStyle ? resolvedTextColor : Color(colors.accentPrimary))
        // When the row wraps at accessibility text sizes the button title must stay
        // leading-aligned instead of centering. The modifier is only applied then, so the
        // single-line rendering used at smaller sizes is left untouched.
        if sizeCategory.isAccessibilityCategory {
            text.multilineTextAlignment(.leading)
        } else {
            text
        }
    }
}
