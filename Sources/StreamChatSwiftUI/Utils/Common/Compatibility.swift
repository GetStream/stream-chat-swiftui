//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct Compatibility<Content> {
    let content: Content
    
    init(_ content: Content) {
        self.content = content
    }
}

extension View {
    var compatibility: Compatibility<Self> { Compatibility(self) }
}
