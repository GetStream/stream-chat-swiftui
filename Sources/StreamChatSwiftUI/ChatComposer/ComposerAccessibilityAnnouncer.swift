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
    static let announcementDelay: TimeInterval = 0.5

    static func announce(_ message: String) {
        guard !message.isEmpty else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + announcementDelay) {
            post(message)
        }
    }

    private static func post(_ message: String) {
        if #available(iOS 17, *) {
            AccessibilityNotification.Announcement(message).post()
        } else {
            UIAccessibility.post(notification: .announcement, argument: message)
        }
    }
}
