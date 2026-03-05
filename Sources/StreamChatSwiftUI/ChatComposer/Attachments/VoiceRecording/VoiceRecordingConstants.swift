//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

enum VoiceRecordingConstants {
    /// Upward drag distance (negative Y) at which the recording locks.
    static let lockMaxDistance: CGFloat = -36
    /// Leftward drag distance (negative X) at which the cancel label starts fading.
    static let cancelMinDistance: CGFloat = -30
    /// Leftward drag distance (negative X) at which the recording is cancelled.
    static let cancelMaxDistance: CGFloat = -75
}
