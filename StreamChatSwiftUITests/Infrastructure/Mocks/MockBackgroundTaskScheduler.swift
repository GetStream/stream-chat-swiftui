//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChat

/// Mock implementation of `BackgroundTaskScheduler`.
final class MockBackgroundTaskScheduler: BackgroundTaskScheduler {
    nonisolated(unsafe) var isAppActive_called: Bool = false
    nonisolated(unsafe) var isAppActive_returns: Bool = true
    var isAppActive: Bool {
        isAppActive_called = true
        return isAppActive_returns
    }

    nonisolated(unsafe) var beginBackgroundTask_called: Bool = false
    nonisolated(unsafe) var beginBackgroundTask_expirationHandler: (@MainActor @Sendable() -> Void)?
    nonisolated(unsafe) var beginBackgroundTask_returns: Bool = true
    func beginTask(expirationHandler: (@MainActor @Sendable() -> Void)?) -> Bool {
        beginBackgroundTask_called = true
        beginBackgroundTask_expirationHandler = expirationHandler
        return beginBackgroundTask_returns
    }

    nonisolated(unsafe) var endBackgroundTask_called: Bool = false
    func endTask() {
        endBackgroundTask_called = true
    }

    nonisolated(unsafe) var startListeningForAppStateUpdates_called: Bool = false
    nonisolated(unsafe) var startListeningForAppStateUpdates_onBackground: (() -> Void)?
    nonisolated(unsafe) var startListeningForAppStateUpdates_onForeground: (() -> Void)?
    func startListeningForAppStateUpdates(
        onEnteringBackground: @escaping () -> Void,
        onEnteringForeground: @escaping () -> Void
    ) {
        startListeningForAppStateUpdates_called = true
        startListeningForAppStateUpdates_onBackground = onEnteringBackground
        startListeningForAppStateUpdates_onForeground = onEnteringForeground
    }

    nonisolated(unsafe) var stopListeningForAppStateUpdates_called: Bool = false
    func stopListeningForAppStateUpdates() {
        stopListeningForAppStateUpdates_called = true
    }
}

extension MockBackgroundTaskScheduler {
    func simulateAppGoingToBackground() {
        isAppActive_returns = false
        startListeningForAppStateUpdates_onBackground?()
    }

    func simulateAppGoingToForeground() {
        isAppActive_returns = true
        startListeningForAppStateUpdates_onForeground?()
    }
}
