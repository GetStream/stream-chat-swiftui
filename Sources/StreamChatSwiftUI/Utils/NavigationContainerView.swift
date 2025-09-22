//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Reusable container view to handle the navigation container logic.
struct NavigationContainerView<Content: View>: View {
    @Injected(\.colors) var colors
    var embedInNavigationView: Bool = true
    var content: () -> Content

    var body: some View {
        if embedInNavigationView == true {
            if #available(iOS 16, *), isIphone {
                NavigationStack {
                    content()
                }
                .accentColor(colors.navigationBarTintColor)
            } else {
                NavigationView {
                    content()
                }
                .accentColor(colors.navigationBarTintColor)
            }
        } else {
            content()
        }
    }
}
