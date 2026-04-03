//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import SwiftUI

// MARK: - Composer View Options

/// Options for creating the message composer view.
public final class MessageComposerViewTypeOptions: Sendable {
    /// The channel controller for the composer.
    public let channelController: ChatChannelController
    /// The message controller for editing messages.
    public let messageController: ChatMessageController?
    /// Binding to the quoted message.
    public let quotedMessage: Binding<ChatMessage?>
    /// Binding to the edited message.
    public let editedMessage: Binding<ChatMessage?>
    /// Callback invoked before a message is sent.
    public let willSendMessage: @MainActor () -> Void
    
    public init(
        channelController: ChatChannelController,
        messageController: ChatMessageController?,
        quotedMessage: Binding<ChatMessage?>,
        editedMessage: Binding<ChatMessage?>,
        willSendMessage: @escaping @MainActor () -> Void
    ) {
        self.channelController = channelController
        self.messageController = messageController
        self.quotedMessage = quotedMessage
        self.editedMessage = editedMessage
        self.willSendMessage = willSendMessage
    }
}

// MARK: - Composer Input Options

/// Options for creating the leading composer view.
public final class LeadingComposerViewOptions: Sendable {
    /// Binding to the picker type state.
    public let state: Binding<PickerTypeState>
    /// The channel configuration.
    public let channelConfig: ChannelConfig?
    /// Whether an instant command (e.g. /giphy, /mute) is currently active.
    public let isCommandActive: Bool
    
    public init(
        state: Binding<PickerTypeState>,
        channelConfig: ChannelConfig?,
        isCommandActive: Bool = false
    ) {
        self.state = state
        self.channelConfig = channelConfig
        self.isCommandActive = isCommandActive
    }
}

/// Options for creating the composer input view.
public final class ComposerInputViewOptions: @unchecked Sendable {
    /// The channel controller.
    public let channelController: ChatChannelController
    /// Binding to the text input.
    public let text: Binding<String>
    /// Binding to the selected range location.
    public let selectedRangeLocation: Binding<Int>
    /// Binding to the current command.
    public let command: Binding<ComposerCommand?>
    /// Binding to the recording state.
    public let recordingState: Binding<VoiceRecordingState>
    /// Binding to the current gesture location during active recording.
    public let recordingGestureLocation: Binding<CGPoint>
    /// The composer assets (images + files in insertion order).
    public let composerAssets: [ComposerAsset]
    /// The added custom attachments.
    public let addedCustomAttachments: [CustomAttachment]
    /// The added voice recordings.
    public let addedVoiceRecordings: [AddedVoiceRecording]
    /// Binding to the quoted message.
    public let quotedMessage: Binding<ChatMessage?>
    /// Binding to the edited message.
    public let editedMessage: Binding<ChatMessage?>
    /// The maximum message length.
    public let maxMessageLength: Int?
    /// The cooldown duration in seconds.
    public let cooldownDuration: Int
    /// Whether the composer has content.
    public let hasContent: Bool
    /// Whether sending a message is enabled.
    public let canSendMessage: Bool
    /// The current audio recording info (waveform and duration).
    public let audioRecordingInfo: AudioRecordingInfo
    /// The URL for a pending audio recording available for playback.
    public let pendingAudioRecordingURL: URL?
    /// Callback when a custom attachment is tapped.
    public let onCustomAttachmentTap: @MainActor (CustomAttachment) -> Void
    /// Callback to remove an attachment by ID.
    public let removeAttachmentWithId: @MainActor (String) -> Void
    /// Sends a message.
    public let sendMessage: @MainActor () -> Void
    /// Called when an image is pasted.
    public let onImagePasted: @MainActor (UIImage) -> Void
    /// Start a recording.
    public let startRecording: @MainActor () -> Void
    /// Stop a recording.
    public let stopRecording: @MainActor () -> Void
    /// Confirm and attach the stopped recording.
    public let confirmRecording: @MainActor () -> Void
    /// Discard the current recording.
    public let discardRecording: @MainActor () -> Void
    /// Stop recording and preview the result.
    public let previewRecording: @MainActor () -> Void
    /// Shows the recording tip snackbar.
    public let showRecordingTip: @MainActor () -> Void
    /// Whether the send in channel view should be shown.
    public let sendInChannelShown: Bool
    /// Binding to whether to show reply in channel.
    public let showReplyInChannel: Binding<Bool>
    
    public init(
        channelController: ChatChannelController,
        text: Binding<String>,
        selectedRangeLocation: Binding<Int>,
        command: Binding<ComposerCommand?>,
        recordingState: Binding<VoiceRecordingState>,
        recordingGestureLocation: Binding<CGPoint>,
        composerAssets: [ComposerAsset],
        addedCustomAttachments: [CustomAttachment],
        addedVoiceRecordings: [AddedVoiceRecording],
        quotedMessage: Binding<ChatMessage?>,
        editedMessage: Binding<ChatMessage?>,
        maxMessageLength: Int?,
        cooldownDuration: Int,
        hasContent: Bool,
        canSendMessage: Bool,
        audioRecordingInfo: AudioRecordingInfo,
        pendingAudioRecordingURL: URL?,
        onCustomAttachmentTap: @escaping @MainActor (CustomAttachment) -> Void,
        removeAttachmentWithId: @escaping @MainActor (String) -> Void,
        sendMessage: @escaping @MainActor () -> Void,
        onImagePasted: @escaping @MainActor (UIImage) -> Void,
        startRecording: @escaping @MainActor () -> Void,
        stopRecording: @escaping @MainActor () -> Void,
        confirmRecording: @escaping @MainActor () -> Void,
        discardRecording: @escaping @MainActor () -> Void,
        previewRecording: @escaping @MainActor () -> Void,
        showRecordingTip: @escaping @MainActor () -> Void,
        sendInChannelShown: Bool,
        showReplyInChannel: Binding<Bool>
    ) {
        self.channelController = channelController
        self.text = text
        self.selectedRangeLocation = selectedRangeLocation
        self.command = command
        self.recordingState = recordingState
        self.recordingGestureLocation = recordingGestureLocation
        self.composerAssets = composerAssets
        self.addedCustomAttachments = addedCustomAttachments
        self.addedVoiceRecordings = addedVoiceRecordings
        self.quotedMessage = quotedMessage
        self.editedMessage = editedMessage
        self.maxMessageLength = maxMessageLength
        self.cooldownDuration = cooldownDuration
        self.hasContent = hasContent
        self.canSendMessage = canSendMessage
        self.audioRecordingInfo = audioRecordingInfo
        self.pendingAudioRecordingURL = pendingAudioRecordingURL
        self.onCustomAttachmentTap = onCustomAttachmentTap
        self.removeAttachmentWithId = removeAttachmentWithId
        self.sendMessage = sendMessage
        self.onImagePasted = onImagePasted
        self.startRecording = startRecording
        self.stopRecording = stopRecording
        self.confirmRecording = confirmRecording
        self.discardRecording = discardRecording
        self.previewRecording = previewRecording
        self.showRecordingTip = showRecordingTip
        self.sendInChannelShown = sendInChannelShown
        self.showReplyInChannel = showReplyInChannel
    }
}

/// Options for creating the composer text input view.
public final class ComposerTextInputViewOptions: Sendable {
    /// Binding to the text input.
    public let text: Binding<String>
    /// Binding to the height of the input.
    public let height: Binding<CGFloat>
    /// Binding to the selected range location.
    public let selectedRangeLocation: Binding<Int>
    /// The placeholder text.
    public let placeholder: String
    /// Whether the input is editable.
    public let editable: Bool
    /// The maximum message length.
    public let maxMessageLength: Int?
    /// The current height of the input.
    public let currentHeight: CGFloat
    /// Called when an image is pasted.
    public let onImagePasted: @MainActor (UIImage) -> Void
    
    public init(
        text: Binding<String>,
        height: Binding<CGFloat>,
        selectedRangeLocation: Binding<Int>,
        placeholder: String,
        editable: Bool,
        maxMessageLength: Int?,
        currentHeight: CGFloat,
        onImagePasted: @escaping @MainActor (UIImage) -> Void
    ) {
        self.text = text
        self.height = height
        self.selectedRangeLocation = selectedRangeLocation
        self.placeholder = placeholder
        self.editable = editable
        self.maxMessageLength = maxMessageLength
        self.currentHeight = currentHeight
        self.onImagePasted = onImagePasted
    }
}

/// Options for creating the composer input trailing view.
public final class ComposerInputTrailingViewOptions: @unchecked Sendable {
    /// Binding to the text input.
    @Binding public var text: String
    /// Binding to the recording state.
    @Binding public var recordingState: VoiceRecordingState
    /// Binding for the composer command.
    @Binding public var composerCommand: ComposerCommand?
    /// The current composer's input view state.
    public let composerInputState: MessageComposerInputState
    /// The closure for starting a recording.
    public let startRecording: @MainActor () -> Void
    /// The closure for stopping a recording.
    public let stopRecording: @MainActor () -> Void
    /// The closure for showing the recording tip snackbar.
    public let showRecordingTip: @MainActor () -> Void
    /// The closure for sending a message.
    public let sendMessage: @MainActor () -> Void

    public init(
        text: Binding<String>,
        recordingState: Binding<VoiceRecordingState>,
        composerCommand: Binding<ComposerCommand?>,
        composerInputState: MessageComposerInputState,
        startRecording: @escaping @MainActor () -> Void,
        stopRecording: @escaping @MainActor () -> Void,
        showRecordingTip: @escaping @MainActor () -> Void,
        sendMessage: @escaping @MainActor () -> Void
    ) {
        _text = text
        _recordingState = recordingState
        _composerCommand = composerCommand
        self.composerInputState = composerInputState
        self.startRecording = startRecording
        self.stopRecording = stopRecording
        self.showRecordingTip = showRecordingTip
        self.sendMessage = sendMessage
    }
}

/// Options for creating the trailing composer view.
public final class TrailingComposerViewOptions: Sendable {
    /// Whether the composer is enabled.
    public let enabled: Bool
    /// The cooldown duration in seconds.
    public let cooldownDuration: Int
    /// Callback when the trailing view is tapped.
    public let onTap: @MainActor () -> Void
    
    public init(enabled: Bool, cooldownDuration: Int, onTap: @escaping @MainActor () -> Void) {
        self.enabled = enabled
        self.cooldownDuration = cooldownDuration
        self.onTap = onTap
    }
}

public final class SendMessageButtonOptions: Sendable {
    /// Whether the send message button is enabled.
    public let enabled: Bool
    /// Whether the composer input has a command selected.
    public let commandSelected: Bool
    /// Callback when the button is tapped.
    public let onTap: @MainActor @Sendable () -> Void

    public init(
        enabled: Bool,
        commandSelected: Bool,
        onTap: @escaping @MainActor @Sendable () -> Void
    ) {
        self.enabled = enabled
        self.commandSelected = commandSelected
        self.onTap = onTap
    }
}

public final class ConfirmEditButtonOptions: Sendable {
    /// Whether the confirm edit button is enabled.
    public let enabled: Bool
    /// Callback when the button is tapped.
    public let onTap: @MainActor @Sendable () -> Void

    public init(
        enabled: Bool,
        onTap: @escaping @MainActor @Sendable () -> Void
    ) {
        self.enabled = enabled
        self.onTap = onTap
    }
}

// MARK: - Composer Recording Options

/// Options for creating the unified voice recording input view.
public final class ComposerVoiceRecordingInputViewOptions: @unchecked Sendable {
    public let recordingState: VoiceRecordingState
    public let audioRecordingInfo: AudioRecordingInfo
    public let pendingAudioRecordingURL: URL?
    public let gestureLocation: CGPoint
    public let stopRecording: @MainActor () -> Void
    public let confirmRecording: @MainActor () -> Void
    public let discardRecording: @MainActor () -> Void
    public let previewRecording: @MainActor () -> Void

    public init(
        recordingState: VoiceRecordingState,
        audioRecordingInfo: AudioRecordingInfo,
        pendingAudioRecordingURL: URL?,
        gestureLocation: CGPoint,
        stopRecording: @escaping @MainActor () -> Void,
        confirmRecording: @escaping @MainActor () -> Void,
        discardRecording: @escaping @MainActor () -> Void,
        previewRecording: @escaping @MainActor () -> Void
    ) {
        self.recordingState = recordingState
        self.audioRecordingInfo = audioRecordingInfo
        self.pendingAudioRecordingURL = pendingAudioRecordingURL
        self.gestureLocation = gestureLocation
        self.stopRecording = stopRecording
        self.confirmRecording = confirmRecording
        self.discardRecording = discardRecording
        self.previewRecording = previewRecording
    }
}

// MARK: - Suggestions Options

/// Options for creating the suggestions container view.
public final class SuggestionsContainerViewOptions: @unchecked Sendable {
    /// The suggestions.
    public let suggestions: [String: Any]
    /// Callback to handle a suggestion selection.
    public let handleCommand: @MainActor ([String: Any]) -> Void
    
    public init(suggestions: [String: Any], handleCommand: @escaping @MainActor ([String: Any]) -> Void) {
        self.suggestions = suggestions
        self.handleCommand = handleCommand
    }
}

// MARK: - Quoted Message Options

/// Options for creating the quoted message view.
public final class ComposerQuotedMessageViewOptions: Sendable {
    /// The quoted message to display.
    public let quotedMessage: ChatMessage
    /// The callback when the quoted message view is dismissed.
    public let onDismiss: @MainActor () -> Void

    public init(
        quotedMessage: ChatMessage,
        onDismiss: @escaping @MainActor () -> Void
    ) {
        self.quotedMessage = quotedMessage
        self.onDismiss = onDismiss
    }
}

/// Options for creating the base quoted message view.
public final class QuotedMessageViewOptions: Sendable {
    /// The quoted message to display.
    public let quotedMessage: ChatMessage
    /// Whether the view should use outgoing style.
    public let outgoing: Bool
    /// The padding to apply around the quoted message view.
    public let padding: EdgeInsets?
    
    public init(
        quotedMessage: ChatMessage,
        outgoing: Bool,
        padding: EdgeInsets? = nil
    ) {
        self.quotedMessage = quotedMessage
        self.outgoing = outgoing
        self.padding = padding
    }
}

/// Options for creating the chat quoted message view (message list container).
public final class ChatQuotedMessageViewOptions: Sendable {
    /// The quoted message to display.
    public let quotedMessage: ChatMessage
    /// The parent message which is quoting another message.
    public let parentMessage: ChatMessage
    /// The available width for the quoted message view.
    public let availableWidth: CGFloat?
    /// Binding to the currently scrolled message ID.
    public let scrolledId: Binding<String?>
    
    public init(
        quotedMessage: ChatMessage,
        parentMessage: ChatMessage,
        availableWidth: CGFloat? = nil,
        scrolledId: Binding<String?>
    ) {
        self.quotedMessage = quotedMessage
        self.parentMessage = parentMessage
        self.availableWidth = availableWidth
        self.scrolledId = scrolledId
    }
}

/// Options for creating the message attachment preview view.
public final class MessageAttachmentPreviewViewOptions: Sendable {
    /// The thumbnail to display in the attachment preview.
    public let thumbnail: MessageAttachmentPreviewThumbnail?

    /// Creates new options for the message attachment preview view.
    /// - Parameter thumbnail: The thumbnail to display.
    public init(thumbnail: MessageAttachmentPreviewThumbnail?) {
        self.thumbnail = thumbnail
    }
}

/// Options for creating the edited message header view.
public final class EditedMessageHeaderViewOptions: Sendable {
    /// Binding to the edited message.
    public let editedMessage: Binding<ChatMessage?>
    
    public init(editedMessage: Binding<ChatMessage?>) {
        self.editedMessage = editedMessage
    }
}

/// Options for creating the composer edited message view.
public final class ComposerEditedMessageViewOptions: Sendable {
    /// The edited message to display.
    public let editedMessage: ChatMessage
    /// The callback when the edited message view is dismissed.
    public let onDismiss: @MainActor () -> Void

    public init(
        editedMessage: ChatMessage,
        onDismiss: @escaping @MainActor () -> Void
    ) {
        self.editedMessage = editedMessage
        self.onDismiss = onDismiss
    }
}

/// Options for creating the message attachment preview icon view.
public final class MessageAttachmentPreviewIconViewOptions: Sendable {
    /// The icon type to display.
    public let icon: MessageAttachmentPreviewIcon

    public init(
        icon: MessageAttachmentPreviewIcon
    ) {
        self.icon = icon
    }
}

// MARK: - Poll Options

/// Options for creating the poll attachment picker view.
public final class AttachmentPollPickerViewOptions: Sendable {
    /// The channel controller for the poll.
    public let channelController: ChatChannelController
    /// The message controller for editing messages.
    public let messageController: ChatMessageController?

    public init(channelController: ChatChannelController, messageController: ChatMessageController?) {
        self.channelController = channelController
        self.messageController = messageController
    }
}

/// Options for creating the poll view.
public final class PollViewOptions: Sendable {
    /// The message containing the poll.
    public let message: ChatMessage
    /// The poll data.
    public let poll: Poll
    /// Whether this is the first message in a group.
    public let isFirst: Bool
    /// The available width for the poll view.
    public let availableWidth: CGFloat

    public init(message: ChatMessage, poll: Poll, isFirst: Bool, availableWidth: CGFloat) {
        self.message = message
        self.poll = poll
        self.isFirst = isFirst
        self.availableWidth = availableWidth
    }
}
