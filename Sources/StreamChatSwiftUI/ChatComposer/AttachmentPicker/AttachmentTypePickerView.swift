//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

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
                icon: images.attachmentPhotoIcon,
                pickerType: .photos,
                isSelected: selected == .photos,
                onTap: onTap
            )
            .accessibilityIdentifier("attachmentPickerPhotos")

            AttachmentTypePickerButton(
                icon: images.attachmentCameraIcon,
                pickerType: .camera,
                isSelected: selected == .camera,
                onTap: onTap
            )
            .accessibilityIdentifier("attachmentPickerCamera")

            AttachmentTypePickerButton(
                icon: images.attachmentDocumentIcon,
                pickerType: .files,
                isSelected: selected == .files,
                onTap: onTap
            )
            .accessibilityLabel(L10n.Composer.Picker.file)
            .accessibilityIdentifier("attachmentPickerFiles")

            if canSendPoll {
                AttachmentTypePickerButton(
                    icon: images.attachmentPollIcon,
                    pickerType: .polls,
                    isSelected: selected == .polls,
                    onTap: onTap
                )
                .accessibilityLabel(L10n.Composer.Polls.createPoll)
                .accessibilityIdentifier("attachmentPickerPolls")
            }

            AttachmentTypePickerButton(
                icon: images.attachmentCommandIcon,
                pickerType: .commands,
                isSelected: selected == .commands,
                onTap: onTap
            )
            .accessibilityLabel(L10n.Composer.Suggestions.Commands.header)
            .accessibilityIdentifier("attachmentPickerCommands")

            Spacer()
        }
        .padding(.horizontal, tokens.spacingMd)
        .padding(.vertical, tokens.spacingSm)
        .background(Color(colors.backgroundCoreElevation1))
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
        StreamIconButton(
            role: .secondary,
            style: .ghost,
            size: .large,
            isSelected: isSelected,
            action: { onTap(pickerType) }
        ) {
            Image(uiImage: icon)
                .customizable()
                .frame(width: 18, height: 18)
        }
    }
}
