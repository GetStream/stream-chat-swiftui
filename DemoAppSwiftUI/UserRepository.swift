//
// Copyright © 2026 Stream.io Inc. All rights reserved.
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
    
    @MainActor static let shared = UnsecureRepository()

    func save(user: UserCredentials) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(user) {
            set(encoded, for: .user)
        }
    }

    func loadCurrentUser() -> UserCredentials? {
        guard let savedUser = encodedCurrentUser() else { return nil }
        do {
            return try JSONDecoder().decode(UserCredentials.self, from: savedUser)
        } catch {
            log.error("Error while decoding user")
            return nil
        }
    }

    /// The stored user, as JSON, from either of the two shapes it can arrive in.
    ///
    /// `save(user:)` writes `Data`, which is what the app itself round-trips. A
    /// value supplied on the command line (`-stream.chat.user '{"id":…}'`) instead
    /// lands in `NSArgumentDomain` as a `String`, so reading only `Data` silently
    /// ignores it and the app falls back to the login screen. Accepting both makes
    /// the app launchable straight into a signed-in state — useful for UI tests and
    /// for automated performance runs, which clear app storage between iterations
    /// and would otherwise have to replay the login screen every time.
    private func encodedCurrentUser() -> Data? {
        if let data: Data = get(for: .user) { return data }
        if let json: String = get(for: .user) { return json.data(using: .utf8) }
        return nil
    }
    
    func removeCurrentUser() {
        defaults.set(nil, forKey: Key.user.rawValue)
    }
}
