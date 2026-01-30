//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Video attachment preview for message references (video attachments with play button overlay).
public struct ReferenceMessageVideoPreviewView: View {
    let thumbnailImage: Image

    public init(thumbnailImage: Image) {
        self.thumbnailImage = thumbnailImage
    }

    public var body: some View {
        ReferenceMessageImagePreviewView(image: thumbnailImage)
    }
}
