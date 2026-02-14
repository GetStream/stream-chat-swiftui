//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for an added video displayed in the composer input.
/// Uses the image attachment view with a video duration badge overlay.
struct ComposerVideoAttachmentView: View {
    @Injected(\.utils) private var utils

    let attachment: AddedAsset
    let onDiscardAttachment: (String) -> Void

    var body: some View {
        ComposerImageAttachmentView(
            attachment: attachment,
            onDiscardAttachment: onDiscardAttachment
        )
        .mediaBadgeOverlay {
            VideoMediaBadge(durationText: videoDurationText)
        }
    }

    private var videoDurationText: String {
        guard let duration = attachment.extraData["duration"]?.numberValue else {
            return "0s"
        }
        return utils.videoDurationShortFormatter.format(duration) ?? "0s"
    }
}
