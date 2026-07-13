//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChat

extension Role {
    static func mock(
        name: String,
        custom: Bool = false,
        scopes: [String] = [],
        createdAt: Date = .init(),
        updatedAt: Date = .init()
    ) -> Role {
        Role(
            createdAt: createdAt,
            custom: custom,
            name: name,
            scopes: scopes,
            updatedAt: updatedAt
        )
    }
}
