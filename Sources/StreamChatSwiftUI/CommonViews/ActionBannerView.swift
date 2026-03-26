//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct ActionBannerView: View {
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens
    @Injected(\.fonts) private var fonts

    let text: String
    let image: UIImage
    let action: () -> Void

    public var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: tokens.spacingSm) {
                Spacer()
                
                Image(uiImage: image)
                    .customizable()
                    .frame(width: tokens.iconSizeMd, height: tokens.iconSizeMd)
                    .foregroundColor(Color(colors.textSecondary))

                Text(text)
                    .font(fonts.footnoteBold)
                    .foregroundColor(Color(colors.textSecondary))
                
                Spacer()
            }
            .padding(.all, 16)
            .background(Color(colors.backgroundCoreSurfaceDefault))
        }
    }
}
