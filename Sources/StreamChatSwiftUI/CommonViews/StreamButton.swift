//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChatCommonUI
import SwiftUI

struct StreamButton: View {
    @Injected(\.tokens) private var tokens

    private let icon: Image
    private let text: String?
    private let role: StreamButtonRole
    private let style: StreamButtonVisualStyle
    private let size: StreamButtonSize
    private let action: () -> Void

    init(
        icon: Image,
        text: String?,
        role: StreamButtonRole = .primary,
        style: StreamButtonVisualStyle = .solid,
        size: StreamButtonSize = .md,
        action: @escaping () -> Void
    ) {
        self.role = role
        self.style = style
        self.size = size
        self.icon = icon
        self.text = text
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            if let text {
                HStack(spacing: tokens.spacingXs) {
                    iconView
                    Text(text)
                }
            } else {
                iconView
            }
        }
        .buttonStyle(
            StreamButtonStyle(
                role: role,
                style: style,
                size: size,
                isIconOnly: text == nil
            )
        )
    }

    private var iconView: some View {
        icon
            .font(.system(size: tokens.iconSizeMd))
            .frame(width: tokens.iconSizeMd, height: tokens.iconSizeMd)
    }
}

struct StreamButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool

    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens
    @Injected(\.fonts) private var fonts

    let role: StreamButtonRole
    let style: StreamButtonVisualStyle
    let size: StreamButtonSize
    let isIconOnly: Bool

    init(
        role: StreamButtonRole = .primary,
        style: StreamButtonVisualStyle = .solid,
        size: StreamButtonSize = .md,
        isIconOnly: Bool
    ) {
        self.role = role
        self.style = style
        self.size = size
        self.isIconOnly = isIconOnly
    }

    func makeBody(configuration: Configuration) -> some View {
        Group {
            if isIconOnly {
                iconBody(configuration: configuration)
            } else {
                regularBody(configuration: configuration)
            }
        }
        .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
        .animation(.easeInOut(duration: 0.15), value: isEnabled)
    }

    private func baseContent(configuration: Configuration) -> some View {
        let metrics = sizeMetrics
        return configuration.label
            .font(fonts.bodyBold)
            .foregroundColor(Color(foregroundColor))
            .lineLimit(1)
            .padding(.horizontal, isIconOnly ? metrics.horizontalPaddingIconOnly : metrics.horizontalPaddingWithLabel)
            .padding(.vertical, metrics.verticalPadding)
            .background(Color(backgroundColor))
            .overlay(interactionOverlayView(isPressed: configuration.isPressed))
    }

    private func iconBody(configuration: Configuration) -> some View {
        baseContent(configuration: configuration)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color(borderColor), lineWidth: hasBorder ? borderWidth : 0))
    }

    private func regularBody(configuration: Configuration) -> some View {
        baseContent(configuration: configuration)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color(borderColor), lineWidth: hasBorder ? borderWidth : 0))
    }

    private func interactionOverlayView(isPressed: Bool) -> Color {
        Color(interactionOverlayColor(isPressed: isPressed) ?? .clear)
    }

    private var foregroundColor: UIColor {
        if !isEnabled { return colors.textDisabled }
        switch style {
        case .solid:
            return role.textOnAccentColor(colors: colors)
        case .outline, .ghost, .liquidGlass:
            return role.textColor(colors: colors)
        }
    }

    private var backgroundColor: UIColor {
        if !isEnabled {
            return style == .solid || style == .liquidGlass ? colors.backgroundCoreDisabled : .clear
        }

        switch style {
        case .solid:
            return role.backgroundColor(colors: colors)
        case .outline, .ghost:
            return .clear
        case .liquidGlass:
            return role.liquidGlassBackgroundColor(colors: colors)
        }
    }

    private var borderColor: UIColor {
        if !isEnabled {
            return style == .outline || style == .liquidGlass ? colors.borderUtilityDisabled : .clear
        }

        switch style {
        case .solid, .ghost:
            return .clear
        case .outline, .liquidGlass:
            return role.borderColor(colors: colors)
        }
    }

    private var hasBorder: Bool {
        style == .outline || style == .liquidGlass
    }

    private var borderWidth: CGFloat {
        1
    }

    private func interactionOverlayColor(isPressed: Bool) -> UIColor? {
        guard isEnabled else { return nil }
        if isPressed { return colors.backgroundCorePressed }
        return nil
    }

    private var sizeMetrics: SizeMetrics {
        switch size {
        case .lg:
            return .large(tokens: tokens)
        case .sm:
            return .small(tokens: tokens)
        case .md:
            return .medium(tokens: tokens)
        }
    }

    private struct SizeMetrics {
        let horizontalPaddingWithLabel: CGFloat
        let horizontalPaddingIconOnly: CGFloat
        let verticalPadding: CGFloat

        static func large(tokens: Appearance.DesignSystemTokens) -> SizeMetrics {
            .init(
                horizontalPaddingWithLabel: tokens.buttonPaddingXWithLabelLg,
                horizontalPaddingIconOnly: tokens.buttonPaddingXIconOnlyLg,
                verticalPadding: tokens.buttonPaddingYLg
            )
        }

        static func medium(tokens: Appearance.DesignSystemTokens) -> SizeMetrics {
            .init(
                horizontalPaddingWithLabel: tokens.buttonPaddingXWithLabelMd,
                horizontalPaddingIconOnly: tokens.buttonPaddingXIconOnlyMd,
                verticalPadding: tokens.buttonPaddingYMd
            )
        }

        static func small(tokens: Appearance.DesignSystemTokens) -> SizeMetrics {
            .init(
                horizontalPaddingWithLabel: tokens.buttonPaddingXWithLabelSm,
                horizontalPaddingIconOnly: tokens.buttonPaddingXIconOnlySm,
                verticalPadding: tokens.buttonPaddingYSm
            )
        }
    }
}

private extension StreamButtonRole {
    func backgroundColor(colors: Appearance.ColorPalette) -> UIColor {
        switch self {
        case .primary:
            return colors.buttonPrimaryBackground
        case .secondary:
            return colors.buttonSecondaryBackground
        case .destructive:
            return colors.buttonDestructiveBackground
        }
    }

    func liquidGlassBackgroundColor(colors: Appearance.ColorPalette) -> UIColor {
        switch self {
        case .primary:
            return colors.buttonPrimaryBackgroundLiquidGlass
        case .secondary:
            return colors.buttonSecondaryBackgroundLiquidGlass
        case .destructive:
            return colors.buttonDestructiveBackgroundLiquidGlass
        }
    }

    func borderColor(colors: Appearance.ColorPalette) -> UIColor {
        switch self {
        case .primary:
            return colors.buttonPrimaryBorder
        case .secondary:
            return colors.buttonSecondaryBorder
        case .destructive:
            return colors.buttonDestructiveBorder
        }
    }

    func textColor(colors: Appearance.ColorPalette) -> UIColor {
        switch self {
        case .primary:
            return colors.buttonPrimaryText
        case .secondary:
            return colors.buttonSecondaryText
        case .destructive:
            return colors.buttonDestructiveText
        }
    }

    func textOnAccentColor(colors: Appearance.ColorPalette) -> UIColor {
        switch self {
        case .primary:
            return colors.buttonPrimaryTextOnAccent
        case .secondary:
            return colors.buttonSecondaryTextOnAccent
        case .destructive:
            return colors.buttonDestructiveTextOnAccent
        }
    }
}

enum StreamButtonRole: String, CaseIterable, Sendable {
    case primary = "Primary"
    case secondary = "Secondary"
    case destructive = "Destructive"
}

enum StreamButtonVisualStyle: String, CaseIterable, Sendable {
    case solid = "Solid"
    case outline = "Outline"
    case ghost = "Ghost"
    case liquidGlass = "Liquid Glass"
}

enum StreamButtonSize: String, CaseIterable, Sendable {
    case lg
    case md
    case sm
}
