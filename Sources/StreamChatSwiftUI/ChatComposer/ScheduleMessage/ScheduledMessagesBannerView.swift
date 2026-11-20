//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// What the scheduled messages banner above the composer shows.
public enum ScheduledMessagesBannerState: Equatable, Sendable {
    /// Scheduled messages failed to send.
    case failed(count: Int)
    /// The channel has as many pending scheduled messages as it allows.
    case limitReached(count: Int, limit: Int)
    /// More than one scheduled message is pending.
    case multiple(count: Int)
    /// One scheduled message is pending, with the date it is sent at.
    case single(scheduledAt: Date)
    /// The edited scheduled message quotes a message which was deleted. The link removes the quote.
    case quoteDeleted
}

extension ScheduledMessagesBannerState {
    @MainActor var text: String {
        switch self {
        case let .failed(count):
            return L10n.Composer.ScheduledMessagesBanner.failed(count)
        case let .limitReached(count, limit):
            return L10n.Composer.ScheduledMessagesBanner.limit(count, limit)
        case let .multiple(count):
            return L10n.Composer.ScheduledMessagesBanner.count(count)
        case let .single(scheduledAt):
            let formatter = InjectedValues[\.utils].scheduledMessagesConfig.dateFormatter
            return L10n.Composer.ScheduledMessagesBanner.scheduledFor(formatter.format(scheduledAt))
        case .quoteDeleted:
            return L10n.Composer.ScheduleMessage.Error.quoteDeleted
        }
    }

    var linkText: String {
        switch self {
        case .failed(count: 1), .single:
            return L10n.Composer.ScheduledMessagesBanner.view
        case .failed, .limitReached, .multiple:
            return L10n.Composer.ScheduledMessagesBanner.viewAll
        case .quoteDeleted:
            return L10n.Composer.ScheduledMessagesBanner.removeQuote
        }
    }

    var isFailed: Bool {
        switch self {
        case .failed, .quoteDeleted:
            return true
        case .limitReached, .multiple, .single:
            return false
        }
    }
}

/// A banner on the top edge of the composer with the scheduled messages of the channel or thread, which opens
/// the scheduled message list. While a scheduled message is edited, it shows that its quoted message was deleted.
///
/// Part of the design system, where it is the `Chat / Mobile / Scheduled Messages Banner` component.
///
/// ```swift
/// ScheduledMessagesBannerView(state: .multiple(count: 3), onView: { showList() })
/// ```
public struct ScheduledMessagesBannerView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens

    /// What the banner shows.
    public let state: ScheduledMessagesBannerState
    /// Opens the scheduled message list, or removes the quote of the edited scheduled message for `.quoteDeleted`.
    public let onView: @MainActor () -> Void

    public init(state: ScheduledMessagesBannerState, onView: @escaping @MainActor () -> Void) {
        self.state = state
        self.onView = onView
    }

    public var body: some View {
        Button(action: onView) {
            HStack(spacing: tokens.spacingSm) {
                Image(uiImage: state.isFailed ? images.scheduledMessagesBannerFailed : images.scheduledMessagesBanner)
                    .customizable()
                    .frame(width: tokens.iconSizeMd, height: tokens.iconSizeMd)
                    .foregroundColor(Color(state.isFailed ? colors.accentError : colors.accentPrimary))
                    .accessibilityHidden(true)
                Text(state.text)
                    .font(fonts.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(colors.textPrimary))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(state.linkText)
                    .font(fonts.footnote)
                    .foregroundColor(Color(colors.textLink))
            }
            .padding(.horizontal, tokens.spacingMd)
            .padding(.vertical, tokens.spacingSm)
            .background(Color(colors.backgroundCoreElevation2))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color(colors.borderCoreDefault), lineWidth: 1))
            .shadow(
                color: Color(tokens.lightElevation3.color),
                radius: tokens.lightElevation3.blur / 2,
                x: tokens.lightElevation3.x,
                y: tokens.lightElevation3.y
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("ScheduledMessagesBannerView")
    }
}
