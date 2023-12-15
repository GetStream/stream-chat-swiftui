//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct RecordingDurationView: View {
    @Injected(\.utils) private var utils
    @Injected(\.colors) private var colors
    
    var duration: TimeInterval
    
    var body: some View {
        Text(utils.videoDurationFormatter.format(duration) ?? "")
            .font(.caption)
            .foregroundColor(Color(colors.textLowEmphasis))
    }
}
