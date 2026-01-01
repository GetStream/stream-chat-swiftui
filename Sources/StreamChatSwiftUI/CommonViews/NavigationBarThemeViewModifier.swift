//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

extension View {
    public nonisolated func toolbarThemed<Content>(@ToolbarContentBuilder content toolbarContent: @escaping () -> Content) -> some View where Content: ToolbarContent {
        modifier(NavigationBarThemeViewModifier(toolbarContent: toolbarContent))
    }
}

private struct NavigationBarThemeViewModifier<T: ToolbarContent>: ViewModifier {
    @Injected(\.colors) var colors
    
    let toolbarContent: () -> T
    
    func body(content: Content) -> some View {
        content
            .accentColor(colors.tintColor)
            .modifier(NavigationBarBackgroundViewModifier())
            .toolbar {
                toolbarContent()
            }
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
