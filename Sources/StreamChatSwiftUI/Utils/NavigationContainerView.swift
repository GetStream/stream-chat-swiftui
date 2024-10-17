//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Reusable container view to handle the navigation container logic.
struct NavigationContainerView<Content: View>: View {
    var embedInNavigationView: Bool
    var content: () -> Content

    var body: some View {
        if embedInNavigationView == true {
            if #available(iOS 16, *), isIphone {
                NavigationStack {
                    content()
                }
            } else {
                NavigationView {
                    content()
                }
            }
        } else {
            content()
        }
    }
}
