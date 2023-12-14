//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct AudioRecordingInfo {
    public var waveform: [Float]
    public var duration: TimeInterval
    
    mutating func update(with entry: Float, duration: TimeInterval) {
        waveform.append(entry)
        self.duration = duration
    }
}

extension AudioRecordingInfo {
    static let initial = AudioRecordingInfo(waveform: [], duration: 0)
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
        didFinishRecordingAtURL: URL
    ) {
        //TODO: handle this better
        addedFileURLs.append(didFinishRecordingAtURL)
        recordingState = .initial
    }
    
    public func audioRecorder(
        _ audioRecorder: AudioRecording,
        didFailWithError: Error
    ) {
        
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
