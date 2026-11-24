//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// A sheet as tall as its content, from the `Core / iOS / Sheet` component. Its header has a close button, a title and
/// an optional confirm button.
struct SheetView<Content: View>: View {
    private static var headerMinHeight: CGFloat { 72 }

    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens

    @State private var contentHeight: CGFloat?

    /// The title of the header. Without a title, the sheet has no header from iOS 16 on, where it has a grabber.
    let title: String?
    /// The height used until the content is measured, so the sheet doesn't open at a different height first.
    let estimatedContentHeight: CGFloat
    /// Called when the close button is tapped.
    let onClose: @MainActor () -> Void
    /// Called when the confirm button is tapped. Without it, the header has no confirm button.
    var onConfirm: (@MainActor () -> Void)?
    /// Whether the confirm button is disabled.
    var confirmDisabled = false
    /// The content under the header.
    @ViewBuilder let content: () -> Content

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if let headerTitle {
                    header(title: headerTitle)
                } else {
                    Color.clear.frame(height: tokens.spacingXl)
                }
                content()
            }
            .padding(.bottom, tokens.spacingMd)
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear { contentHeight = proxy.size.height }
                        .onChange(of: proxy.size.height) { contentHeight = $0 }
                }
            )
        }
        .background(Color(colors.backgroundCoreElevation1).edgesIgnoringSafeArea(.all))
        .modifier(PresentationDetentsModifier(sheetSizes: [.custom(contentHeight ?? estimatedHeight)]))
        .compatibility.presentationDragIndicatorVisible()
    }

    private func header(title: String) -> some View {
        ZStack {
            Text(title)
                .font(fonts.bodyBold)
                .foregroundColor(Color(colors.textPrimary))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, tokens.buttonHitTargetMinWidth + tokens.spacingSm)
                .accessibilityAddTraits(.isHeader)

            HStack {
                StreamIconButton(role: .secondary, style: .outline, size: .medium, action: onClose) {
                    Image(uiImage: images.close)
                        .renderingMode(.template)
                        .frame(width: tokens.iconSizeMd, height: tokens.iconSizeMd)
                }
                .accessibilityLabel(Text(L10n.Alert.Actions.cancel))
                .accessibilityIdentifier("SheetHeaderCloseButton")

                Spacer()

                if let onConfirm {
                    StreamIconButton(role: .primary, style: .solid, size: .medium, action: onConfirm) {
                        Image(uiImage: images.whiteCheckmark)
                            .customizable()
                            .frame(width: tokens.iconSizeMd, height: tokens.iconSizeMd)
                    }
                    .disabled(confirmDisabled)
                    .accessibilityLabel(Text(title))
                    .accessibilityIdentifier("SheetHeaderConfirmButton")
                }
            }
        }
        .padding(.horizontal, tokens.spacingMd)
        // Keeps a title that wraps at large text sizes away from the drag indicator.
        .padding(.vertical, tokens.spacingSm)
        .frame(maxWidth: .infinity, minHeight: Self.headerMinHeight)
    }

    private var estimatedHeight: CGFloat {
        (headerTitle == nil ? tokens.spacingXl : Self.headerMinHeight) + estimatedContentHeight + tokens.spacingMd
    }

    // Before iOS 16 a sheet covers the screen and has no grabber, so it keeps the header with the close button.
    private var headerTitle: String? {
        if #available(iOS 16.0, *) {
            title
        } else {
            title ?? ""
        }
    }
}
