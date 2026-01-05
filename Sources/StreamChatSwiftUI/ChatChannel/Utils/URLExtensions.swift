//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation

extension URL {
    var secureURL: URL? {
        let secureScheme = "https"

        guard
            scheme != secureScheme,
            var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        else {
            return self
        }

        components.scheme = secureScheme

        return components.url
    }
}
