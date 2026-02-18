//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChatCommonUI
import SwiftUI

/// View for picking the type of attachment (photo, files, camera, polls, commands).
public struct AttachmentTypePickerView: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens

    var selected: AttachmentPickerState
    var canSendPoll: Bool
    var onTap: (AttachmentPickerState) -> Void

    public init(
        selected: AttachmentPickerState,
        canSendPoll: Bool,
        onTap: @escaping (AttachmentPickerState) -> Void
    ) {
        self.selected = selected
        self.onTap = onTap
        self.canSendPoll = canSendPoll
    }

    public var body: some View {
        HStack(alignment: .center, spacing: tokens.spacingXxxs) {
            AttachmentTypePickerButton(
                icon: images.attachmentPickerPhotosIcon,
                pickerType: .photos,
                isSelected: selected == .photos,
                onTap: onTap
            )
            .accessibilityIdentifier("attachmentPickerPhotos")

            AttachmentTypePickerButton(
                icon: images.attachmentPickerCameraIcon,
                pickerType: .camera,
                isSelected: selected == .camera,
                onTap: onTap
            )
            .accessibilityIdentifier("attachmentPickerCamera")

            AttachmentTypePickerButton(
                icon: images.attachmentPickerDocumentIcon,
                pickerType: .files,
                isSelected: selected == .files,
                onTap: onTap
            )
            .accessibilityLabel(L10n.Composer.Picker.file)
            .accessibilityIdentifier("attachmentPickerFiles")

            if canSendPoll {
                AttachmentTypePickerButton(
                    icon: images.attachmentPickerPollIcon,
                    pickerType: .polls,
                    isSelected: selected == .polls,
                    onTap: onTap
                )
                .accessibilityLabel(L10n.Composer.Polls.createPoll)
                .accessibilityIdentifier("attachmentPickerPolls")
            }

            AttachmentTypePickerButton(
                icon: images.attachmentPickerCommandIcon,
                pickerType: .commands,
                isSelected: selected == .commands,
                onTap: onTap
            )
            .accessibilityLabel(L10n.Composer.Suggestions.Commands.header)
            .accessibilityIdentifier("attachmentPickerCommands")

            Spacer()
        }
        .padding(.horizontal, tokens.spacingMd)
        .padding(.bottom, tokens.spacingSm)
        .background(Color(colors.backgroundElevationElevation1))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("AttachmentTypePickerView")
    }
}

/// Button used for picking of attachment types.
public struct AttachmentTypePickerButton: View {
    @Injected(\.tokens) private var tokens
    @Injected(\.colors) private var colors

    var icon: UIImage
    var pickerType: AttachmentPickerState
    var isSelected: Bool
    var onTap: (AttachmentPickerState) -> Void

    public init(
        icon: UIImage,
        pickerType: AttachmentPickerState,
        isSelected: Bool,
        onTap: @escaping (AttachmentPickerState) -> Void
    ) {
        self.icon = icon
        self.pickerType = pickerType
        self.isSelected = isSelected
        self.onTap = onTap
    }

    public var body: some View {
        StreamButton(
            icon: Image(uiImage: icon).renderingMode(.template),
            text: nil,
            role: .secondary,
            style: .ghost,
            size: .large,
            isSelected: isSelected
        ) {
            onTap(pickerType)
        }
    }
}
