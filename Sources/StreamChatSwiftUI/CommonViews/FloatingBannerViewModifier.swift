//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI

extension View {
    @ViewBuilder
    func topBanner(isPresented: Bool, _ bannerView: @escaping () -> some View) -> some View {
        modifier(
            FloatingBannerViewModifier(
                isPresented: isPresented,
                alignment: .top,
                bannerView
            )
        )
    }

    @ViewBuilder
    func bottomBanner(isPresented: Bool, _ bannerView: @escaping () -> some View) -> some View {
        modifier(
            FloatingBannerViewModifier(
                isPresented: isPresented,
                alignment: .bottom,
                bannerView
            )
        )
    }
}

struct FloatingBannerViewModifier<BannerView: View>: ViewModifier {
    let alignment: Alignment
    var isPresented: Bool

    @ViewBuilder
    let bannerView: () -> BannerView

    init(
        isPresented: Bool,
        alignment: Alignment = .bottom,
        _ bannerView: @escaping () -> BannerView
    ) {
        self.alignment = alignment
        self.isPresented = isPresented
        self.bannerView = bannerView
    }

    func body(content: Content) -> some View {
        ZStack(alignment: alignment) {
            content
            if isPresented {
                bannerView()
            }
        }
    }
}
