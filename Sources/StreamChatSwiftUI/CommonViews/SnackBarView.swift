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
    public let duration: TimeInterval
    public var onDismiss: (() -> Void)?

    public init(
        text: String,
        duration: TimeInterval = 3,
        onDismiss: (() -> Void)? = nil
    ) {
        self.text = text
        self.duration = duration
        self.onDismiss = onDismiss
    }

    public var body: some View {
        HStack(spacing: tokens.spacingXs) {
            Text(text)
                .font(fonts.subheadline)
                .lineLimit(1)
        }
        .padding(.horizontal, tokens.spacingMd)
        .padding(.vertical, tokens.spacingSm)
        .foregroundColor(Color(colors.textInverse))
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
    ///   - duration: How long the snack bar stays visible.
    ///   - bottomOffset: Extra offset from the bottom of this view.
    public func snackBar(
        text: Binding<String?>,
        duration: TimeInterval = 3,
        bottomOffset: CGFloat = 0
    ) -> some View {
        overlay(
            Group {
                if let value = text.wrappedValue {
                    SnackBarView(text: value, duration: duration) {
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
