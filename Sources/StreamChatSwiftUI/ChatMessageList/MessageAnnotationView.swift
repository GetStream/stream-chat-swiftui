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
        annotationRow
            .foregroundColor(resolvedTextColor)
            .modifier(
                CombinedAnnotationAccessibility(
                    label: accessibilityLabel,
                    // Interactive annotations expose the action button as its own
                    // element, so the row must not collapse into a single one.
                    isEnabled: buttonAction == nil
                )
            )
    }

    private var annotationRow: some View {
        HStack(spacing: tokens.spacingXxs) {
            // The icon doesn't scale with the text, so at accessibility sizes it
            // looks out of place and eats horizontal room the wrapped title needs.
            if !sizeCategory.isAccessibilityCategory {
                Image(uiImage: icon)
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: tokens.iconSizeSm, height: tokens.iconSizeSm)
                    .padding(.horizontal, tokens.spacingXxxs)
                    .accessibilityHidden(true)
            }
            if let title {
                Text(title)
                    .font(fonts.footnote.weight(.semibold))
                    .lineLimit(1)
                    .accessibilityHidden(buttonAction != nil)
            }
            if let subtitle {
                if title != nil {
                    Text("•")
                        .font(fonts.footnote)
                        .accessibilityHidden(true)
                }
                Text(subtitle)
                    .font(fonts.footnote)
            }
            if let buttonTitle, let buttonAction {
                if title != nil {
                    Text("•")
                        .font(fonts.footnote)
                        .accessibilityHidden(true)
                }
                Button(action: buttonAction) {
                    buttonText(buttonTitle)
                }
                .accessibilityLabel(accessibilityLabel)
            }
        }
    }

    /// Combined VoiceOver label so the whole annotation (including any action
    /// button title) is announced as a single element.
    private var accessibilityLabel: String {
        [title, subtitle, buttonTitle]
            .compactMap { $0 }
            .joined(separator: ", ")
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

/// Collapses a non-interactive annotation row into a single VoiceOver element
/// with the combined label. For interactive annotations it is disabled, so the
/// action button is announced as its own element instead.
private struct CombinedAnnotationAccessibility: ViewModifier {
    let label: String
    let isEnabled: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if isEnabled {
            content
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(label)
        } else {
            content
        }
    }
}
