//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import UIKit

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    func sceneWillResignActive(_ scene: UIScene) {
        if NotificationsHandler.shared.notificationChannelId != nil {
            NotificationsHandler.shared.notificationChannelId = nil
        }
    }
}
