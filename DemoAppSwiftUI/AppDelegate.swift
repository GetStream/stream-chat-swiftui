//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import Sentry
import StreamChat
import StreamChatSwiftUI
import SwiftUI
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {

    var streamChat: StreamChat?

    var chatClient: ChatClient = {
        var config = ChatClientConfig(apiKey: .init(apiKeyString))
        config.isLocalStorageEnabled = true
        config.applicationGroupIdentifier = applicationGroupIdentifier

        let client = ChatClient(config: config)
        return client
    }()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
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

        #if RELEASE
        // We're tracking Crash Reports / Issues from the Demo App to keep improving the SDK
        SentrySDK.start { options in
            options.dsn = "https://00e1d4e0213541d2b103ea252b77f120@o389650.ingest.sentry.io/6395489"
            options.tracesSampleRate = 1.0
        }
        #endif

        let utils = Utils(
            messageListConfig: MessageListConfig(dateIndicatorPlacement: .messageList)
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
        
        let credentials = UnsecureRepository.shared.loadCurrentUser()
        if let credentials, let token = try? Token(rawValue: credentials.token) {
            chatClient.connectUser(
                userInfo: .init(
                    id: credentials.id,
                    name: credentials.name,
                    imageURL: credentials.avatarURL
                ),
                token: token
            )
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                if AppState.shared.userState == .launchAnimation {
                    AppState.shared.userState = credentials == nil ? .notLoggedIn : .loggedIn
                }
            }
        }

        UNUserNotificationCenter.current().delegate = NotificationsHandler.shared

        return true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        guard let currentUserId = chatClient.currentUserId else {
            log.warning("cannot add the device without connecting as user first, did you call connectUser")
            return
        }

        chatClient.currentUserController().addDevice(.apn(token: deviceToken)) { error in
            if let error = error {
                log.error("adding a device failed with an error \(error)")
                return
            }
            UserDefaults(suiteName: applicationGroupIdentifier)?.set(
                currentUserId,
                forKey: currentUserIdRegisteredForPush
            )
        }
    }
}

extension UIColor {
    static let streamBlue = UIColor(red: 0, green: 108.0 / 255.0, blue: 255.0 / 255.0, alpha: 1)
}
