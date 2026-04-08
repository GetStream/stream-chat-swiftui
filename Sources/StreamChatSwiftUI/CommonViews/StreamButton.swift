//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct StreamButton<Icon: View, TextContent: View>: View {
    @Injected(\.tokens) private var tokens

    private let icon: Icon
    private let text: TextContent
    private let role: StreamButtonRole
    private let style: StreamButtonVisualStyle
    private let size: StreamButtonSize
    private let isSelected: Bool
    private let action: () -> Void

    init(
        role: StreamButtonRole = .primary,
        style: StreamButtonVisualStyle = .solid,
        size: StreamButtonSize = .medium,
        isSelected: Bool = false,
        action: @escaping () -> Void,
        @ViewBuilder icon: () -> Icon,
        @ViewBuilder text: () -> TextContent
    ) {
        self.role = role
        self.style = style
        self.size = size
        self.isSelected = isSelected
        self.icon = icon()
        self.text = text()
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: tokens.spacingXs) {
                icon
                text
            }
        }
        .buttonStyle(
            StreamButtonStyle(
                role: role,
                style: style,
                size: size,
                isIconOnly: false,
                isSelected: isSelected
            )
        )
    }
}

// MARK: - StreamIconButton

struct StreamIconButton<Icon: View>: View {
    @Injected(\.tokens) private var tokens

    private let icon: Icon
    private let role: StreamButtonRole
    private let style: StreamButtonVisualStyle
    private let size: StreamButtonSize
    private let isSelected: Bool
    private let action: () -> Void

    init(
        role: StreamButtonRole = .primary,
        style: StreamButtonVisualStyle = .solid,
        size: StreamButtonSize = .medium,
        isSelected: Bool = false,
        action: @escaping () -> Void,
        @ViewBuilder icon: () -> Icon
    ) {
        self.role = role
        self.style = style
        self.size = size
        self.isSelected = isSelected
        self.icon = icon()
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            icon
        }
        .buttonStyle(
            StreamButtonStyle(
                role: role,
                style: style,
                size: size,
                isIconOnly: true,
                isSelected: isSelected
            )
        )
    }
}

// MARK: - StreamTextButton

struct StreamTextButton<TextContent: View>: View {
    @Injected(\.tokens) private var tokens

    private let text: TextContent
    private let role: StreamButtonRole
    private let style: StreamButtonVisualStyle
    private let size: StreamButtonSize
    private let isSelected: Bool
    private let action: () -> Void

    init(
        role: StreamButtonRole = .primary,
        style: StreamButtonVisualStyle = .solid,
        size: StreamButtonSize = .medium,
        isSelected: Bool = false,
        action: @escaping () -> Void,
        @ViewBuilder text: () -> TextContent
    ) {
        self.role = role
        self.style = style
        self.size = size
        self.isSelected = isSelected
        self.text = text()
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            text
        }
        .buttonStyle(
            StreamButtonStyle(
                role: role,
                style: style,
                size: size,
                isIconOnly: false,
                isSelected: isSelected
            )
        )
    }
}

struct StreamButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool

    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens
    @Injected(\.fonts) private var fonts

    private let borderWidth: CGFloat = 1

    let role: StreamButtonRole
    let style: StreamButtonVisualStyle
    let size: StreamButtonSize
    let isIconOnly: Bool
    let isSelected: Bool

    init(
        role: StreamButtonRole = .primary,
        style: StreamButtonVisualStyle = .solid,
        size: StreamButtonSize = .medium,
        isIconOnly: Bool,
        isSelected: Bool = false
    ) {
        self.role = role
        self.style = style
        self.size = size
        self.isIconOnly = isIconOnly
        self.isSelected = isSelected
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
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }

    private func baseContent(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(Color(foregroundColor))
            .lineLimit(1)
            .padding(.horizontal, isIconOnly ? sizeMetrics.horizontalPaddingIconOnly : sizeMetrics.horizontalPaddingWithLabel)
            .padding(.vertical, sizeMetrics.verticalPadding)
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
            .contentShape(Capsule())
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
            return style == .solid || style == .liquidGlass ? colors.backgroundUtilityDisabled : .clear
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

    private func interactionOverlayColor(isPressed: Bool) -> UIColor? {
        guard isEnabled else { return nil }
        if isPressed { return colors.backgroundUtilityPressed }
        if isSelected { return colors.backgroundUtilitySelected }
        return nil
    }

    private var sizeMetrics: SizeMetrics {
        switch size {
        case .large:
            return .large(tokens: tokens)
        case .small:
            return .small(tokens: tokens)
        case .medium:
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
    case large
    case medium
    case small
}
