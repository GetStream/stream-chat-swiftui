//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

final class VoiceRecordingHandler_Tests: XCTestCase {
    private lazy var handler: VoiceRecordingHandler! = .init()
    private let url = URL(fileURLWithPath: "/tmp/voice.aac")
    private let duration: TimeInterval = 30

    override func tearDown() {
        handler = nil
        super.tearDown()
    }

    // MARK: - displayedTime(for:duration:)

    func test_displayedTime_whenNotActive_returnsTotalDuration() {
        let result = handler.displayedTime(for: url, duration: duration)

        XCTAssertEqual(result, duration)
    }

    func test_displayedTime_whenPlaying_returnsRemainingTime() {
        handler.context = AudioPlaybackContext(
            assetLocation: url,
            duration: duration,
            currentTime: 10,
            state: .playing,
            rate: .normal,
            isSeeking: false
        )

        let result = handler.displayedTime(for: url, duration: duration)

        XCTAssertEqual(result, 20, accuracy: 0.001)
    }

    func test_displayedTime_whenPaused_returnsRemainingTime() {
        handler.context = AudioPlaybackContext(
            assetLocation: url,
            duration: duration,
            currentTime: 25,
            state: .paused,
            rate: .zero,
            isSeeking: false
        )

        let result = handler.displayedTime(for: url, duration: duration)

        XCTAssertEqual(result, 5, accuracy: 0.001)
    }

    func test_displayedTime_whenPausedAtStart_returnsFullDuration() {
        handler.context = AudioPlaybackContext(
            assetLocation: url,
            duration: duration,
            currentTime: 0,
            state: .paused,
            rate: .zero,
            isSeeking: false
        )

        let result = handler.displayedTime(for: url, duration: duration)

        XCTAssertEqual(result, duration, accuracy: 0.001)
    }

    func test_displayedTime_whenStopped_returnsTotalDuration() {
        handler.context = AudioPlaybackContext(
            assetLocation: url,
            duration: duration,
            currentTime: 0,
            state: .stopped,
            rate: .zero,
            isSeeking: false
        )

        let result = handler.displayedTime(for: url, duration: duration)

        XCTAssertEqual(result, duration)
    }

    func test_displayedTime_whenPlayerDurationExceedsRecordingDuration_usesPlayerDuration() {
        let playerDuration: TimeInterval = 32
        handler.context = AudioPlaybackContext(
            assetLocation: url,
            duration: playerDuration,
            currentTime: 10,
            state: .playing,
            rate: .normal,
            isSeeking: false
        )

        let result = handler.displayedTime(for: url, duration: duration)

        XCTAssertEqual(result, playerDuration - 10, accuracy: 0.001)
    }

    func test_displayedTime_clampsToZero_whenCurrentTimeExceedsDuration() {
        handler.context = AudioPlaybackContext(
            assetLocation: url,
            duration: duration,
            currentTime: 35,
            state: .playing,
            rate: .normal,
            isSeeking: false
        )

        let result = handler.displayedTime(for: url, duration: duration)

        XCTAssertEqual(result, 0)
    }

    func test_displayedTime_whenActiveForDifferentURL_returnsTotalDuration() {
        let otherURL = URL(fileURLWithPath: "/tmp/other.aac")
        handler.context = AudioPlaybackContext(
            assetLocation: otherURL,
            duration: 60,
            currentTime: 20,
            state: .playing,
            rate: .normal,
            isSeeking: false
        )

        let result = handler.displayedTime(for: url, duration: duration)

        XCTAssertEqual(result, duration)
    }
}
