//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

class BlockedUsersViewModel: ObservableObject {
    
    @Injected(\.chatClient) var chatClient
    
    @Published var blockedUsers = [ChatUser]()
    
    private let currentUserController: CurrentChatUserController
    
    init() {
        currentUserController = InjectedValues[\.chatClient].currentUserController()
        currentUserController.synchronize()
    }
    
    func loadBlockedUsers() {
        let blockedUserIds = currentUserController.currentUser?.blockedUserIds ?? []
        for blockedUserId in blockedUserIds {
            if let user = currentUserController.dataStore.user(id: blockedUserId) {
                blockedUsers.append(user)
            } else {
                let controller = chatClient.userController(userId: blockedUserId)
                controller.synchronize { [weak self] _ in
                    if let user = controller.user {
                        self?.blockedUsers.append(user)
                    }
                }
            }
        }
    }
    
    func unblock(user: ChatUser) {
        let unblockController = chatClient.userController(userId: user.id)
        unblockController.unblock { [weak self] error in
            if error == nil {
                self?.blockedUsers.removeAll { blocked in
                    blocked.id == user.id
                }
            }
        }
    }
}
