//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

public enum MessageComposerInputState {
    case slowMode(cooldownDuration: Int)
    case creating(hasContent: Bool)
    case editing(hasContent: Bool)
    case allowAudioRecording
}
