//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import XCTest

extension ChannelListPage {
    static var signOutAlertButton: XCUIElement {
        app.alerts.buttons["Sign out"].firstMatch
    }

    static func connectionLabel(withStatus status: ConnectionStatus) -> XCUIElement {
        app.staticTexts.matching(identifier: status.rawValue).firstMatch
    }

    enum ConnectionStatus: String {
        case initialized
        case connecting
        case connected
        case disconnecting
        case disconnected
    }
}
