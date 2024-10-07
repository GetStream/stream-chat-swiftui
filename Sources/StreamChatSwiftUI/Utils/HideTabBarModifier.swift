//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct HideTabBarModifier: ViewModifier {
    let handleTabBarVisibility: Bool

    var shouldHandleTabBarVisibility: Bool {
        isIphone && handleTabBarVisibility
    }

    func body(content: Content) -> some View {
        if shouldHandleTabBarVisibility, #available(iOS 16.0, *) {
            content
                .toolbar(.hidden, for: .tabBar)
        } else if shouldHandleTabBarVisibility {
            content
                .onAppear {
                    UITabBar.appearance().isHidden = true
                }
                .onDisappear {
                    UITabBar.appearance().isHidden = false
                }
        } else {
            content
        }
    }
}
