//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// A floating snack bar that displays a transient message.
///
/// The snack bar automatically triggers `onDismiss` after `duration` seconds, or after at least 10 seconds
/// when it has an action and VoiceOver is running. Tapping the action also triggers it.
public struct SnackBarView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    public let text: String
    /// The icon shown in front of the text, such as `images.snackBarError` for an error. There is no icon when `nil`.
    public let icon: UIImage?
    /// A Boolean value indicating whether a spinner is shown in front of the text, for something still in progress.
    public let showsSpinner: Bool
    public let duration: TimeInterval
    public var onDismiss: (() -> Void)?
    /// The title of the action button. There is no button when `nil`.
    public let actionTitle: String?
    /// Called when the action button is tapped, before the snack bar is dismissed.
    public let onAction: (() -> Void)?

    public init(
        text: String,
        icon: UIImage? = nil,
        showsSpinner: Bool = false,
        duration: TimeInterval = 3,
        onDismiss: (() -> Void)? = nil,
        actionTitle: String? = nil,
        onAction: (() -> Void)? = nil
    ) {
        self.text = text
        self.icon = icon
        self.showsSpinner = showsSpinner
        self.duration = duration
        self.onDismiss = onDismiss
        self.actionTitle = actionTitle
        self.onAction = onAction
    }

    public var body: some View {
        HStack(spacing: tokens.spacingXs) {
            if showsSpinner {
                LoadingSpinnerView(sizeOnInverseBackground: LoadingSpinnerSize.extraSmall)
                    .frame(width: tokens.iconSizeMd, height: tokens.iconSizeMd)
                    .padding(.leading, -tokens.spacingXxs)
                    .accessibilityHidden(true)
            }
            if let icon {
                Image(uiImage: icon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: tokens.iconSizeMd, height: tokens.iconSizeMd)
                    .padding(.leading, -tokens.spacingXxs)
                    .accessibilityHidden(true)
            }
            Text(text)
                .font(fonts.subheadline)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, tokens.spacingSm)
            if let actionTitle {
                Button {
                    onAction?()
                    onDismiss?()
                } label: {
                    Text(actionTitle)
                        .font(fonts.bodyBold)
                        .padding(.horizontal, tokens.spacingMd)
                        .frame(minHeight: 32)
                        .overlay(Capsule().strokeBorder(Color(colors.borderCoreOnInverse), lineWidth: 1))
                        .frame(minHeight: tokens.buttonHitTargetMinHeight)
                        .contentShape(Rectangle())
                }
                .padding(.leading, tokens.spacingXxs)
                .padding(.trailing, -tokens.spacingXs)
            }
        }
        .padding(.horizontal, tokens.spacingMd)
        .foregroundColor(Color(colors.textOnInverse))
        .background(Color(colors.backgroundCoreInverse))
        .clipShape(Capsule())
        .shadow(
            color: Color(tokens.lightElevation3.color),
            radius: tokens.lightElevation3.blur / 2,
            x: tokens.lightElevation3.x,
            y: tokens.lightElevation3.y
        )
        .onAppear {
            // Reaching the action with VoiceOver takes longer than tapping it.
            let visibleDuration = actionTitle != nil && UIAccessibility.isVoiceOverRunning ? max(duration, 10) : duration
            DispatchQueue.main.asyncAfter(deadline: .now() + visibleDuration) {
                onDismiss?()
            }
        }
        .transition(.offset(y: 8).combined(with: .opacity))
        .accessibilityElement(children: actionTitle == nil ? .combine : .contain)
        .accessibilityLabel(text)
    }
}

// MARK: - View Modifier

extension View {
    /// Presents a floating snack bar above this view.
    ///
    /// The snack bar auto-dismisses after `duration` seconds.
    /// - Parameters:
    ///   - text: A binding to the text. Set to a non-nil value to show;
    ///     the modifier resets it to `nil` when the snack bar dismisses.
    ///   - icon: The icon shown in front of the text. There is no icon when `nil`.
    ///   - showsSpinner: Whether a spinner is shown in front of the text.
    ///   - duration: How long the snack bar stays visible. With an action and VoiceOver running, it stays at least
    ///     10 seconds.
    ///   - actionTitle: The title of the action button. There is no button when `nil`.
    ///   - onAction: Called when the action button is tapped, before the snack bar is dismissed.
    ///   - bottomOffset: Extra offset from the bottom of this view.
    public func snackBar(
        text: Binding<String?>,
        icon: UIImage? = nil,
        showsSpinner: Bool = false,
        duration: TimeInterval = 3,
        actionTitle: String? = nil,
        onAction: (() -> Void)? = nil,
        bottomOffset: CGFloat = 0
    ) -> some View {
        overlay(
            Group {
                if let value = text.wrappedValue {
                    SnackBarView(
                        text: value,
                        icon: icon,
                        showsSpinner: showsSpinner,
                        duration: duration,
                        onDismiss: {
                            // A text set since this one appeared stays, such as one that the action shows.
                            guard text.wrappedValue == value else { return }
                            withAnimation {
                                text.wrappedValue = nil
                            }
                        },
                        actionTitle: actionTitle,
                        onAction: onAction
                    )
                    .id(value)
                }
            }
            .animation(.easeInOut, value: text.wrappedValue)
            .offset(y: -bottomOffset),
            alignment: .bottom
        )
    }
}
