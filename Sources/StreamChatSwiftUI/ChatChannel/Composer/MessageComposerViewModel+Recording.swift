//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public final class AudioRecordingInfo: Equatable {
    /// The waveform of the recording.
    public var waveform: [Float]
    /// The duration of the recording.
    public var duration: TimeInterval

    public init(waveform: [Float], duration: TimeInterval) {
        self.waveform = waveform
        self.duration = duration
    }

    func update(with entry: Float, duration: TimeInterval) {
        waveform.append(entry)
        self.duration = duration
    }

    public static func == (lhs: AudioRecordingInfo, rhs: AudioRecordingInfo) -> Bool {
        lhs.waveform == rhs.waveform && lhs.duration == rhs.duration
    }
}

extension AudioRecordingInfo {
    static var initial: AudioRecordingInfo {
        AudioRecordingInfo(waveform: [], duration: 0)
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
        if audioRecordingInfo == .initial { return }
        audioAnalysisFactory?.waveformVisualisation(
            fromAudioURL: location,
            for: waveformTargetSamples,
            completionHandler: { [weak self] result in
                guard let self else { return }
                switch result {
                case let .success(waveform):
                    DispatchQueue.main.async {
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
                        }
                    }
                case let .failure(error):
                    log.error(error)
                    self.recordingState = .initial
                }
            }
        )
    }
    
    public func audioRecorder(
        _ audioRecorder: AudioRecording,
        didFailWithError error: Error
    ) {
        log.error(error)
        recordingState = .initial
        audioRecordingInfo = .initial
    }
}

extension MessageComposerViewModel {
    public func startRecording() {
        utils.audioSessionFeedbackGenerator.feedbackForBeginRecording()
        audioRecorder.beginRecording {
            log.debug("started recording")
        }
    }
    
    public func stopRecording() {
        utils.audioSessionFeedbackGenerator.feedbackForStopRecording()
        audioRecorder.stopRecording()
    }
    
    public func resumeRecording() {
        utils.audioSessionFeedbackGenerator.feedbackForBeginRecording()
        audioRecorder.resumeRecording()
    }
    
    public func pauseRecording() {
        utils.audioSessionFeedbackGenerator.feedbackForPause()
        audioRecorder.pauseRecording()
    }
}

extension MessageComposerViewModel {
    public func discardRecording() {
        recordingState = .initial
        audioRecordingInfo = .initial
        stopRecording()
    }
    
    public func confirmRecording() {
        if recordingState == .stopped {
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
    
    public func previewRecording() {
        recordingState = .stopped
        stopRecording()
    }
}
