//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

extension Compatibility where Content: View {
    func scrollEdgeEffectHidden(_ hidden: Bool, for edges: Edge.Set) -> some View {
        content.modifier(ScrollEdgeEffectHiddenViewModifier(hidden: hidden, edges: edges))
    }
}

// A modifier keeps the `AnyView` from the `#available` check out of the modified view's type.
private struct ScrollEdgeEffectHiddenViewModifier: ViewModifier {
    let hidden: Bool
    let edges: Edge.Set

    func body(content: Content) -> some View {
        #if os(iOS) && compiler(>=6.2)
        if #available(iOS 26.0, *) {
            content.scrollEdgeEffectHidden(hidden, for: edges)
        } else {
            content
        }
        #else
        content
        #endif
    }
}
