//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import XCTest

final class Tets_Tests: StreamTestCase {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        addTags([.coreFeatures])
    }

    func testme() {
        let message = "message"

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        WHEN("user sends a message") {
            userRobot.sendMessage(message)
        }
        THEN("message list updates") {
            userRobot.assertMessage(message)
        }
    }
}
