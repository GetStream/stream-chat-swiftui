//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation

public enum RecordingState: Equatable, Sendable {
    case initial
    case recording(CGPoint)
    case locked
    case stopped
}

extension RecordingState {
    var showsComposer: Bool {
        self == .initial
    }

    /// Whether the user is actively recording (finger down, not yet locked).
    var isRecording: Bool {
        if case .recording = self { return true }
        return false
    }

    /// Whether the recording is locked or stopped (shows locked UI).
    var isLockedOrStopped: Bool {
        self == .locked || self == .stopped
    }
}
