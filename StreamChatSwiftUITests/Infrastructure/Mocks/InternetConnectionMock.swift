//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChat

class InternetConnectionMock: InternetConnection, @unchecked Sendable {
    @Atomic private(set) var monitorMock: InternetConnectionMonitorMock!
    @Atomic private(set) var init_notificationCenter: NotificationCenter!

    init(
        monitor: InternetConnectionMonitorMock = .init(),
        notificationCenter: NotificationCenter = .default
    ) {
        super.init(notificationCenter: notificationCenter, monitor: monitor)
        init_notificationCenter = notificationCenter
        monitorMock = monitor
    }
}

class InternetConnectionMonitorMock: InternetConnectionMonitor, @unchecked Sendable {
    weak var delegate: InternetConnectionDelegate?

    var status: InternetConnection.Status = .unknown {
        didSet {
            delegate?.internetConnectionStatusDidChange(status: status)
        }
    }

    @Atomic var isStarted = false

    func start() {
        isStarted = true
        status = .available(.great)
    }

    func stop() {
        isStarted = false
        status = .unknown
    }
}
