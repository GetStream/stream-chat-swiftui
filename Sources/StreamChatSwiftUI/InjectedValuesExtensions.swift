//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

extension InjectedValues {
    /// Provides access to the `ChatClient` instance.
    public var chatClient: ChatClient {
        get {
            MainActor.ensureIsolated { [streamChat] in streamChat.chatClient }
        }
        set {
            MainActor.ensureIsolated { [streamChat] in streamChat.chatClient = newValue }
        }
    }

    /// Provides access to the `ColorPalette` instance.
    public var colors: ColorPalette {
        get {
            MainActor.ensureIsolated { [streamChat] in streamChat.appearance.colors }
        }
        set {
            MainActor.ensureIsolated { [streamChat] in streamChat.appearance.colors = newValue }
        }
    }

    /// Provides access to the `Utils` instance.
    public var utils: Utils {
        get {
            MainActor.ensureIsolated { [streamChat] in streamChat.utils }
        }
        set {
            MainActor.ensureIsolated { [streamChat] in streamChat.utils = newValue }
        }
    }

    /// Provides access to the `Images` instance.
    public var images: Images {
        get {
            MainActor.ensureIsolated { [streamChat] in streamChat.appearance.images }
        }
        set {
            MainActor.ensureIsolated { [streamChat] in streamChat.appearance.images = newValue }
        }
    }

    /// Provides access to the `Fonts` instance.
    public var fonts: Fonts {
        get {
            MainActor.ensureIsolated { [streamChat] in streamChat.appearance.fonts }
        }
        set {
            MainActor.ensureIsolated { [streamChat] in streamChat.appearance.fonts = newValue }
        }
    }
}
