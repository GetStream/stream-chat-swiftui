//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import StreamChatSwiftUI

final class AppConfiguration {
    static let `default` = AppConfiguration()
    
    /// The translation language to set on connect.
    var translationLanguage: TranslationLanguage?
    /// A flag indicating whether the channel pinning feature is enabled.
    var isChannelPinningFeatureEnabled = false
}
