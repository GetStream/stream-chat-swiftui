//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View used as a video player's footer.
struct VideoPlayerFooterView: View {
    @Injected(\.colors) private var colors

    let attachment: ChatMessageVideoAttachment
    @Binding var shown: Bool

    var body: some View {
        HStack {
            ShareButtonView(content: [attachment.payload.videoURL])
                .standardPadding()

            Spacer()
        }
        .foregroundColor(Color(colors.text))
    }
}
