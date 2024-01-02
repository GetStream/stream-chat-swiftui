//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

extension InjectedValues {
    /// Provides access to the `ChatClient` instance.
    public var chatClient: ChatClient {
        get {
            streamChat.chatClient
        }
        set {
            streamChat.chatClient = newValue
        }
    }

    /// Provides access to the `ColorPalette` instance.
    public var colors: ColorPalette {
        get {
            streamChat.appearance.colors
        }
        set {
            streamChat.appearance.colors = newValue
        }
    }

    /// Provides access to the `Utils` instance.
    public var utils: Utils {
        get {
            streamChat.utils
        }
        set {
            streamChat.utils = newValue
        }
    }

    /// Provides access to the `Images` instance.
    public var images: Images {
        get {
            streamChat.appearance.images
        }
        set {
            streamChat.appearance.images = newValue
        }
    }

    /// Provides access to the `Fonts` instance.
    public var fonts: Fonts {
        get {
            streamChat.appearance.fonts
        }
        set {
            streamChat.appearance.fonts = newValue
        }
    }
}
