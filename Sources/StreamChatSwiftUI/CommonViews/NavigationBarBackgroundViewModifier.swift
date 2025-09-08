//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import SwiftUI

extension View {
    /// Sets background color to navigation bar if ``ColorPalette.navigationBarBackground`` is set.
    func navigationBarBackground() -> some View {
        modifier(NavigationBarBackgroundViewModifier())
    }
}

private struct NavigationBarBackgroundViewModifier: ViewModifier {
    @Injected(\.colors) var colors
    
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *), let background = colors.navigationBarBackground {
            content
                .toolbarBackground(Color(background), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
            
        } else {
            content
        }
    }
}
