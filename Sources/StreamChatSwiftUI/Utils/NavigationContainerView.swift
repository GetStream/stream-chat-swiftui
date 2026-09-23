//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

private struct ChatNavigationSplitViewKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var isInChatNavigationSplitView: Bool {
        get { self[ChatNavigationSplitViewKey.self] }
        set { self[ChatNavigationSplitViewKey.self] = newValue }
    }
}

/// Reusable container view to handle the navigation container logic.
struct NavigationContainerView<Content: View>: View {
    @Injected(\.colors) var colors
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var embedInNavigationView: Bool = true
    var content: () -> Content

    var body: some View {
        if embedInNavigationView == true {
            if #available(iOS 16, *), horizontalSizeClass != .regular {
                NavigationStack {
                    content()
                }
                .accentColor(Color(colors.navigationBarTintColor))
            } else {
                NavigationView {
                    content()
                }
                .accentColor(Color(colors.navigationBarTintColor))
            }
        } else {
            content()
        }
    }
}
