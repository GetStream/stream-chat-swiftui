//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// A floating snack bar that displays a transient message.
///
/// The snack bar automatically triggers `onDismiss` after `duration` seconds
public struct SnackBarView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    public let text: String
    /// A Boolean value indicating whether a spinner is shown in front of the text, for something still in progress.
    public let showsSpinner: Bool
    public let duration: TimeInterval
    /// The title of the action button. There is no button when `nil`.
    public let actionTitle: String?
    /// Called when the action button is tapped, before the snack bar is dismissed.
    public var onAction: (() -> Void)?
    public var onDismiss: (() -> Void)?

    public init(
        text: String,
        showsSpinner: Bool = false,
        duration: TimeInterval = 3,
        actionTitle: String? = nil,
        onAction: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.text = text
        self.showsSpinner = showsSpinner
        self.duration = duration
        self.actionTitle = actionTitle
        self.onAction = onAction
        self.onDismiss = onDismiss
    }

    public var body: some View {
        HStack(spacing: tokens.spacingXs) {
            if showsSpinner {
                LoadingSpinnerView(sizeOnInverseBackground: LoadingSpinnerSize.extraSmall)
                    .accessibilityHidden(true)
            }
            Text(text)
                .font(fonts.subheadline)
                .fixedSize(horizontal: false, vertical: true)
            if let actionTitle {
                Button {
                    onAction?()
                    onDismiss?()
                } label: {
                    Text(actionTitle)
                        .font(fonts.bodyBold)
                        .padding(.horizontal, tokens.spacingMd)
                        .frame(minHeight: 32)
                        .overlay(Capsule().strokeBorder(Color(colors.textOnInverse), lineWidth: 1))
                }
                .padding(.leading, tokens.spacingXxs)
                .padding(.trailing, -tokens.spacingXs)
            }
        }
        .padding(.horizontal, tokens.spacingMd)
        .padding(.vertical, actionTitle == nil ? tokens.spacingSm : tokens.spacingXs)
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
            DispatchQueue.main.asyncAfter(deadline: .now() + visibleDuration) {
                onDismiss?()
            }
        }
        .transition(.offset(y: 8).combined(with: .opacity))
        .accessibilityElement(children: actionTitle == nil ? .combine : .contain)
        .accessibilityLabel(text)
    }
}

extension SnackBarView {
    // Reaching the action with VoiceOver takes longer than tapping it.
    private var visibleDuration: TimeInterval {
        actionTitle != nil && UIAccessibility.isVoiceOverRunning ? max(duration, 10) : duration
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
    ///   - showsSpinner: Whether a spinner is shown in front of the text.
    ///   - duration: How long the snack bar stays visible.
    ///   - actionTitle: The title of the action button. There is no button when `nil`.
    ///   - onAction: Called when the action button is tapped, before the snack bar is dismissed.
    ///   - bottomOffset: Extra offset from the bottom of this view.
    public func snackBar(
        text: Binding<String?>,
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
                        showsSpinner: showsSpinner,
                        duration: duration,
                        actionTitle: actionTitle,
                        onAction: onAction
                    ) {
                        withAnimation {
                            text.wrappedValue = nil
                        }
                    }
                }
            }
            .animation(.easeInOut, value: text.wrappedValue)
            .offset(y: -bottomOffset),
            alignment: .bottom
        )
    }
}
