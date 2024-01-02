//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct RecordingTipView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    
    var body: some View {
        Text(L10n.Composer.Recording.tip)
            .font(fonts.caption1)
            .bold()
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color(colors.background6))
    }
}
