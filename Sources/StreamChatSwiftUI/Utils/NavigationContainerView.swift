//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Reusable container view to handle the navigation container logic.
struct NavigationContainerView<Content: View>: View {
    @Injected(\.colors) var colors
    var embedInNavigationView: Bool
    var content: () -> Content

    var body: some View {
        if embedInNavigationView == true {
            if #available(iOS 16, *), isIphone {
                NavigationStack {
                    content()
                        .accentColor(colors.tintColor)
                        .navigationBarBackground()
                }
                // Tint for back and other system buttons
                .accentColor(colors.navigationBarTintColor)
            } else {
                NavigationView {
                    content()
                        .accentColor(colors.tintColor)
                        .navigationBarBackground()
                }
                .accentColor(colors.navigationBarTintColor)
            }
        } else {
            content()
        }
    }
}
