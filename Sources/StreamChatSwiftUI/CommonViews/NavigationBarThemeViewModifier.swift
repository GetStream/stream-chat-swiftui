//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

extension View {
    public func toolbarThemed(@ToolbarContentBuilder content toolbarContent: @escaping () -> some ToolbarContent) -> some View {
        modifier(NavigationBarThemeViewModifier(toolbarContent: toolbarContent))
    }
}

private struct NavigationBarThemeViewModifier<T: ToolbarContent>: ViewModifier {
    @Injected(\.colors) var colors
    
    let toolbarContent: () -> T
    
    func body(content: Content) -> some View {
        content
            .accentColor(Color(colors.accentPrimary))
            .modifier(NavigationBarBackgroundViewModifier())
            .toolbar {
                toolbarContent()
            }
    }
}

private struct NavigationBarBackgroundViewModifier: ViewModifier {
    @Injected(\.colors) var colors
    
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .toolbarBackground(
                    Color(colors.navigationBarBackground ?? colors.backgroundElevationElevation1),
                    for: .navigationBar
                )
                .toolbarBackground(.visible, for: .navigationBar)
        } else {
            content
        }
    }
}
