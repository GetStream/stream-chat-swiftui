//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// An object containing visual configuration for the whole application.
public class Appearance {
    public var colors: ColorPalette
    public var images: Images
    public var fonts: Fonts

    public init(
        colors: ColorPalette = ColorPalette(),
        images: Images = Images(),
        fonts: Fonts = Fonts()
    ) {
        self.colors = colors
        self.images = images
        self.fonts = fonts
    }

    /// Provider for custom localization which is dependent on App Bundle.
    public static var localizationProvider: (_ key: String, _ table: String) -> String = { key, table in
        Bundle.streamChatUI.localizedString(forKey: key, value: nil, table: table)
    }
}

// MARK: - Appearance + Default

public extension Appearance {
    static var `default`: Appearance = .init()
}

/// Provides the default value of the `Appearance` class.
public struct AppearanceKey: EnvironmentKey {
    public static let defaultValue: Appearance = Appearance()
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
