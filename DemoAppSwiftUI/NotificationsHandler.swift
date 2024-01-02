//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI
import UIKit

/// Handles push notifications in the demo app.
/// When a notification is received, the channel id is extracted from the notification object.
/// The code below shows an example how to use it to navigate directly to the corresponding screen.
class NotificationsHandler: NSObject, ObservableObject, UNUserNotificationCenterDelegate {

    @Injected(\.chatClient) private var chatClient

    @Published var notificationChannelId: String?

    static let shared = NotificationsHandler()

    override private init() {}

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

        if AppState.shared.userState == .loggedIn {
            notificationChannelId = cid.description
        } else if let userId = UserDefaults(suiteName: applicationGroupIdentifier)?.string(forKey: currentUserIdRegisteredForPush),
                  let userCredentials = UserCredentials.builtInUsersByID(id: userId),
                  let token = try? Token(rawValue: userCredentials.token) {
            loginAndNavigateToChannel(
                userCredentials: userCredentials,
                token: token,
                cid: cid
            )
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

    private func loginAndNavigateToChannel(
        userCredentials: UserCredentials,
        token: Token,
        cid: ChannelId
    ) {
        let userInfo: UserInfo = .init(
            id: userCredentials.id,
            name: userCredentials.name,
            imageURL: userCredentials.avatarURL
        )
        chatClient.connectUser(userInfo: userInfo, token: token) { [weak self] error in
            if error != nil {
                log.debug("Error logging in")
                return
            }

            DispatchQueue.main.async {
                AppState.shared.userState = .loggedIn
                self?.notificationChannelId = cid.description
            }
        }
    }
}
