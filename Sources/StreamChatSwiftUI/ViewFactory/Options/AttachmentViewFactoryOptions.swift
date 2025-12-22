//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Foundation
import Photos
import StreamChat
import SwiftUI

// MARK: - Image Attachment Options

/// Options for creating the image attachment view.
public final class ImageAttachmentViewOptions: Sendable {
    /// The message containing the image attachment.
    public let message: ChatMessage
    /// Whether this is the first message in a group.
    public let isFirst: Bool
    /// The available width for the attachment.
    public let availableWidth: CGFloat
    /// Binding to the currently scrolled message ID.
    public let scrolledId: Binding<String?>
    
    public init(
        message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) {
        self.message = message
        self.isFirst = isFirst
        self.availableWidth = availableWidth
        self.scrolledId = scrolledId
    }
}

// MARK: - Giphy Attachment Options

/// Options for creating the giphy attachment view.
public final class GiphyAttachmentViewOptions: Sendable {
    /// The message containing the giphy attachment.
    public let message: ChatMessage
    /// Whether this is the first message in a group.
    public let isFirst: Bool
    /// The available width for the attachment.
    public let availableWidth: CGFloat
    /// Binding to the currently scrolled message ID.
    public let scrolledId: Binding<String?>
    
    public init(
        message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) {
        self.message = message
        self.isFirst = isFirst
        self.availableWidth = availableWidth
        self.scrolledId = scrolledId
    }
}

/// Options for creating the giphy badge view.
public final class GiphyBadgeViewTypeOptions: Sendable {
    /// The message containing the giphy attachment.
    public let message: ChatMessage
    /// The available width for the badge.
    public let availableWidth: CGFloat
    
    public init(message: ChatMessage, availableWidth: CGFloat) {
        self.message = message
        self.availableWidth = availableWidth
    }
}

// MARK: - Link Attachment Options

/// Options for creating the link attachment view.
public final class LinkAttachmentViewOptions: Sendable {
    /// The message containing the link attachment.
    public let message: ChatMessage
    /// Whether this is the first message in a group.
    public let isFirst: Bool
    /// The available width for the attachment.
    public let availableWidth: CGFloat
    /// Binding to the currently scrolled message ID.
    public let scrolledId: Binding<String?>
    
    public init(
        message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) {
        self.message = message
        self.isFirst = isFirst
        self.availableWidth = availableWidth
        self.scrolledId = scrolledId
    }
}

// MARK: - File Attachment Options

/// Options for creating the file attachment view.
public final class FileAttachmentViewOptions: Sendable {
    /// The message containing the file attachment.
    public let message: ChatMessage
    /// Whether this is the first message in a group.
    public let isFirst: Bool
    /// The available width for the attachment.
    public let availableWidth: CGFloat
    /// Binding to the currently scrolled message ID.
    public let scrolledId: Binding<String?>
    
    public init(
        message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) {
        self.message = message
        self.isFirst = isFirst
        self.availableWidth = availableWidth
        self.scrolledId = scrolledId
    }
}

// MARK: - Video Attachment Options

/// Options for creating the video attachment view.
public final class VideoAttachmentViewOptions: Sendable {
    /// The message containing the video attachment.
    public let message: ChatMessage
    /// Whether this is the first message in a group.
    public let isFirst: Bool
    /// The available width for the attachment.
    public let availableWidth: CGFloat
    /// Binding to the currently scrolled message ID.
    public let scrolledId: Binding<String?>
    
    public init(
        message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) {
        self.message = message
        self.isFirst = isFirst
        self.availableWidth = availableWidth
        self.scrolledId = scrolledId
    }
}

// MARK: - Voice Recording Options

/// Options for creating the voice recording view.
public final class VoiceRecordingViewOptions: Sendable {
    /// The message containing the voice recording.
    public let message: ChatMessage
    /// Whether this is the first message in a group.
    public let isFirst: Bool
    /// The available width for the attachment.
    public let availableWidth: CGFloat
    /// Binding to the currently scrolled message ID.
    public let scrolledId: Binding<String?>
    
    public init(
        message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) {
        self.message = message
        self.isFirst = isFirst
        self.availableWidth = availableWidth
        self.scrolledId = scrolledId
    }
}

// MARK: - Custom Attachment Options

/// Options for creating the custom attachment view.
public final class CustomAttachmentViewTypeOptions: Sendable {
    /// The message containing the custom attachment.
    public let message: ChatMessage
    /// Whether this is the first message in a group.
    public let isFirst: Bool
    /// The available width for the attachment.
    public let availableWidth: CGFloat
    /// Binding to the currently scrolled message ID.
    public let scrolledId: Binding<String?>
    
    public init(
        message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) {
        self.message = message
        self.isFirst = isFirst
        self.availableWidth = availableWidth
        self.scrolledId = scrolledId
    }
}

/// Options for creating the custom composer attachment view.
public final class CustomComposerAttachmentViewOptions: Sendable {
    /// The added custom attachments.
    public let addedCustomAttachments: [CustomAttachment]
    /// Callback when a custom attachment is tapped.
    public let onCustomAttachmentTap: @MainActor (CustomAttachment) -> Void
    
    public init(
        addedCustomAttachments: [CustomAttachment],
        onCustomAttachmentTap: @escaping @MainActor (CustomAttachment) -> Void
    ) {
        self.addedCustomAttachments = addedCustomAttachments
        self.onCustomAttachmentTap = onCustomAttachmentTap
    }
}

/// Options for creating the custom attachment preview view.
public final class CustomAttachmentPreviewViewOptions: Sendable {
    /// The added custom attachments.
    public let addedCustomAttachments: [CustomAttachment]
    /// Callback when a custom attachment is tapped.
    public let onCustomAttachmentTap: @MainActor (CustomAttachment) -> Void
    
    public init(
        addedCustomAttachments: [CustomAttachment],
        onCustomAttachmentTap: @escaping @MainActor (CustomAttachment) -> Void
    ) {
        self.addedCustomAttachments = addedCustomAttachments
        self.onCustomAttachmentTap = onCustomAttachmentTap
    }
}

// MARK: - Gallery Options

/// Options for creating the gallery view.
public final class GalleryViewOptions: Sendable {
    /// The media attachments to display.
    public let mediaAttachments: [MediaAttachment]
    /// The message containing the attachments.
    public let message: ChatMessage
    /// Binding to whether the gallery is shown.
    public let isShown: Binding<Bool>
    /// Additional options for the media views.
    public let options: MediaViewsOptions
    
    public init(
        mediaAttachments: [MediaAttachment],
        message: ChatMessage,
        isShown: Binding<Bool>,
        options: MediaViewsOptions
    ) {
        self.mediaAttachments = mediaAttachments
        self.message = message
        self.isShown = isShown
        self.options = options
    }
}

/// Options for creating the gallery header view.
public final class GalleryHeaderViewOptions: Sendable {
    /// The title to display in the header.
    public let title: String
    /// The subtitle to display in the header.
    public let subtitle: String
    /// Binding to whether the header is shown.
    public let shown: Binding<Bool>
    
    public init(title: String, subtitle: String, shown: Binding<Bool>) {
        self.title = title
        self.subtitle = subtitle
        self.shown = shown
    }
}

// MARK: - Video Player Options

/// Options for creating the video player view.
public final class VideoPlayerViewOptions: Sendable {
    /// The video attachment to play.
    public let attachment: ChatMessageVideoAttachment
    /// The message containing the video.
    public let message: ChatMessage
    /// Binding to whether the player is shown.
    public let isShown: Binding<Bool>
    /// Additional options for the media views.
    public let options: MediaViewsOptions
    
    public init(
        attachment: ChatMessageVideoAttachment,
        message: ChatMessage,
        isShown: Binding<Bool>,
        options: MediaViewsOptions
    ) {
        self.attachment = attachment
        self.message = message
        self.isShown = isShown
        self.options = options
    }
}

/// Options for creating the video player header view.
public final class VideoPlayerHeaderViewOptions: Sendable {
    /// The title to display in the header.
    public let title: String
    /// The subtitle to display in the header.
    public let subtitle: String
    /// Binding to whether the header is shown.
    public let shown: Binding<Bool>
    
    public init(title: String, subtitle: String, shown: Binding<Bool>) {
        self.title = title
        self.subtitle = subtitle
        self.shown = shown
    }
}

/// Options for creating the video player footer view.
public final class VideoPlayerFooterViewOptions: Sendable {
    /// The video attachment being played.
    public let attachment: ChatMessageVideoAttachment
    /// Binding to whether the footer is shown.
    public let shown: Binding<Bool>
    
    public init(attachment: ChatMessageVideoAttachment, shown: Binding<Bool>) {
        self.attachment = attachment
        self.shown = shown
    }
}

// MARK: - Attachment Picker Options

/// Options for creating the attachment picker view.
public final class AttachmentPickerViewOptions: Sendable {
    /// Binding to the attachment picker state.
    public let attachmentPickerState: Binding<AttachmentPickerState>
    /// Binding to whether the file picker is shown.
    public let filePickerShown: Binding<Bool>
    /// Binding to whether the camera picker is shown.
    public let cameraPickerShown: Binding<Bool>
    /// Binding to the added file URLs.
    public let addedFileURLs: Binding<[URL]>
    /// Callback when the picker state changes.
    public let onPickerStateChange: @MainActor (AttachmentPickerState) -> Void
    /// The photo library assets.
    public let photoLibraryAssets: PHFetchResult<PHAsset>?
    /// Callback when an asset is tapped.
    public let onAssetTap: @MainActor (AddedAsset) -> Void
    /// Callback when a custom attachment is tapped.
    public let onCustomAttachmentTap: @MainActor (CustomAttachment) -> Void
    /// Function to check if an asset is selected.
    public let isAssetSelected: @MainActor (String) -> Bool
    /// The added custom attachments.
    public let addedCustomAttachments: [CustomAttachment]
    /// Callback when a camera image is added.
    public let cameraImageAdded: @MainActor (AddedAsset) -> Void
    /// Callback to ask for assets access permissions.
    public let askForAssetsAccessPermissions: @MainActor () -> Void
    /// Whether the picker is displayed.
    public let isDisplayed: Bool
    /// The height of the picker.
    public let height: CGFloat
    /// The popup height of the picker.
    public let popupHeight: CGFloat
    /// Snapshot of the currently selected asset identifiers.
    public let selectedAssetIds: [String]?
    
    public init(
        attachmentPickerState: Binding<AttachmentPickerState>,
        filePickerShown: Binding<Bool>,
        cameraPickerShown: Binding<Bool>,
        addedFileURLs: Binding<[URL]>,
        onPickerStateChange: @escaping @MainActor (AttachmentPickerState) -> Void,
        photoLibraryAssets: PHFetchResult<PHAsset>?,
        onAssetTap: @escaping @MainActor (AddedAsset) -> Void,
        onCustomAttachmentTap: @escaping @MainActor (CustomAttachment) -> Void,
        isAssetSelected: @escaping @MainActor (String) -> Bool,
        addedCustomAttachments: [CustomAttachment],
        cameraImageAdded: @escaping @MainActor (AddedAsset) -> Void,
        askForAssetsAccessPermissions: @escaping @MainActor () -> Void,
        isDisplayed: Bool,
        height: CGFloat,
        popupHeight: CGFloat,
        selectedAssetIds: [String]? = nil
    ) {
        self.attachmentPickerState = attachmentPickerState
        self.filePickerShown = filePickerShown
        self.cameraPickerShown = cameraPickerShown
        self.addedFileURLs = addedFileURLs
        self.onPickerStateChange = onPickerStateChange
        self.photoLibraryAssets = photoLibraryAssets
        self.onAssetTap = onAssetTap
        self.onCustomAttachmentTap = onCustomAttachmentTap
        self.isAssetSelected = isAssetSelected
        self.addedCustomAttachments = addedCustomAttachments
        self.cameraImageAdded = cameraImageAdded
        self.askForAssetsAccessPermissions = askForAssetsAccessPermissions
        self.isDisplayed = isDisplayed
        self.height = height
        self.popupHeight = popupHeight
        self.selectedAssetIds = selectedAssetIds
    }
}

/// Options for creating the attachment source picker view.
public final class AttachmentSourcePickerViewOptions: Sendable {
    /// The currently selected picker state.
    public let selected: AttachmentPickerState
    /// Callback when the picker state changes.
    public let onPickerStateChange: @MainActor (AttachmentPickerState) -> Void
    
    public init(selected: AttachmentPickerState, onPickerStateChange: @escaping @MainActor (AttachmentPickerState) -> Void) {
        self.selected = selected
        self.onPickerStateChange = onPickerStateChange
    }
}

/// Options for creating the photo attachment picker view.
public final class PhotoAttachmentPickerViewOptions: Sendable {
    /// The assets to display in the picker.
    public let assets: PHFetchResultCollection
    /// Callback when an asset is tapped.
    public let onAssetTap: @MainActor (AddedAsset) -> Void
    /// Function to check if an asset is selected.
    public let isAssetSelected: @MainActor (String) -> Bool
    /// Snapshot of the currently selected asset identifiers.
    public let selectedAssetIds: [String]?
    
    public init(
        assets: PHFetchResultCollection,
        onAssetTap: @escaping @MainActor (AddedAsset) -> Void,
        isAssetSelected: @escaping @MainActor (String) -> Bool,
        selectedAssetIds: [String]? = nil
    ) {
        self.assets = assets
        self.onAssetTap = onAssetTap
        self.isAssetSelected = isAssetSelected
        self.selectedAssetIds = selectedAssetIds
    }
}

/// Options for creating the file picker view.
public final class FilePickerViewOptions: Sendable {
    /// Binding to whether the file picker is shown.
    public let filePickerShown: Binding<Bool>
    /// Binding to the added file URLs.
    public let addedFileURLs: Binding<[URL]>
    
    public init(filePickerShown: Binding<Bool>, addedFileURLs: Binding<[URL]>) {
        self.filePickerShown = filePickerShown
        self.addedFileURLs = addedFileURLs
    }
}

/// Options for creating the camera picker view.
public final class CameraPickerViewOptions: Sendable {
    /// Binding to the selected picker state.
    public let selected: Binding<AttachmentPickerState>
    /// Binding to whether the camera picker is shown.
    public let cameraPickerShown: Binding<Bool>
    /// Callback when a camera image is added.
    public let cameraImageAdded: @MainActor (AddedAsset) -> Void
    
    public init(
        selected: Binding<AttachmentPickerState>,
        cameraPickerShown: Binding<Bool>,
        cameraImageAdded: @escaping @MainActor (AddedAsset) -> Void
    ) {
        self.selected = selected
        self.cameraPickerShown = cameraPickerShown
        self.cameraImageAdded = cameraImageAdded
    }
}
