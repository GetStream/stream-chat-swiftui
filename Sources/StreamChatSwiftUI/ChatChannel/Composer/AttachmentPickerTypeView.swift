//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Enum for the picker type state.
public enum PickerTypeState: Equatable, Sendable {
    /// Picker is expanded, with a selected `AttachmentPickerType`.
    case expanded(AttachmentPickerType)
}

/// Attachment picker type.
public enum AttachmentPickerType: Sendable {
    /// None is selected.
    case none
    /// Media (images, files, videos) is selected.
    case media
    /// Instant commands are selected.
    case instantCommands
    /// Custom attachment picker type.
    case custom
}

// TODO: maybe remove this view.
/// View for picking the attachment type (media or giphy commands).
public struct AttachmentPickerTypeView: View {
    @Injected(\.images) private var images
    @Injected(\.colors) private var colors

    @Binding var pickerTypeState: PickerTypeState
    var channelConfig: ChannelConfig?
    var channelController: ChatChannelController
    var isSendMessageEnabled: Bool

    public init(
        pickerTypeState: Binding<PickerTypeState>,
        channelConfig: ChannelConfig?,
        channelController: ChatChannelController,
        isSendMessageEnabled: Bool
    ) {
        _pickerTypeState = pickerTypeState
        self.channelConfig = channelConfig
        self.isSendMessageEnabled = isSendMessageEnabled
        self.channelController = channelController
    }

    private var commandsAvailable: Bool {
        channelConfig?.commands.count ?? 0 > 0
    }

    public var body: some View {
        HStack(spacing: 16) {
            switch pickerTypeState {
            case let .expanded(attachmentPickerType):
                if channelController.channel?.canUploadFile == true && isSendMessageEnabled {
                    PickerTypeButton(
                        pickerTypeState: $pickerTypeState,
                        pickerType: .media,
                        selected: attachmentPickerType
                    )
                    .accessibilityLabel(Text(L10n.Composer.Picker.showAll))
                    .accessibilityIdentifier("PickerTypeButtonMedia")
                }

                if commandsAvailable && isSendMessageEnabled {
                    PickerTypeButton(
                        pickerTypeState: $pickerTypeState,
                        pickerType: .instantCommands,
                        selected: attachmentPickerType
                    )
                    .accessibilityLabel(Text(L10n.Composer.Suggestions.Commands.header))
                    .accessibilityIdentifier("PickerTypeButtonCommands")
                    }
            }
        }
        .accessibilityElement(children: .contain)
    }
}

/// View for the picker type button.
struct PickerTypeButton: View {
    @Injected(\.images) private var images
    @Injected(\.colors) private var colors

    @Binding var pickerTypeState: PickerTypeState

    let pickerType: AttachmentPickerType
    let selected: AttachmentPickerType

    var body: some View {
        Button {
            withAnimation {
                onTap(attachmentType: pickerType, selected: selected)
            }
        } label: {
            Image(uiImage: icon)
                .renderingMode(.template)
                .aspectRatio(contentMode: .fill)
                .frame(height: 18)
                .foregroundColor(
                    foregroundColor(for: pickerType, selected: selected)
                )
        }
    }

    private var icon: UIImage {
        if pickerType == .media {
            images.openAttachments
        } else {
            images.commands
        }
    }

    private func onTap(
        attachmentType: AttachmentPickerType,
        selected: AttachmentPickerType
    ) {
        if selected == attachmentType {
            pickerTypeState = .expanded(.none)
        } else {
            pickerTypeState = .expanded(attachmentType)
        }
    }

    private func foregroundColor(
        for pickerType: AttachmentPickerType,
        selected: AttachmentPickerType
    ) -> Color {
        if pickerType == selected {
            Color(colors.highlightedAccentBackground)
        } else {
            Color(colors.textLowEmphasis)
        }
    }
}
