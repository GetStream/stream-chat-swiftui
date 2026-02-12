//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for an added video displayed in the composer input.
/// Uses the image attachment view with a video duration badge overlay.
struct ComposerVideoAttachmentView: View {
    let attachment: AddedAsset
    let imageSize: CGFloat
    let onDiscardAttachment: (String) -> Void

    var body: some View {
        ComposerImageAttachmentView(
            attachment: attachment,
            imageSize: imageSize,
            onDiscardAttachment: onDiscardAttachment
        )
        .mediaBadgeOverlay {
            VideoMediaBadge(durationText: videoDurationText)
        }
    }

    private var videoDurationText: String {
        guard let raw = attachment.extraData["duration"] else { return "0s" }
        guard case let .string(durationString) = raw else { return "0s" }
        let seconds = parseDurationString(durationString)
        return "\(seconds)s"
    }

    private func parseDurationString(_ string: String) -> Int {
        let parts = string.split(separator: ":")
        guard parts.count >= 2,
              let minutes = Int(parts[0]),
              let seconds = Int(parts[1]) else {
            return 0
        }
        return minutes * 60 + seconds
    }
}
