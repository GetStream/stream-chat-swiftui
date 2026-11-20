//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct SheetView<Content: View>: View {
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    @State private var contentHeight: CGFloat?

    let title: String?
    // Used until the content is measured, so the sheet doesn't open at a different height first.
    let estimatedContentHeight: CGFloat
    let onClose: @MainActor () -> Void
    var onConfirm: (@MainActor () -> Void)?
    var confirmDisabled = false
    var confirmAccessibilityLabel: String?
    @ViewBuilder let content: () -> Content

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if let headerTitle {
                    SheetHeaderView(
                        title: headerTitle,
                        onClose: onClose,
                        onConfirm: onConfirm,
                        confirmDisabled: confirmDisabled,
                        confirmAccessibilityLabel: confirmAccessibilityLabel
                    )
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

    private var estimatedHeight: CGFloat {
        (headerTitle == nil ? tokens.spacingXl : SheetHeaderView.minHeight) + estimatedContentHeight + tokens.spacingMd
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
