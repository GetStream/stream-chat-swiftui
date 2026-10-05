//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import XCTest

final class Authentication_Tests: StreamTestCase {
    // Covers the next token refresh, which happens once the current token expires after `StreamMockServer.jwtTimeout`.
    let invalidationDuration = 10

    override func setUpWithError() throws {
        app.setLaunchArguments(.jwt)
        try super.setUpWithError()
    }

    func test_tokenInvalidatesBeforeUserLogsIn() {
        GIVEN("token is invalid") {
            backendRobot.invalidateToken()
        }
        WHEN("user tries to log in") {
            userRobot.login()
        }
        THEN("app requests a token refresh") {
            userRobot.assertConnectionStatus(.connected)
        }
    }

    func test_tokenInvalidatesAfterUserLogsIn() {
        GIVEN("user logs in") {
            userRobot
                .login()
                .assertConnectionStatus(.connected)
        }
        WHEN("token invalidates") {
            backendRobot.invalidateToken(duration: invalidationDuration)
        }
        AND("token expires") {
            backendRobot.waitForJwtToExpire()
        }
        THEN("app requests a token refresh") {
            userRobot.assertConnectionStatus(.connected)
        }
    }

    func test_tokenDateInvalidatesBeforeUserLogsIn() {
        GIVEN("token is invalid") {
            backendRobot.invalidateTokenDate()
        }
        WHEN("user tries to log in") {
            userRobot.login()
        }
        THEN("app requests a token refresh") {
            userRobot.assertConnectionStatus(.connected)
        }
    }

    func test_tokenDateInvalidatesAfterUserLogsIn() {
        GIVEN("user logs in") {
            userRobot
                .login()
                .assertConnectionStatus(.connected)
        }
        WHEN("token invalidates") {
            backendRobot.invalidateTokenDate(duration: invalidationDuration)
        }
        AND("token expires") {
            backendRobot.waitForJwtToExpire()
        }
        THEN("app requests a token refresh") {
            userRobot.assertConnectionStatus(.connected)
        }
    }

    func test_tokenSignatureInvalidatesBeforeUserLogsIn() {
        GIVEN("token is invalid") {
            backendRobot.invalidateTokenSignature()
        }
        WHEN("user tries to log in") {
            userRobot.login()
        }
        THEN("app requests a token refresh") {
            userRobot.assertConnectionStatus(.connected)
        }
    }

    func test_tokenSignatureInvalidatesAfterUserLogsIn() {
        GIVEN("user logs in") {
            userRobot
                .login()
                .assertConnectionStatus(.connected)
        }
        WHEN("token invalidates") {
            backendRobot.invalidateTokenSignature(duration: invalidationDuration)
        }
        AND("token expires") {
            backendRobot.waitForJwtToExpire()
        }
        THEN("app requests a token refresh") {
            userRobot.assertConnectionStatus(.connected)
        }
    }

    func test_tokenExpiresBeforeUserLogsIn() {
        GIVEN("token expires") {
            backendRobot.revokeToken()
        }
        WHEN("user tries to log in") {
            userRobot.login()
        }
        THEN("app requests a token refresh") {
            userRobot.assertConnectionStatus(.connected)
        }
    }

    func test_tokenExpiresAfterUserLoggedIn() {
        GIVEN("user logs in") {
            userRobot
                .login()
                .assertConnectionStatus(.connected)
        }
        WHEN("token expires") {
            backendRobot.waitForJwtToExpire()
        }
        THEN("app requests a token refresh") {
            userRobot.assertConnectionStatus(.connected)
        }
    }

    func test_tokenExpiresWhenUserIsInBackground() {
        GIVEN("user logs in") {
            userRobot
                .setStaysConnectedInBackground(to: .off)
                .login()
                .assertConnectionStatus(.connected)
        }
        AND("user goes to background") {
            deviceRobot.moveApplication(to: .background)
        }
        AND("token expires") {
            backendRobot.waitForJwtToExpire()
        }
        WHEN("user comes back to foreground") {
            deviceRobot.moveApplication(to: .foreground)
        }
        THEN("app requests a token refresh") {
            userRobot.assertConnectionStatus(.connected)
        }
    }

    func test_tokenExpiresWhileUserIsOffline() {
        GIVEN("user logs in") {
            userRobot
                .setConnectivitySwitchVisibility(to: .on)
                .login()
                .assertConnectionStatus(.connected)
        }
        AND("user goes offline") {
            userRobot.setConnectivity(to: .off)
        }
        WHEN("token expires") {
            backendRobot.waitForJwtToExpire()
        }
        AND("user comes back online") {
            userRobot.setConnectivity(to: .on)
        }
        THEN("app requests a token refresh") {
            userRobot.assertConnectionStatus(.connected)
        }
    }

    func test_tokenGenerationFails() {
        GIVEN("JWT generation breaks on server side") {
            backendRobot.breakTokenGeneration()
        }
        AND("user tries to log in") {
            userRobot.login()
        }
        WHEN("app requests a token refresh") {}
        AND("server returns an error") {}
        AND("JWT generation recovers on server side") {}
        THEN("app requests a token refresh a second time") {
            userRobot.assertConnectionStatus(.connected)
        }
    }
}
