//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct AudioRecordingInfo: Equatable, Sendable {
    /// The waveform of the recording.
    public var waveform: [Float]
    /// The duration of the recording.
    public var duration: TimeInterval
    
    mutating func update(with entry: Float, duration: TimeInterval) {
        waveform.append(entry)
        self.duration = duration
    }
}

extension AudioRecordingInfo {
    static let initial = AudioRecordingInfo(waveform: [], duration: 0)
}

extension MessageComposerViewModel: AudioPlayingDelegate {
    public func audioPlayer(
        _ audioPlayer: AudioPlaying,
        didUpdateContext context: AudioPlaybackContext
    ) {
        currentPlaybackURL = context.assetLocation
    }
}

extension MessageComposerViewModel: AudioRecordingDelegate {
    public func audioRecorder(
        _ audioRecorder: AudioRecording,
        didUpdateContext: AudioRecordingContext
    ) {
        audioRecordingInfo.update(
            with: didUpdateContext.averagePower,
            duration: didUpdateContext.duration
        )
    }
    
    public func audioRecorder(
        _ audioRecorder: AudioRecording,
        didFinishRecordingAtURL location: URL
    ) {
        if audioRecordingInfo == .initial {
            shouldSendOnRecordingFinish = false
            return
        }
        audioAnalysisFactory?.waveformVisualisation(
            fromAudioURL: location,
            for: waveformTargetSamples,
            completionHandler: { [weak self] result in
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    guard self.audioRecordingInfo != .initial else { return }
                    switch result {
                    case let .success(waveform):
                        let recording = AddedVoiceRecording(
                            url: location,
                            duration: self.audioRecordingInfo.duration,
                            waveform: waveform
                        )
                        if self.recordingState == .stopped {
                            self.pendingAudioRecording = recording
                            self.audioRecordingInfo.waveform = waveform
                        } else {
                            self.addedVoiceRecordings.append(recording)
                            self.recordingState = .initial
                            self.audioRecordingInfo = .initial
                            if self.shouldSendOnRecordingFinish {
                                self.shouldSendOnRecordingFinish = false
                                self.sendMessage()
                            }
                        }
                    case let .failure(error):
                        log.error(error)
                        self.shouldSendOnRecordingFinish = false
                        self.recordingState = .initial
                    }
                }
            }
        )
    }
    
    public func audioRecorder(
        _ audioRecorder: AudioRecording,
        didFailWithError error: Error
    ) {
        log.error(error)
        shouldSendOnRecordingFinish = false
        let wasRecording = recordingState != .initial
        recordingState = .initial
        audioRecordingInfo = .initial
        if wasRecording {
            snackBarText = L10n.Composer.Recording.recordingStopped
        }
    }
}

extension MessageComposerViewModel {
    /// Displays a tip snackbar explaining how to use voice recording.
    /// The text adapts based on `isVoiceRecordingAutoSendEnabled`.
    public func showRecordingTip() {
        snackBarText = utils.composerConfig.isVoiceRecordingAutoSendEnabled
            ? L10n.Composer.Recording.tip
            : L10n.Composer.Recording.tipSave
    }

    /// Begins capturing audio from the microphone.
    public func startRecording() {
        utils.audioSessionFeedbackGenerator.feedbackForBeginRecording()
        audioRecorder.beginRecording {
            log.debug("started recording")
        }
    }

    /// Stops the audio recorder. The recording enters the locked or stopped
    /// state depending on the current gesture flow.
    public func stopRecording() {
        utils.audioSessionFeedbackGenerator.feedbackForStopRecording()
        audioRecorder.stopRecording()
    }

    /// Resumes a previously paused recording session.
    public func resumeRecording() {
        utils.audioSessionFeedbackGenerator.feedbackForBeginRecording()
        audioRecorder.resumeRecording()
    }

    /// Pauses the current recording without discarding it.
    public func pauseRecording() {
        utils.audioSessionFeedbackGenerator.feedbackForPause()
        audioRecorder.pauseRecording()
    }
}

extension MessageComposerViewModel {
    /// Stops recording and sends the voice message as soon as the file is ready.
    ///
    /// Called when the user lifts their finger during a hold-to-record gesture
    /// (as opposed to locking). Sets `shouldSendOnRecordingFinish` so that the
    /// `audioRecorder(_:didFinishRecordingAtURL:)` callback triggers `sendMessage()`
    /// automatically once the audio file has been processed.
    public func sendRecording() {
        guard recordingState == .recording else { return }
        shouldSendOnRecordingFinish = true
        stopRecording()
    }

    /// Stops recording and adds the voice message to the composer's attachment
    /// preview without sending it.
    ///
    /// Called when the user lifts their finger during a hold-to-record gesture
    /// and `isVoiceRecordingAutoSendEnabled` is `false`. The recording is
    /// appended to `addedVoiceRecordings` so the user can review or discard
    /// it before explicitly sending.
    public func saveRecording() {
        guard recordingState == .recording else { return }
        shouldSendOnRecordingFinish = false
        stopRecording()
    }

    /// Cancels the current recording and resets all recording state.
    /// Shows a snackbar confirming the voice message was deleted.
    public func discardRecording() {
        shouldSendOnRecordingFinish = false
        stopPreviewPlaybackIfNeeded()
        stopRecording()
        recordingState = .initial
        audioRecordingInfo = .initial
        recordingGestureLocation = .zero
        snackBarText = L10n.Composer.Recording.voiceMessageDeleted
    }

    /// Confirms a stopped recording and adds it to the composer's voice attachments.
    /// If the recording is still in progress (locked state), stops it first.
    public func confirmRecording() {
        if recordingState == .stopped {
            stopPreviewPlaybackIfNeeded()
            if let pending = pendingAudioRecording {
                addedVoiceRecordings.append(pending)
                pendingAudioRecording = nil
                audioRecordingInfo = .initial
                recordingState = .initial
            }
        } else {
            stopRecording()
        }
    }

    /// Stops the shared audio player if it currently has one of the composer's
    /// local voice recordings loaded (the preview, a pending, or an added one).
    ///
    /// This is important because the shared `AVPlayer` keeps its `currentItem`
    /// pointing at the local file URL. When the composer's flow transitions away
    /// (confirm / discard / send), that file may be uploaded and then removed by
    /// `AttachmentQueueUploader`, leaving the `AVPlayer` with a dangling asset
    /// reference — which then breaks playback of every voice message in the
    /// message list until the AVPlayer is re-created.
    ///
    /// `currentPlaybackURL` is kept in sync via `AudioPlayingDelegate` so we
    /// only stop the player when its loaded asset actually belongs to this
    /// composer, leaving unrelated playback (e.g. a voice message in the list)
    /// untouched.
    func stopPreviewPlaybackIfNeeded() {
        guard let currentPlaybackURL else { return }
        let localURLs: Set<URL> = Set(
            addedVoiceRecordings.map(\.url)
                + [pendingAudioRecording?.url].compactMap { $0 }
        )
        guard localURLs.contains(currentPlaybackURL) else { return }
        utils.audioPlayer.stop()
    }

    /// Transitions to the stopped/preview state so the user can listen
    /// to the recording before confirming or discarding it.
    public func previewRecording() {
        recordingState = .stopped
        stopRecording()
    }
}
