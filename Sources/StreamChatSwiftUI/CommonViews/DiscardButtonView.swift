//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// View for the discard button.
public struct DiscardButtonView: View {

    @Injected(\.images) private var images

    var color = Color.black.opacity(0.8)

    public init(color: Color = Color.black.opacity(0.8)) {
        self.color = color
    }

    public var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 16, height: 16)

            Image(uiImage: images.closeFilled)
                .renderingMode(.template)
                .foregroundColor(color)
        }
        .padding(.all, 4)
    }
}
