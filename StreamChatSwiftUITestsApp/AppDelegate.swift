//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    
    var streamChat: StreamChat?
    
    var chatClient: ChatClient = {
        var config = ChatClientConfig(apiKey: .init(apiKeyString))
        config.isLocalStorageEnabled = true
        config.applicationGroupIdentifier = applicationGroupIdentifier

        let client = ChatClient(config: config)
        return client
    }()
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        disableAnimations()
        connectUser(withCredentials: UserCredentials.mock)
        return true
    }
    
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }
    

    private func connectUser(withCredentials credentials: UserCredentials) {
        let token = try! Token(rawValue: credentials.token)
        LogConfig.level = .warning
        
        streamChat = StreamChat(chatClient: chatClient)
        
        chatClient.connectUser(
                userInfo: .init(id: credentials.id, name: credentials.name, imageURL: credentials.avatarURL),
                token: token
        ) { error in
            if let error = error {
                log.error("connecting the user failed \(error)")
                return
            }
        }
    }
    
    private func disableAnimations() {
        UIApplication.shared.keyWindow?.layer.speed = 2
        UIView.setAnimationsEnabled(false)
    }
    
}

extension UIColor {
    static let streamBlue = UIColor(red: 0, green: 108.0 / 255.0, blue: 255.0 / 255.0, alpha: 1)
}

class SceneDelegate: NSObject, UIWindowSceneDelegate {}
