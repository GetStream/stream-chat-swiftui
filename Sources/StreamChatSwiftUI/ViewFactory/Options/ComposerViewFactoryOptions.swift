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
    /// Callback when a message is sent.
    public let onMessageSent: @MainActor () -> Void
    
    public init(
        channelController: ChatChannelController,
        messageController: ChatMessageController?,
        quotedMessage: Binding<ChatMessage?>,
        editedMessage: Binding<ChatMessage?>,
        onMessageSent: @escaping @MainActor () -> Void
    ) {
        self.channelController = channelController
        self.messageController = messageController
        self.quotedMessage = quotedMessage
        self.editedMessage = editedMessage
        self.onMessageSent = onMessageSent
    }
}

// MARK: - Composer Input Options

/// Options for creating the leading composer view.
public final class LeadingComposerViewOptions: Sendable {
    /// Binding to the picker type state.
    public let state: Binding<PickerTypeState>
    /// The channel configuration.
    public let channelConfig: ChannelConfig?
    
    public init(state: Binding<PickerTypeState>, channelConfig: ChannelConfig?) {
        self.state = state
        self.channelConfig = channelConfig
    }
}

/// Options for creating the composer input view.
public final class ComposerInputViewOptions: Sendable {
    /// The channel controller.
    public let channelController: ChatChannelController
    /// Binding to the text input.
    public let text: Binding<String>
    /// Binding to the selected range location.
    public let selectedRangeLocation: Binding<Int>
    /// Binding to the current command.
    public let command: Binding<ComposerCommand?>
    /// Binding to the recording state.
    public let recordingState: Binding<RecordingState>
    /// The added assets.
    public let addedAssets: [AddedAsset]
    /// The added file URLs.
    public let addedFileURLs: [URL]
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
    /// Callback when a custom attachment is tapped.
    public let onCustomAttachmentTap: @MainActor (CustomAttachment) -> Void
    /// Whether the input should scroll.
    public let shouldScroll: Bool
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
    
    public init(
        channelController: ChatChannelController,
        text: Binding<String>,
        selectedRangeLocation: Binding<Int>,
        command: Binding<ComposerCommand?>,
        recordingState: Binding<RecordingState>,
        addedAssets: [AddedAsset],
        addedFileURLs: [URL],
        addedCustomAttachments: [CustomAttachment],
        addedVoiceRecordings: [AddedVoiceRecording],
        quotedMessage: Binding<ChatMessage?>,
        editedMessage: Binding<ChatMessage?>,
        maxMessageLength: Int?,
        cooldownDuration: Int,
        hasContent: Bool,
        canSendMessage: Bool,
        onCustomAttachmentTap: @escaping @MainActor (CustomAttachment) -> Void,
        shouldScroll: Bool,
        removeAttachmentWithId: @escaping @MainActor (String) -> Void,
        sendMessage: @escaping @MainActor () -> Void,
        onImagePasted: @escaping @MainActor (UIImage) -> Void,
        startRecording: @escaping @MainActor () -> Void,
        stopRecording: @escaping @MainActor () -> Void
    ) {
        self.channelController = channelController
        self.text = text
        self.selectedRangeLocation = selectedRangeLocation
        self.command = command
        self.recordingState = recordingState
        self.addedAssets = addedAssets
        self.addedFileURLs = addedFileURLs
        self.addedCustomAttachments = addedCustomAttachments
        self.addedVoiceRecordings = addedVoiceRecordings
        self.quotedMessage = quotedMessage
        self.editedMessage = editedMessage
        self.maxMessageLength = maxMessageLength
        self.cooldownDuration = cooldownDuration
        self.hasContent = hasContent
        self.canSendMessage = canSendMessage
        self.onCustomAttachmentTap = onCustomAttachmentTap
        self.shouldScroll = shouldScroll
        self.removeAttachmentWithId = removeAttachmentWithId
        self.sendMessage = sendMessage
        self.onImagePasted = onImagePasted
        self.startRecording = startRecording
        self.stopRecording = stopRecording
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
    @Binding public var recordingState: RecordingState
    /// The current composer's input view state.
    public let composerInputState: MessageComposerInputState
    /// The closure for starting a recording.
    public let startRecording: () -> Void
    /// The closure for stopping a recording.
    public let stopRecording: () -> Void
    /// The closure for sending a message.
    public let sendMessage: () -> Void

    public init(
        text: Binding<String>,
        recordingState: Binding<RecordingState>,
        composerInputState: MessageComposerInputState,
        startRecording: @escaping () -> Void,
        stopRecording: @escaping () -> Void,
        sendMessage: @escaping () -> Void
    ) {
        _text = text
        _recordingState = recordingState
        self.composerInputState = composerInputState
        self.startRecording = startRecording
        self.stopRecording = stopRecording
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

// MARK: - Composer Recording Options

/// Options for creating the composer recording view.
public final class ComposerRecordingViewOptions: Sendable {
    /// The view model for the composer.
    public let viewModel: MessageComposerViewModel
    /// The location of the gesture.
    public let gestureLocation: CGPoint
    
    public init(viewModel: MessageComposerViewModel, gestureLocation: CGPoint) {
        self.viewModel = viewModel
        self.gestureLocation = gestureLocation
    }
}

/// Options for creating the composer recording locked view.
public final class ComposerRecordingLockedViewOptions: Sendable {
    /// The view model for the composer.
    public let viewModel: MessageComposerViewModel
    
    public init(viewModel: MessageComposerViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - Commands Options

/// Options for creating the commands container view.
public final class CommandsContainerViewOptions: @unchecked Sendable {
    /// The command suggestions.
    public let suggestions: [String: Any]
    /// Callback to handle a command.
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
    /// The padding to apply around the quoted message view.
    public let padding: EdgeInsets?
    
    public init(
        quotedMessage: ChatMessage,
        padding: EdgeInsets? = nil
    ) {
        self.quotedMessage = quotedMessage
        self.padding = padding
    }
}

/// Options for creating the chat quoted message view (message list container).
public final class ChatQuotedMessageViewOptions: Sendable {
    /// The quoted message to display.
    public let quotedMessage: ChatMessage
    /// Binding to the currently scrolled message ID.
    public let scrolledId: Binding<String?>
    
    public init(
        quotedMessage: ChatMessage,
        scrolledId: Binding<String?>
    ) {
        self.quotedMessage = quotedMessage
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

/// Options for creating the custom attachment quoted view.
public final class CustomAttachmentQuotedViewOptions: Sendable {
    /// The message containing the custom attachment.
    public let message: ChatMessage
    
    public init(message: ChatMessage) {
        self.message = message
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

/// Options for creating the composer poll view.
public final class ComposerPollViewOptions: Sendable {
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
    
    public init(message: ChatMessage, poll: Poll, isFirst: Bool) {
        self.message = message
        self.poll = poll
        self.isFirst = isFirst
    }
}
