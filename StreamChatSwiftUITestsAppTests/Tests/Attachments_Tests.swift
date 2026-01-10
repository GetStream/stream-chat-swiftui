//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import XCTest

final class Attachments_Tests: StreamTestCase {
    override func setUpWithError() throws {
        try XCTSkipIf(
            ProcessInfo().operatingSystemVersion.majorVersion >= 18,
            "Attachments tests freeze the test app on iOS > 18"
        )
        
        try super.setUpWithError()
        addTags([.coreFeatures])
        assertMockServer()
    }
    
    override func tearDownWithError() throws {
        if ProcessInfo().operatingSystemVersion.majorVersion < 18 {
            try super.tearDownWithError()
        }
    }

    func test_uploadImage() throws {
        linkToScenario(withId: 310)

        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        WHEN("user sends an image") {
            userRobot.uploadImage()
        }
        THEN("user can see uploaded image") {
            userRobot.assertImage(isPresent: true)
        }
    }

    func test_participantUploadsImage() throws {
        linkToScenario(withId: 311)

        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        WHEN("participant uploads an image") {
            participantRobot.uploadAttachment(type: .image)
        }
        THEN("user can see uploaded image") {
            userRobot.assertImage(isPresent: true)
        }
    }

    func test_participantUploadsVideo() throws {
        linkToScenario(withId: 312)

        throw XCTSkip("Check out CIS-2294")

        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        WHEN("participant uploads a video") {
            participantRobot.uploadAttachment(type: .video)
        }
        THEN("user can see uploaded video") {
            userRobot.assertVideo(isPresent: true)
        }
    }

    func test_participantUploadsFile() throws {
        linkToScenario(withId: 313)

        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        WHEN("participant uploads a file") {
            participantRobot.uploadAttachment(type: .file, waitBeforeSending: 2)
        }
        THEN("user can see uploaded file") {
            userRobot.assertFile(isPresent: true)
        }
    }
}
