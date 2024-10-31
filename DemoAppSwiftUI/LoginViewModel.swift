//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

class LoginViewModel: ObservableObject {

    @Published var demoUsers = UserCredentials.builtInUsers
    @Published var loading = false

    @Injected(\.chatClient) var chatClient

    func demoUserTapped(_ user: UserCredentials) {
        if user.isGuest {
            connectGuestUser(withCredentials: user)
            return
        }

        connectUser(withCredentials: user)
    }

    private func connectUser(withCredentials credentials: UserCredentials) {
        loading = true
        let token = try! Token(rawValue: credentials.token)
        LogConfig.level = .warning

        chatClient.connectUser(
            userInfo: .init(id: credentials.id, name: credentials.name, imageURL: credentials.avatarURL),
            token: token
        ) { [weak self] error in
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

    private func connectGuestUser(withCredentials credentials: UserCredentials) {
        loading = true
        LogConfig.level = .warning

        chatClient.connectGuestUser(
            userInfo: .init(id: credentials.id, name: credentials.name)
        ) { [weak self] error in
            if let error = error {
                log.error("connecting the user failed \(error)")
                return
            }

            DispatchQueue.main.async { [weak self] in
                withAnimation {
                    self?.loading = false
                    AppState.shared.userState = .loggedIn
                }
            }
        }
    }
}
