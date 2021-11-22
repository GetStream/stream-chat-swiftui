//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Default SDK implementation for the view displayed when there are no channels available.
///
/// Different view can be injected in its place.
public struct NoChannelsView: View {
    @Injected(\.fonts) var fonts
    @Injected(\.colors) var colors
    
    public var body: some View {
        VStack(spacing: 8) {
            Spacer()
            
            VStack(spacing: 8) {
                Image(systemName: "message")
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    .aspectRatio(contentMode: .fit)
                    .font(.system(size: 100))
                    .foregroundColor(Color(colors.textLowEmphasis))
                Text(L10n.Channel.NoContent.title)
                    .font(fonts.bodyBold)
                Text(L10n.Channel.NoContent.message)
                    .font(fonts.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(colors.subtitleText))
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color(colors.background1))
    }
    
    private var bottomButtonPadding: CGFloat {
        bottomSafeArea + 40
    }
}
