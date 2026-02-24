//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// The visual style of a snack bar.
public enum SnackBarStyle {
    case `default`
    case error
}

/// A floating snack bar that displays a transient message.
///
/// The snack bar automatically triggers `onDismiss` after `duration` seconds.
/// The parent view is responsible for removing the snack bar from the hierarchy
/// (typically by setting a binding to `nil` inside `onDismiss`), and can wrap
/// that removal in `withAnimation` to animate the exit transition.
public struct SnackBarView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    public let text: String
    public let style: SnackBarStyle
    public let duration: TimeInterval
    public var onDismiss: (() -> Void)?

    public init(
        text: String,
        style: SnackBarStyle = .default,
        duration: TimeInterval = 3,
        onDismiss: (() -> Void)? = nil
    ) {
        self.text = text
        self.style = style
        self.duration = duration
        self.onDismiss = onDismiss
    }

    public var body: some View {
        HStack(spacing: tokens.spacingXs) {
            if style == .error {
                Image(systemName: "exclamationmark.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
            }

            Text(text)
                .font(fonts.subheadline)
                .lineLimit(1)
        }
        .padding(.horizontal, tokens.spacingMd)
        .padding(.vertical, tokens.spacingSm)
        .foregroundColor(Color(colors.textOnDark))
        .background(Color(colors.backgroundCoreInverse))
        .clipShape(Capsule())
        .shadow(
            color: Color(tokens.lightElevation3.color),
            radius: tokens.lightElevation3.blur / 2,
            x: tokens.lightElevation3.x,
            y: tokens.lightElevation3.y
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                onDismiss?()
            }
        }
        .transition(.offset(y: 8).combined(with: .opacity))
        .accessibilityElement(children: .combine)
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
    ///   - style: The visual style (`.default` or `.error`).
    ///   - duration: How long the snack bar stays visible.
    ///   - bottomOffset: Extra offset from the bottom of this view.
    public func snackBar(
        text: Binding<String?>,
        style: SnackBarStyle = .default,
        duration: TimeInterval = 3,
        bottomOffset: CGFloat = 0
    ) -> some View {
        overlay(
            Group {
                if let value = text.wrappedValue {
                    SnackBarView(text: value, style: style, duration: duration) {
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
