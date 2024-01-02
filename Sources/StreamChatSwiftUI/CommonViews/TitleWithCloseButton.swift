//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// View displaying a title and a close button.
struct TitleWithCloseButton: View {

    @Injected(\.fonts) private var fonts

    var title: String
    @Binding var isShown: Bool

    var body: some View {
        ZStack {
            HStack {
                Spacer()
                Button {
                    isShown = false
                } label: {
                    DiscardButtonView()
                }
            }

            Text(title)
                .font(fonts.bodyBold)
        }
        .padding()
    }
}
