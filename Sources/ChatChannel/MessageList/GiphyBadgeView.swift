//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Default view for the giphy badge.
public struct GiphyBadgeView: View {
    @Injected(\.images) var images
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    
    public var body: some View {
        BottomLeftView {
            HStack(spacing: 4) {
                Image(uiImage: images.commandGiphy)
                Text("GIPHY")
                    .font(fonts.bodyBold)
                    .foregroundColor(Color(colors.staticColorText))
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(Color.black.opacity(0.6))
            .cornerRadius(24)
            .padding(.all, 8)
        }
    }
}
