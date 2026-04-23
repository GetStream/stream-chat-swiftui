//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation

/// The current composer's input view state.
public enum MessageComposerInputState {
    case slowMode(cooldownDuration: Int)
    case creating(hasContent: Bool, hasCommand: Bool)
    case editing(hasContent: Bool)
    case allowAudioRecording
}

extension MessageComposerInputState {
    /// Resolves the composer input state from the inputs that affect which trailing
    /// control the composer should render.
    ///
    /// Shared between `MessageComposerViewModel.composerInputState` and the view's
    /// local computed state so both stay in sync (including the
    /// `VoiceRecordingGestureOverlay` visibility) without duplicating the decision
    /// tree or introducing a breaking API change.
    init(
        cooldownDuration: Int,
        isEditingMessage: Bool,
        isInstantCommandActive: Bool,
        isVoiceRecordingEnabled: Bool,
        hasContent: Bool,
        canSendMessage: Bool
    ) {
        if cooldownDuration > 0 {
            self = .slowMode(cooldownDuration: cooldownDuration)
        } else if isEditingMessage {
            self = .editing(hasContent: hasContent)
        } else if isInstantCommandActive {
            self = .creating(hasContent: hasContent, hasCommand: true)
        } else if isVoiceRecordingEnabled && !hasContent && canSendMessage {
            self = .allowAudioRecording
        } else {
            self = .creating(hasContent: hasContent, hasCommand: false)
        }
    }
}
