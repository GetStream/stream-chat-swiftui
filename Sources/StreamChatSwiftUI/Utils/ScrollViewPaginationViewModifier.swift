//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Foundation
import SwiftUI

private struct ScrollViewPaginationViewModifier: ViewModifier {
    let coordinateSpace: CoordinateSpace
    let flipped: Bool
    let threshold: CGFloat
    let onBottomThreshold: () -> Void
    let onTopThreshold: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onChange(of: geometry.frame(in: coordinateSpace)) { _ in
                            handleGeometryChanged(geometry)
                        }
                }
            )
    }
    
    func handleGeometryChanged(_ geometry: GeometryProxy) {
        let frame = geometry.frame(in: coordinateSpace)
        guard frame.size.height > 0 else { return }
        let offset = -frame.minY
        if offset + UIScreen.main.bounds.height + threshold > frame.height {
            flipped ? onTopThreshold?() : onBottomThreshold()
        } else if offset < threshold {
            flipped ? onBottomThreshold() : onTopThreshold?()
        }
    }
}

extension View {
    func onScrollPaginationChanged(
        in coordinateSpace: CoordinateSpace = .global,
        flipped: Bool = false,
        threshold: CGFloat = 400,
        onBottomThreshold: @escaping () -> Void,
        onTopThreshold: (() -> Void)? = nil
    ) -> some View {
        modifier(
            ScrollViewPaginationViewModifier(
                coordinateSpace: coordinateSpace,
                flipped: flipped,
                threshold: threshold,
                onBottomThreshold: onBottomThreshold,
                onTopThreshold: onTopThreshold
            )
        )
    }
}
