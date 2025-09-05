//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import SwiftUI

private struct TintedToolbarViewModifier<T: ToolbarContent>: ViewModifier {
    @Injected(\.colors) var colors
    let toolbarContent: () -> T
    
    init(
        @ToolbarContentBuilder content: @escaping () -> T
    ) {
        toolbarContent = content
    }
    
    func body(content: Content) -> some View {
        content
            .accentColor(colors.tintColor)
            .toolbar {
                toolbarContent()
            }
            // The whole toolbar requires it for supporting tint colors for system managed back buttons
            .accentColor(colors.navigationTintColor)
    }
}

extension View {
    func tintedToolbar<Content>(@ToolbarContentBuilder _ content: @escaping () -> Content) -> some View where Content: ToolbarContent {
        modifier(TintedToolbarViewModifier(content: content))
    }
}
