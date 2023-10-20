//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

protocol UserRepository {
    
    func save(user: UserCredentials)
        
    func loadCurrentUser() -> UserCredentials?
    
    func removeCurrentUser()
}

// NOTE: This is just for simplicity. User data shouldn't be kept in `UserDefaults`.
final class UnsecureRepository: UserRepository {
    enum Key: String, CaseIterable {
        case user = "stream.chat.user"
    }

    private let defaults: UserDefaults

    private init(defaults: UserDefaults = UserDefaults.standard) {
        self.defaults = defaults
    }

    private func set(_ value: Any?, for key: Key) {
        defaults.set(value, forKey: key.rawValue)
    }

    private func get<T>(for key: Key) -> T? {
        defaults.object(forKey: key.rawValue) as? T
    }
    
    static let shared = UnsecureRepository()

    func save(user: UserCredentials) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(user) {
            set(encoded, for: .user)
        }
    }

    func loadCurrentUser() -> UserCredentials? {
        if let savedUser: Data = get(for: .user) {
            let decoder = JSONDecoder()
            do {
                let loadedUser = try decoder.decode(UserCredentials.self, from: savedUser)
                return loadedUser
            } catch {
                log.error("Error while decoding user")
            }
        }
        return nil
    }
    
    func removeCurrentUser() {
        defaults.set(nil, forKey: Key.user.rawValue)
    }
}
