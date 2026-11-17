//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// A sheet with a header, which is as tall as its content.
///
/// Part of the design system, where it is the `Core / iOS / Sheet` component.
/// Use it as the root view of a `sheet` presentation and put the rows into `content`.
///
/// ```swift
/// .sheet(isPresented: $isPresented) {
///     SheetView(title: "Schedule message", estimatedContentHeight: 96, onClose: { isPresented = false }) {
///         ListItemView(icon: icon, title: "Tomorrow at 9:00 AM")
///     }
/// }
/// ```
struct SheetView<Content: View>: View {
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    @State private var contentHeight: CGFloat?

    /// The title shown in the header.
    let title: String
    /// The height of `content`, used until the content is measured, so the sheet doesn't open at a different height first.
    let estimatedContentHeight: CGFloat
    /// Called when the close button in the header is tapped.
    let onClose: @MainActor () -> Void
    /// Called when the confirm button is tapped. The header has no confirm button when it is `nil`.
    var onConfirm: (@MainActor () -> Void)?
    /// The content below the header, for example a list of `ListItemView` rows.
    @ViewBuilder let content: () -> Content

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                SheetHeaderView(title: title, onClose: onClose, onConfirm: onConfirm)
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
        .compatibility.presentationDetents([.custom(contentHeight ?? estimatedHeight)])
        .compatibility.presentationDragIndicatorVisible()
    }

    private var estimatedHeight: CGFloat {
        SheetHeaderView.minHeight + estimatedContentHeight + tokens.spacingMd
    }
}
