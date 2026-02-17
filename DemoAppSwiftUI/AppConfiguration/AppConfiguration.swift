//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Combine
import Foundation
import StreamChat
import StreamChatSwiftUI

final class AppConfiguration: ObservableObject {
    static let `default` = AppConfiguration()

    /// The translation language to set on connect.
    var translationLanguage: TranslationLanguage?
    /// A flag indicating whether the channel pinning feature is enabled.
    @Published var isChannelPinningFeatureEnabled = false
    /// Force RTL layout for preview (e.g. demo app).
    @Published var forceRTL = false
}
