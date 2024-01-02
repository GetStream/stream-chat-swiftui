//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct RecordingDurationView: View {
    @Injected(\.utils) private var utils
    @Injected(\.colors) private var colors
    
    var duration: TimeInterval
    
    var body: some View {
        Text(utils.videoDurationFormatter.format(duration) ?? "")
            .font(.caption.monospacedDigit())
            .fontWeight(.semibold)
            .foregroundColor(Color(colors.textLowEmphasis))
    }
}
