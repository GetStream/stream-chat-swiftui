//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import XCTest

@MainActor
final class VoiceRecordingHandler_Tests: StreamChatTestCase {

    private lazy var mockPlayer: MockAudioPlayer! = .init()
    private lazy var handler: VoiceRecordingHandler! = .init()
    private let url = URL(fileURLWithPath: "/tmp/voice.aac")
    private let duration: TimeInterval = 30

    override func setUp() {
        super.setUp()
        mockPlayer = MockAudioPlayer()
        streamChat?.utils._audioPlayer = mockPlayer
        handler = VoiceRecordingHandler()
    }

    override func tearDown() {
        handler = nil
        mockPlayer = nil
        super.tearDown()
    }

    // MARK: - displayedTime(for:duration:)

    func test_displayedTime_whenNotActive_returnsTotalDuration() {
        let result = handler.displayedTime(for: url, duration: duration)

        XCTAssertEqual(result, duration)
    }

    func test_displayedTime_whenPlaying_returnsRemainingTime() {
        handler.context = makeContext(currentTime: 10, state: .playing)

        let result = handler.displayedTime(for: url, duration: duration)

        XCTAssertEqual(result, 20, accuracy: 0.001)
    }

    func test_displayedTime_whenPaused_returnsRemainingTime() {
        handler.context = makeContext(currentTime: 25, state: .paused)

        let result = handler.displayedTime(for: url, duration: duration)

        XCTAssertEqual(result, 5, accuracy: 0.001)
    }

    func test_displayedTime_whenPausedAtStart_returnsFullDuration() {
        handler.context = makeContext(currentTime: 0, state: .paused)

        let result = handler.displayedTime(for: url, duration: duration)

        XCTAssertEqual(result, duration, accuracy: 0.001)
    }

    func test_displayedTime_whenStopped_returnsTotalDuration() {
        handler.context = makeContext(currentTime: 0, state: .stopped)

        let result = handler.displayedTime(for: url, duration: duration)

        XCTAssertEqual(result, duration)
    }

    func test_displayedTime_whenPlayerDurationExceedsRecordingDuration_usesPlayerDuration() {
        let playerDuration: TimeInterval = 32
        handler.context = makeContext(duration: playerDuration, currentTime: 10, state: .playing)

        let result = handler.displayedTime(for: url, duration: duration)

        XCTAssertEqual(result, playerDuration - 10, accuracy: 0.001)
    }

    func test_displayedTime_clampsToZero_whenCurrentTimeExceedsDuration() {
        handler.context = makeContext(currentTime: 35, state: .playing)

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

    // MARK: - updatePlaybackState(for:)

    func test_updatePlaybackState_whenPlaying_setsIsPlayingTrue() {
        handler.context = makeContext(state: .playing)

        handler.updatePlaybackState(for: url)

        XCTAssertTrue(handler.isPlaying)
    }

    func test_updatePlaybackState_whenPlaying_appliesHandlerRate() {
        handler.rate = .double
        handler.context = makeContext(state: .playing)

        handler.updatePlaybackState(for: url)

        XCTAssertEqual(mockPlayer.updateRateWasCalledWithRate, .double)
    }

    func test_updatePlaybackState_whenPlaying_appliesDefaultRate() {
        handler.rate = .normal
        handler.context = makeContext(state: .playing)

        handler.updatePlaybackState(for: url)

        XCTAssertEqual(mockPlayer.updateRateWasCalledWithRate, .normal)
    }

    func test_updatePlaybackState_whenAlreadyPlaying_doesNotReapplyRate() {
        handler.isPlaying = true
        handler.rate = .double
        handler.context = makeContext(state: .playing)

        handler.updatePlaybackState(for: url)

        XCTAssertNil(mockPlayer.updateRateWasCalledWithRate)
    }

    func test_updatePlaybackState_whenPaused_setsIsPlayingFalse() {
        handler.isPlaying = true
        handler.context = makeContext(state: .paused)

        handler.updatePlaybackState(for: url)

        XCTAssertFalse(handler.isPlaying)
    }

    func test_updatePlaybackState_whenStopped_setsIsPlayingFalse() {
        handler.isPlaying = true
        handler.context = makeContext(state: .stopped)

        handler.updatePlaybackState(for: url)

        XCTAssertFalse(handler.isPlaying)
    }

    func test_updatePlaybackState_whenDifferentURL_doesNotUpdate() {
        handler.isPlaying = true
        handler.context = AudioPlaybackContext(
            assetLocation: URL(fileURLWithPath: "/tmp/other.aac"),
            duration: 10,
            currentTime: 0,
            state: .stopped,
            rate: .zero,
            isSeeking: false
        )

        handler.updatePlaybackState(for: url)

        XCTAssertTrue(handler.isPlaying)
    }

    // MARK: - togglePlayback(for:)

    func test_togglePlayback_whenPlaying_pausesPlayer() {
        handler.isPlaying = true

        handler.togglePlayback(for: url)

        XCTAssertTrue(mockPlayer.pauseWasCalled)
        XCTAssertNil(mockPlayer.loadAssetWasCalledWithURL)
    }

    func test_togglePlayback_whenNotPlaying_loadsAssetWithoutApplyingRate() {
        handler.isPlaying = false
        handler.rate = .double

        handler.togglePlayback(for: url)

        XCTAssertEqual(mockPlayer.loadAssetWasCalledWithURL, url)
        XCTAssertNil(mockPlayer.updateRateWasCalledWithRate)
    }

    // MARK: - cycleRate()

    func test_cycleRate_fromNormal_setsDouble() {
        handler.rate = .normal
        handler.isPlaying = true

        handler.cycleRate()

        XCTAssertEqual(handler.rate, .double)
        XCTAssertEqual(mockPlayer.updateRateWasCalledWithRate, .double)
    }

    func test_cycleRate_fromDouble_setsHalf() {
        handler.rate = .double
        handler.isPlaying = true

        handler.cycleRate()

        XCTAssertEqual(handler.rate, .half)
        XCTAssertEqual(mockPlayer.updateRateWasCalledWithRate, .half)
    }

    func test_cycleRate_fromHalf_setsNormal() {
        handler.rate = .half
        handler.isPlaying = true

        handler.cycleRate()

        XCTAssertEqual(handler.rate, .normal)
        XCTAssertEqual(mockPlayer.updateRateWasCalledWithRate, .normal)
    }

    func test_cycleRate_whenNotPlaying_updatesRateWithoutCallingPlayer() {
        handler.rate = .normal
        handler.isPlaying = false

        handler.cycleRate()

        XCTAssertEqual(handler.rate, .double)
        XCTAssertNil(mockPlayer.updateRateWasCalledWithRate)
    }

    func test_cycleRate_whenNotPlaying_fullCycleDoesNotCallPlayer() {
        handler.isPlaying = false
        handler.rate = .normal

        handler.cycleRate()
        XCTAssertEqual(handler.rate, .double)

        handler.cycleRate()
        XCTAssertEqual(handler.rate, .half)

        handler.cycleRate()
        XCTAssertEqual(handler.rate, .normal)

        XCTAssertNil(mockPlayer.updateRateWasCalledWithRate)
    }

    // MARK: - rateTitle

    func test_rateTitle_normal() {
        handler.rate = .normal
        XCTAssertEqual(handler.rateTitle, "x1")
    }

    func test_rateTitle_double() {
        handler.rate = .double
        XCTAssertEqual(handler.rateTitle, "x2")
    }

    func test_rateTitle_half() {
        handler.rate = .half
        XCTAssertEqual(handler.rateTitle, "x0.5")
    }

    // MARK: - isActive(for:)

    func test_isActive_whenURLMatches_returnsTrue() {
        handler.context = makeContext(state: .playing)

        XCTAssertTrue(handler.isActive(for: url))
    }

    func test_isActive_whenURLDiffers_returnsFalse() {
        handler.context = makeContext(state: .playing)

        XCTAssertFalse(handler.isActive(for: URL(fileURLWithPath: "/tmp/other.aac")))
    }

    // MARK: - seek(to:loadingFrom:)

    func test_seek_whenAlreadyActive_seeksWithoutLoading() {
        handler.context = makeContext(state: .playing)

        handler.seek(to: 10)

        XCTAssertEqual(mockPlayer.seekWasCalledWithTime, 10)
        XCTAssertNil(mockPlayer.loadAssetWasCalledWithURL)
    }

    func test_seek_whenNotActive_loadsAssetAndSeeks() {
        let newURL = URL(fileURLWithPath: "/tmp/new.aac")

        handler.seek(to: 5, loadingFrom: newURL)

        XCTAssertEqual(mockPlayer.loadAssetWasCalledWithURL, newURL)
        XCTAssertEqual(mockPlayer.seekWasCalledWithTime, 5)
    }

    // MARK: - Helpers

    private func makeContext(
        duration: TimeInterval? = nil,
        currentTime: TimeInterval = 0,
        state: AudioPlaybackState
    ) -> AudioPlaybackContext {
        AudioPlaybackContext(
            assetLocation: url,
            duration: duration ?? self.duration,
            currentTime: currentTime,
            state: state,
            rate: state == .playing ? .normal : .zero,
            isSeeking: false
        )
    }
}
