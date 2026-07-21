//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import StreamChatSwiftUI
import SwiftUI

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
    /// When enabled, messages start at the top of the list when there are few messages.
    var shouldMessagesStartAtTheTop = false
    /// Base directory used for Stream Chat attachment downloads.
    ///
    /// Applied when creating `ChatClient`, so changes take effect on the next app launch.
    var attachmentDownloadsDirectory: AttachmentDownloadsDirectory = .stored {
        didSet { AttachmentDownloadsDirectory.stored = attachmentDownloadsDirectory }
    }

    enum AppStyle: String, CaseIterable {
        case regular
        case liquidGlass
    }

    /// Common sandbox locations for storing downloaded attachments.
    enum AttachmentDownloadsDirectory: String, CaseIterable, Identifiable {
        case documents
        case applicationSupport
        case caches

        private static let userDefaultsKey = "demo.attachmentDownloadsDirectory"

        var id: String { rawValue }

        var title: String {
            switch self {
            case .documents:
                return "Documents"
            case .applicationSupport:
                return "Application Support"
            case .caches:
                return "Caches"
            }
        }

        var subtitle: String {
            switch self {
            case .documents:
                return "User-visible, included in backups"
            case .applicationSupport:
                return "Hidden, included in backups"
            case .caches:
                return "Hidden, excluded from backups"
            }
        }

        /// Persisted selection used when building `ChatClientConfig`.
        static var stored: AttachmentDownloadsDirectory {
            get {
                guard let rawValue = UserDefaults.standard.string(forKey: userDefaultsKey),
                      let value = Self(rawValue: rawValue) else {
                    return .documents
                }
                return value
            }
            set {
                UserDefaults.standard.set(newValue.rawValue, forKey: userDefaultsKey)
            }
        }

        var folderURL: URL? {
            let fileManager = FileManager.default
            switch self {
            case .documents:
                return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            case .applicationSupport:
                return fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
                    .appendingPathComponent("io.getstream.StreamChat", isDirectory: true)
            case .caches:
                return fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first?
                    .appendingPathComponent("io.getstream.StreamChat", isDirectory: true)
            }
        }
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
            },
            videoAttachmentCachingPolicy: VideoAttachmentCachingPolicy(maxCacheSize: 100 * 1024 * 1024),
            shouldMessagesStartAtTheTop: AppConfiguration.default.shouldMessagesStartAtTheTop
        )
    }

    /// Builds the demo app's `CommandsConfig` using the enhanced mention suggestions provider.
    @MainActor static func makeCommandsConfig() -> CommandsConfig {
        EnhancedMentionsCommandsConfig()
    }
}
