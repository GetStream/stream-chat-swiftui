//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import CoreGraphics

public extension CGSize {
    /// Maximum size of avatar used in the UI.
    ///
    /// It's better to use single size of avatar thumbnail to utilise the cache.
    static var avatarThumbnailSize: CGSize { CGSize(width: 40, height: 40) }
}
