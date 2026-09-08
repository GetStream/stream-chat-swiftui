//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

private struct StreamLiquidGlassEffectsEnabledKey: EnvironmentKey {
    static let defaultValue = true
}

extension EnvironmentValues {
    var streamLiquidGlassEffectsEnabled: Bool {
        get { self[StreamLiquidGlassEffectsEnabledKey.self] }
        set { self[StreamLiquidGlassEffectsEnabledKey.self] = newValue }
    }
}
