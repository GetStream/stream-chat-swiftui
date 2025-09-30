//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import SwiftUI

// MARK: - Composer View Options

/// Options for creating the message composer view.
public class MessageComposerViewTypeOptions {
    /// The channel controller for the composer.
    public let channelController: ChatChannelController
    /// The message controller for editing messages.
    public let messageController: ChatMessageController?
    /// Binding to the quoted message.
    public let quotedMessage: Binding<ChatMessage?>
    /// Binding to the edited message.
    public let editedMessage: Binding<ChatMessage?>
    /// Callback when a message is sent.
    public let onMessageSent: @MainActor() -> Void
    
    public init(
        channelController: ChatChannelController,
        messageController: ChatMessageController?,
        quotedMessage: Binding<ChatMessage?>,
        editedMessage: Binding<ChatMessage?>,
        onMessageSent: @escaping @MainActor() -> Void
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
public class LeadingComposerViewOptions {
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
public class ComposerInputViewOptions {
    /// Binding to the text input.
    public let text: Binding<String>
    /// Binding to the selected range location.
    public let selectedRangeLocation: Binding<Int>
    /// Binding to the current command.
    public let command: Binding<ComposerCommand?>
    /// The added assets.
    public let addedAssets: [AddedAsset]
    /// The added file URLs.
    public let addedFileURLs: [URL]
    /// The added custom attachments.
    public let addedCustomAttachments: [CustomAttachment]
    /// Binding to the quoted message.
    public let quotedMessage: Binding<ChatMessage?>
    /// The maximum message length.
    public let maxMessageLength: Int?
    /// The cooldown duration in seconds.
    public let cooldownDuration: Int
    /// Callback when a custom attachment is tapped.
    public let onCustomAttachmentTap: @MainActor(CustomAttachment) -> Void
    /// Whether the input should scroll.
    public let shouldScroll: Bool
    /// Callback to remove an attachment by ID.
    public let removeAttachmentWithId: @MainActor(String) -> Void
    
    public init(
        text: Binding<String>,
        selectedRangeLocation: Binding<Int>,
        command: Binding<ComposerCommand?>,
        addedAssets: [AddedAsset],
        addedFileURLs: [URL],
        addedCustomAttachments: [CustomAttachment],
        quotedMessage: Binding<ChatMessage?>,
        maxMessageLength: Int?,
        cooldownDuration: Int,
        onCustomAttachmentTap: @escaping @MainActor(CustomAttachment) -> Void,
        shouldScroll: Bool,
        removeAttachmentWithId: @escaping @MainActor(String) -> Void
    ) {
        self.text = text
        self.selectedRangeLocation = selectedRangeLocation
        self.command = command
        self.addedAssets = addedAssets
        self.addedFileURLs = addedFileURLs
        self.addedCustomAttachments = addedCustomAttachments
        self.quotedMessage = quotedMessage
        self.maxMessageLength = maxMessageLength
        self.cooldownDuration = cooldownDuration
        self.onCustomAttachmentTap = onCustomAttachmentTap
        self.shouldScroll = shouldScroll
        self.removeAttachmentWithId = removeAttachmentWithId
    }
}

/// Options for creating the composer text input view.
public class ComposerTextInputViewOptions {
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
    
    public init(
        text: Binding<String>,
        height: Binding<CGFloat>,
        selectedRangeLocation: Binding<Int>,
        placeholder: String,
        editable: Bool,
        maxMessageLength: Int?,
        currentHeight: CGFloat
    ) {
        self.text = text
        self.height = height
        self.selectedRangeLocation = selectedRangeLocation
        self.placeholder = placeholder
        self.editable = editable
        self.maxMessageLength = maxMessageLength
        self.currentHeight = currentHeight
    }
}

/// Options for creating the trailing composer view.
public class TrailingComposerViewOptions {
    /// Whether the composer is enabled.
    public let enabled: Bool
    /// The cooldown duration in seconds.
    public let cooldownDuration: Int
    /// Callback when the trailing view is tapped.
    public let onTap: @MainActor() -> Void
    
    public init(enabled: Bool, cooldownDuration: Int, onTap: @escaping @MainActor() -> Void) {
        self.enabled = enabled
        self.cooldownDuration = cooldownDuration
        self.onTap = onTap
    }
}

// MARK: - Composer Recording Options

/// Options for creating the composer recording view.
public class ComposerRecordingViewOptions {
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
public class ComposerRecordingLockedViewOptions {
    /// The view model for the composer.
    public let viewModel: MessageComposerViewModel
    
    public init(viewModel: MessageComposerViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - Commands Options

/// Options for creating the commands container view.
public class CommandsContainerViewOptions {
    /// The command suggestions.
    public let suggestions: [String: Any]
    /// Callback to handle a command.
    public let handleCommand: @MainActor([String: Any]) -> Void
    
    public init(suggestions: [String: Any], handleCommand: @escaping @MainActor([String: Any]) -> Void) {
        self.suggestions = suggestions
        self.handleCommand = handleCommand
    }
}

// MARK: - Quoted Message Options

/// Options for creating the quoted message header view.
public class QuotedMessageHeaderViewOptions {
    /// Binding to the quoted message.
    public let quotedMessage: Binding<ChatMessage?>
    
    public init(quotedMessage: Binding<ChatMessage?>) {
        self.quotedMessage = quotedMessage
    }
}

/// Options for creating the quoted message view.
public class QuotedMessageViewOptions {
    /// The quoted message to display.
    public let quotedMessage: ChatMessage
    /// Whether to fill the available space.
    public let fillAvailableSpace: Bool
    /// Whether the view is in the composer.
    public let isInComposer: Bool
    /// Binding to the currently scrolled message ID.
    public let scrolledId: Binding<String?>
    
    public init(
        quotedMessage: ChatMessage,
        fillAvailableSpace: Bool,
        isInComposer: Bool,
        scrolledId: Binding<String?>
    ) {
        self.quotedMessage = quotedMessage
        self.fillAvailableSpace = fillAvailableSpace
        self.isInComposer = isInComposer
        self.scrolledId = scrolledId
    }
}

/// Options for creating the custom attachment quoted view.
public class CustomAttachmentQuotedViewOptions {
    /// The message containing the custom attachment.
    public let message: ChatMessage
    
    public init(message: ChatMessage) {
        self.message = message
    }
}

/// Options for creating the edited message header view.
public class EditedMessageHeaderViewOptions {
    /// Binding to the edited message.
    public let editedMessage: Binding<ChatMessage?>
    
    public init(editedMessage: Binding<ChatMessage?>) {
        self.editedMessage = editedMessage
    }
}

// MARK: - Poll Options

/// Options for creating the composer poll view.
public class ComposerPollViewOptions {
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
public class PollViewOptions {
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
