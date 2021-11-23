//
//  Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SwiftUI
import StreamChat
import StreamChatSwiftUI

class LoginViewModel: ObservableObject {
    
    @Published var demoUsers = UserCredentials.builtInUsers
    
    @Injected(\.chatClient) var chatClient
    
    func demoUserTapped(_ user: UserCredentials) {
        connectUser(withCredentials: user)
    }
    
    private func connectUser(withCredentials credentials: UserCredentials) {
        let token = try! Token(rawValue: credentials.token)
        LogConfig.level = .warning
         
        chatClient.connectUser(
                userInfo: .init(id: credentials.id, name: credentials.name, imageURL: credentials.avatarURL),
                token: token
        ) { error in
            if let error = error {
                log.error("connecting the user failed \(error)")
                return
            }
            
            DispatchQueue.main.async {
                AppState.shared.userState = .loggedIn
            }            
        }
    }
    
}
