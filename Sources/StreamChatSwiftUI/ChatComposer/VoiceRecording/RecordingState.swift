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
}
