//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI
import UIKit

/// Helper for posting VoiceOver announcements from composer-related views.
///
/// Uses the SwiftUI-friendly `AccessibilityNotification` API on iOS 17+, with a
/// `UIAccessibility` fallback for older systems. A small delay gives appearance
/// animations time to settle before the announcement is read out.
@MainActor
enum ComposerAccessibilityAnnouncer {
    /// The kind of VoiceOver notification to post.
    enum Kind {
        /// Reads the message without moving VoiceOver focus. Use for ambient
        /// updates (e.g. "Mentions list opened").
        case announcement
        /// Reads the message and lets VoiceOver refocus on the new screen.
        /// Use when presenting a sheet or pushing a new view.
        case screenChanged
    }

    static let announcementDelay: TimeInterval = 0.5

    static func announce(_ message: String, kind: Kind = .announcement) {
        guard !message.isEmpty else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + announcementDelay) {
            post(message, kind: kind)
        }
    }

    private static func post(_ message: String, kind: Kind) {
        if #available(iOS 17, *) {
            switch kind {
            case .announcement:
                AccessibilityNotification.Announcement(message).post()
            case .screenChanged:
                AccessibilityNotification.ScreenChanged(message).post()
            }
        } else {
            let notification: UIAccessibility.Notification = {
                switch kind {
                case .announcement: return .announcement
                case .screenChanged: return .screenChanged
                }
            }()
            UIAccessibility.post(notification: notification, argument: message)
        }
    }
}
