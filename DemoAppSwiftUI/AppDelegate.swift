//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import UIKit
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    
    var streamChat: StreamChat?
    
    var chatClient: ChatClient = {
        var config = ChatClientConfig(apiKey: .init(apiKeyString))
        //config.isLocalStorageEnabled = true
        config.applicationGroupIdentifier = applicationGroupIdentifier

        let client = ChatClient(config: config)
        return client
    }()
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        /*
        //Customizations, uncomment to customize.
        var colors = ColorPalette()
        colors.tintColor = Color(.streamBlue)
        
        var fonts = Fonts()
        fonts.footnoteBold = Font.footnote
        
        let images = Images()
        images.reactionLoveBig = UIImage(systemName: "heart.fill")!
        
        let appearance = Appearance(colors: colors, images: images, fonts: fonts)
        
        let channelNamer: ChatChannelNamer = { channel, currentUserId in
            "This is our custom name: \(channel.name ?? "no name")"
        }
        let utils = Utils(channelNamer: channelNamer)
         
        streamChat = StreamChat(chatClient: chatClient, appearance: appearance, utils: utils)

        */
        
        /*
        let messageTypeResolver = CustomMessageTypeResolver()
        let utils = Utils(messageTypeResolver: messageTypeResolver)
         
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
        */
        
        streamChat = StreamChat(chatClient: chatClient)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            AppState.shared.userState = .notLoggedIn
        }
        
        return true
    }
    
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }
    
}

extension UIColor {
    static let streamBlue = UIColor(red: 0, green: 108.0 / 255.0, blue: 255.0 / 255.0, alpha: 1)
}

