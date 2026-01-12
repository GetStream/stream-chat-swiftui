//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

public struct LazyView<Content: View>: View {
    private let build: () -> Content

    public init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }

    public var body: Content {
        build()
    }
}
