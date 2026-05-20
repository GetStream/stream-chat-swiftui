//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import StreamChatSwiftUI

final class AppConfiguration {
    @MainActor static let `default` = AppConfiguration()

    /// The translation language to set on connect.
    var translationLanguage: TranslationLanguage?
    /// A flag indicating whether the channel pinning feature is enabled.
    var isChannelPinningFeatureEnabled = false
    /// Reactions display style in the message list (clustered vs segmented).
    var reactionsStyle: ReactionsStyle = .segmented
    /// Reactions placement relative to the message (top or bottom).
    var reactionsPlacement: ReactionsPlacement = .top
    /// The visual style used across the app (regular or liquid glass).
    var appStyle: AppStyle = .regular
    /// When enabled, releasing a hold-to-record gesture sends the voice message instantly.
    var isVoiceRecordingAutoSendEnabled = false

    enum AppStyle: String, CaseIterable {
        case regular
        case liquidGlass
    }

    /// Builds the demo app's `ComposerConfig` using current app configuration.
    @MainActor static func makeComposerConfig() -> ComposerConfig {
        ComposerConfig(
            isVoiceRecordingAutoSendEnabled: AppConfiguration.default.isVoiceRecordingAutoSendEnabled
        )
    }

    /// Builds the demo app's `MessageListConfig` using current app configuration.
    @MainActor static func makeMessageListConfig() -> MessageListConfig {
        MessageListConfig(
            messageDisplayOptions: MessageDisplayOptions(
                reactionsPlacement: AppConfiguration.default.reactionsPlacement,
                reactionsStyle: AppConfiguration.default.reactionsStyle
            ),
            skipEditedMessageLabel: { message in
                message.extraData["ai_generated"]?.boolValue == true
            }
        )
    }
}
