//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import Foundation

public enum RecordingState: Equatable {
    case initial
    case showingTip
    case recording(CGPoint)
    case locked
    case stopped
}

extension RecordingState {
    var showsComposer: Bool {
        self == .initial || self == .showingTip
    }
}
