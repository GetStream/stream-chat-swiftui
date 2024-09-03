//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
    /// Delays rendering the content to the next run loop.
    ///
    /// - Important: This is used to workaround `FB15010770` where pushing a `LazyVStack` to `NavigationStack` causes the `LazyVStack` to load views using the height of the `UIScreen.main`, not the destination height.
    func delayedRendering() -> some View {
        modifier(DelayedRenderingViewModifier())
    }
}

struct DelayedRenderingViewModifier: ViewModifier {
    static var isEnabled = true
    @State private var canShowContent = Self.isEnabled ? false : true
    
    func body(content: Content) -> some View {
        if canShowContent {
            content
        } else {
            Color.clear
                .onAppear {
                    Task { @MainActor in
                        canShowContent = true
                    }
                }
        }
    }
}
