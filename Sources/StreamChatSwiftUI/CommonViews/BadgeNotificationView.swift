//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChatCommonUI
import SwiftUI

public enum BadgeNotificationType: String, CaseIterable, Sendable {
    case primary = "Primary"
    case error = "Error"
    case neutral = "Neutral"
}

public enum BadgeNotificationSize: String, CaseIterable, Sendable {
    case small = "Small"
    case extraSmall = "Extra Small"
}

/// A notification badge that displays a count.
public struct BadgeNotificationView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    let count: Int
    var type: BadgeNotificationType
    var size: BadgeNotificationSize

    private let borderWidth: CGFloat = 2

    public init(
        count: Int,
        type: BadgeNotificationType = .primary,
        size: BadgeNotificationSize = .small
    ) {
        self.count = count
        self.type = type
        self.size = size
    }

    public var body: some View {
        HStack(alignment: .center, spacing: tokens.spacingNone) {
            Text("\(count)")
                .lineLimit(1)
                .font(sizeMetrics.font)
                .foregroundColor(Color(foregroundColor))
        }
        .padding(.horizontal, tokens.spacingXxs)
        .padding(.vertical, tokens.spacingNone)
        .frame(
            minWidth: sizeMetrics.width,
            idealWidth: sizeMetrics.width,
            minHeight: sizeMetrics.height,
            maxHeight: sizeMetrics.height,
            alignment: .center
        )
        .background(Color(backgroundColor))
        .cornerRadius(tokens.radiusMax)
        .overlay(
            RoundedRectangle(cornerRadius: tokens.radiusMax)
                .inset(by: -1)
                .stroke(Color(colors.badgeBorder), lineWidth: 2)
        )
        .accessibilityIdentifier("BadgeNotificationView")
    }

    // MARK: - Colors

    private var backgroundColor: UIColor {
        switch type {
        case .primary:
            return colors.badgeBackgroundPrimary
        case .error:
            return colors.badgeBackgroundError
        case .neutral:
            return colors.badgeBackgroundNeutral
        }
    }

    private var foregroundColor: UIColor {
        switch type {
        case .primary, .error:
            return colors.badgeTextOnAccent
        case .neutral:
            return colors.badgeText
        }
    }

    // MARK: - Size Metrics

    private var sizeMetrics: SizeMetrics {
        switch size {
        case .small:
            return .small(fonts: fonts)
        case .extraSmall:
            return .extraSmall(fonts: fonts)
        }
    }

    private struct SizeMetrics {
        let width: CGFloat
        let height: CGFloat
        let font: Font

        static func small(fonts: Appearance.FontsSwiftUI) -> SizeMetrics {
            .init(width: 20, height: 20, font: fonts.footnoteBold)
        }

        static func extraSmall(fonts: Appearance.FontsSwiftUI) -> SizeMetrics {
            .init(width: 16, height: 16, font: fonts.caption1.bold())
        }
    }
}

// MARK: - BadgeNotificationModifier

/// Overlays a notification badge at the top-trailing corner of the modified view.
struct BadgeNotificationModifier: ViewModifier {
    let count: Int
    var type: BadgeNotificationType
    var size: BadgeNotificationSize

    init(
        count: Int,
        type: BadgeNotificationType = .primary,
        size: BadgeNotificationSize = .small
    ) {
        self.count = count
        self.type = type
        self.size = size
    }

    func body(content: Content) -> some View {
        content.overlay(
            Group {
                if count > 0 {
                    BadgeNotificationView(
                        count: count,
                        type: type,
                        size: size
                    )
                    .offset(x: 5, y: -5)
                }
            },
            alignment: .topTrailing
        )
    }
}

// MARK: - View Extension

extension View {
    /// Adds a notification badge to the top-trailing corner.
    /// - Parameters:
    ///   - count: The number to display. The badge is hidden when count is 0.
    ///   - type: The badge color scheme.
    ///   - size: The badge size.
    func badgeNotification(
        count: Int,
        type: BadgeNotificationType = .primary,
        size: BadgeNotificationSize = .small
    ) -> some View {
        modifier(BadgeNotificationModifier(
            count: count,
            type: type,
            size: size
        ))
    }
}
