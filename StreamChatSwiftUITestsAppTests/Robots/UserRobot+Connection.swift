//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import XCTest

extension UserRobot {
    @discardableResult
    func assertConnectionStatus(
        _ status: ChannelListPage.ConnectionStatus,
        timeout: Double = 15,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Self {
        let isShown = ChannelListPage.connectionLabel(withStatus: status).wait(timeout: timeout).exists
        XCTAssertTrue(isShown, "Connection status is not '\(status.rawValue)'", file: file, line: line)
        return self
    }
}

extension UserRobot {
    @discardableResult
    func logoutAndConfirm() -> Self {
        logout()
        ChannelListPage.signOutAlertButton.wait().safeTap()
        return self
    }

    @discardableResult
    func assertStartPageIsShown(file: StaticString = #filePath, line: UInt = #line) -> Self {
        XCTAssertTrue(StartPage.startButton.wait().exists, "Start page is not shown", file: file, line: line)
        XCTAssertFalse(ChannelListPage.userAvatar.exists, "Channel list is still shown", file: file, line: line)
        return self
    }
}
