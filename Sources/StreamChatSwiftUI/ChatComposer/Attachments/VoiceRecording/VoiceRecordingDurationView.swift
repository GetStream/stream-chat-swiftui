//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct VoiceRecordingDurationView: View {
    @Injected(\.utils) private var utils
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    var duration: TimeInterval
    var usesAccentColor: Bool = false

    var body: some View {
        Text(utils.videoDurationFormatter.format(duration) ?? "")
            .font(fonts.subheadline.monospacedDigit())
            .foregroundColor(Color(usesAccentColor ? colors.accentPrimary : colors.textPrimary))
    }
}
