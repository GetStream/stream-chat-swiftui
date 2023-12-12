//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import Foundation

public enum RecordingState: Equatable {
    case initial
    case recording(CGPoint)
    case locked
    case stopped
}
