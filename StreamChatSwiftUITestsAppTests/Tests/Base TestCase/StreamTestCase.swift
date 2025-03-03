//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import XCTest

// Application
let app = XCUIApplication()

class StreamTestCase: XCTestCase {

    let deviceRobot = DeviceRobot(app)
    var userRobot: UserRobot!
    var backendRobot: BackendRobot!
    var participantRobot: ParticipantRobot!
    var server: StreamMockServer!
    var mockServerCrashed = false
    var recordVideo = false

    override func setUpWithError() throws {
        continueAfterFailure = false
        startMockServer()
        participantRobot = ParticipantRobot(server)
        backendRobot = BackendRobot(server)
        userRobot = UserRobot(server)

        try super.setUpWithError()
        alertHandler()
        useMockServer()
        startVideo()
        app.launch()
    }

    override func tearDownWithError() throws {
        attachElementTree()
        stopVideo()
        app.terminate()
        server.stop()
        backendRobot.delayServerResponse(byTimeInterval: 0.0)

        try super.tearDownWithError()
        app.launchArguments.removeAll()
        app.launchEnvironment.removeAll()
    }
}

extension StreamTestCase {
    
    func assertMockServer() {
        XCTAssertFalse(mockServerCrashed, "Mock server failed on start")
    }

    private func useMockServer() {
        // Leverage web socket server
        app.setLaunchArguments(.useMockServer)

        // Configure web socket host
        app.setEnvironmentVariables([
            .websocketHost: "\(MockServerConfiguration.websocketHost)",
            .httpHost: "\(MockServerConfiguration.httpHost)",
            .port: "\(MockServerConfiguration.port)"
        ])
    }

    private func attachElementTree() {
        let attachment = XCTAttachment(string: app.debugDescription)
        attachment.lifetime = .deleteOnSuccess
        add(attachment)
    }

    private func alertHandler() {
        let title = "Notification Alert"
        _ = addUIInterruptionMonitor(withDescription: title) { (alert: XCUIElement) -> Bool in
            let allowButton = alert.buttons.matching(NSPredicate(format: "label LIKE 'Allow' or label LIKE 'Allow Full Access' or label LIKE 'Allow Access to All Photos'")).firstMatch
            if allowButton.exists {
                allowButton.tap()
                return true
            }
            return false
        }
    }

    private func startMockServer() {
        server = StreamMockServer()
        server.configure()
        
        for _ in 0...3 {
            let serverHasStarted = server.start(port: UInt16(MockServerConfiguration.port))
            if serverHasStarted {
                return
            }
            server.stop()
            MockServerConfiguration.port = UInt16.random(in: 61000..<62000)
        }
        
        mockServerCrashed = true
    }

    private func startVideo() {
        if recordVideo {
            server.recordVideo(name: testName)
        }
    }

    private func stopVideo() {
        if recordVideo {
            server.recordVideo(name: testName, delete: !isTestFailed(), stop: true)
        }
    }

    private func isTestFailed() -> Bool {
        if let testRun = testRun {
            let failureCount = testRun.failureCount + testRun.unexpectedExceptionCount
            return failureCount > 0
        }
        return false
    }

    private var testName: String {
        String(name.split(separator: " ")[1].dropLast())
    }
}
