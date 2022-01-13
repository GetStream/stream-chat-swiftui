//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Enum for the picker type state.
public enum PickerTypeState {
    /// Picker is expanded, with a selected `AttachmentPickerType`.
    case expanded(AttachmentPickerType)
    /// Picker is collapsed.
    case collapsed
}

/// Attachment picker type.
public enum AttachmentPickerType {
    /// None is selected.
    case none
    /// Media (images, files, videos) is selected.
    case media
    /// Instant commands are selected.
    case instantCommands
    /// Custom attachment picker type.
    case custom
}

/// View for picking the attachment type (media or giphy commands).
public struct AttachmentPickerTypeView: View {
    @Injected(\.images) private var images
    @Injected(\.colors) private var colors
    
    @Binding var pickerTypeState: PickerTypeState
    var channelConfig: ChannelConfig?
    
    public var body: some View {
        HStack(spacing: 16) {
            switch pickerTypeState {
            case let .expanded(attachmentPickerType):
                if channelConfig?.uploadsEnabled == true {
                    PickerTypeButton(
                        pickerTypeState: $pickerTypeState,
                        pickerType: .media,
                        selected: attachmentPickerType
                    )
                }
                
                PickerTypeButton(
                    pickerTypeState: $pickerTypeState,
                    pickerType: .instantCommands,
                    selected: attachmentPickerType
                )
            case .collapsed:
                Button {
                    withAnimation {
                        pickerTypeState = .expanded(.none)
                    }
                } label: {
                    Image(uiImage: images.shrinkInputArrow)
                        .renderingMode(.template)
                        .foregroundColor(Color(colors.highlightedAccentBackground))
                }
            }
        }
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
            return images.openAttachments
        } else {
            return images.commands
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
            return Color(colors.highlightedAccentBackground)
        } else {
            return Color(colors.textLowEmphasis)
        }
    }
}
