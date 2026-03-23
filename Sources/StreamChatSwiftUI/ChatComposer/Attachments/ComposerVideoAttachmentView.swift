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
        let duration = attachment.duration ?? attachment.extraData["duration"]?.numberValue
        guard let duration else { return "0s" }
        return utils.mediaBadgeDurationFormatter.shortFormat(duration)
    }
}
