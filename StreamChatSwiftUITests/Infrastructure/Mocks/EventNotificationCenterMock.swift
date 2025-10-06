//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChat

/// Mock implementation of `EventNotificationCenter`
final class EventNotificationCenterMock: EventNotificationCenter, @unchecked Sendable {
    lazy var mock_process = MockFunc<([Event], Bool, (@Sendable () -> Void)?), Void>.mock(for: process)

    override func process(
        _ events: [Event],
        postNotifications: Bool = true,
        completion: (@Sendable () -> Void)? = nil
    ) {
        super.process(events, postNotifications: postNotifications, completion: completion)

        mock_process.call(with: (events, postNotifications, completion))
    }
}
