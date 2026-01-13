//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChatCommonUI
import SwiftUI

// MARK: - Appearance + Default

public extension Appearance {
    static let `default`: Appearance = .init()
}

/// Provides the default value of the `Appearance` class.
public struct AppearanceKey: EnvironmentKey {
    public static var defaultValue: Appearance { StreamConcurrency.onMain { Appearance() } }
}

extension EnvironmentValues {
    /// Provides access to the `Appearance` class to the views and view models.
    public var appearance: Appearance {
        get {
            self[AppearanceKey.self]
        }
        set {
            self[AppearanceKey.self] = newValue
        }
    }
}
