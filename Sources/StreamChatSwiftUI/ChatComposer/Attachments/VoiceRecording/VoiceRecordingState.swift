//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation

public enum VoiceRecordingState: Equatable, Sendable {
    case initial
    case recording
    case locked
    case stopped
}

extension VoiceRecordingState {
    var showsComposer: Bool {
        self == .initial
    }

    /// Whether the user is actively recording (finger down, not yet locked).
    var isRecording: Bool {
        self == .recording
    }

    /// Whether the recording is locked or stopped (shows locked UI).
    var isLockedOrStopped: Bool {
        self == .locked || self == .stopped
    }
}
