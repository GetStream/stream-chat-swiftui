//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChatCommonUI
import UIKit

// TODO: Move to common module

extension Appearance.Images {
    var attachmentPlayOverlayIcon: UIImage {
        UIImage(
            systemName: "play.fill",
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: 12,
                weight: .regular
            )
        )!
    }

    var overlayDismissIcon: UIImage {
        UIImage(
            systemName: "xmark",
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: 10,
                weight: .heavy
            )
        )!
    }

    var attachmentImageIcon: UIImage {
        UIImage(
            systemName: "camera",
            withConfiguration: UIImage.SymbolConfiguration(weight: .regular)
        )!
    }

    var attachmentLinkIcon: UIImage {
        UIImage(
            systemName: "link",
            withConfiguration: UIImage.SymbolConfiguration(weight: .regular)
        )!
    }

    var attachmentVideoIcon: UIImage {
        UIImage(
            systemName: "video",
            withConfiguration: UIImage.SymbolConfiguration(weight: .regular)
        )!
    }

    var attachmentDocIcon: UIImage {
        UIImage(
            systemName: "document",
            withConfiguration: UIImage.SymbolConfiguration(weight: .regular)
        )!
    }

    var attachmentVoiceIcon: UIImage {
        UIImage(
            systemName: "microphone",
            withConfiguration: UIImage.SymbolConfiguration(weight: .regular)
        )!
    }

    var attachmentPollIcon: UIImage {
        UIImage(
            systemName: "chart.bar",
            withConfiguration: UIImage.SymbolConfiguration(weight: .regular)
        )!
    }

    var attachmentPhotoIcon: UIImage {
        UIImage(
            systemName: "photo",
            withConfiguration: UIImage.SymbolConfiguration(weight: .regular)
        )!
    }
}
