//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI
import UIKit

class NotificationsHandler: NSObject, UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        defer {
            completionHandler()
        }

        guard let notificationInfo = try? ChatPushNotificationInfo(content: response.notification.request.content) else {
            return
        }

        guard let cid = notificationInfo.cid else {
            return
        }

        guard case UNNotificationDefaultActionIdentifier = response.actionIdentifier else {
            return
        }
        
        if let userId = UserDefaults(suiteName: applicationGroupIdentifier)?.string(forKey: currentUserIdRegisteredForPush),
           let userCredentials = UserCredentials.builtInUsersByID(id: userId) {
            // presentChat(userCredentials: userCredentials, channelID: cid)
        }
    }
    
    func setupRemoteNotifications() {
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
    }
}
