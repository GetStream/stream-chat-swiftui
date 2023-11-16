//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

class LoginViewModel: ObservableObject {

    @Published var demoUsers = UserCredentials.builtInUsers
    @Published var loading = false

    @Injected(\.chatClient) var chatClient

    func demoUserTapped(_ user: UserCredentials) {
        connectUser(withCredentials: user)
    }

    private func connectUser(withCredentials credentials: UserCredentials) {
        loading = true
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

            DispatchQueue.main.async { [weak self] in
                withAnimation {
                    self?.loading = false
                    UnsecureRepository.shared.save(user: credentials)
                    AppState.shared.userState = .loggedIn
                }
            }
        }
    }
}
