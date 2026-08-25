//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

extension Compatibility where Content: View {
    @ViewBuilder
    func scrollEdgeEffectHidden(_ hidden: Bool, for edges: Edge.Set) -> some View {
        #if os(iOS) && compiler(>=6.3)
        if #available(iOS 27.0, *) {
            content.scrollEdgeEffectHidden(hidden, for: edges)
        } else {
            content
        }
        #else
        content
        #endif
    }
}
