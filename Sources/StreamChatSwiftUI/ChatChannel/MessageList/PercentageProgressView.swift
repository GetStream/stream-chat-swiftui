//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// A view used to show the progress of a task a long with the percentage.
struct PercentageProgressView: View {
    @Injected(\.images) private var images
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    let progress: CGFloat

    var body: some View {
        HStack(spacing: 4) {
            ProgressView()
                .progressViewStyle(
                    CircularProgressViewStyle(tint: .white)
                )
                .scaleEffect(0.7)

            Text(progressDisplay(for: progress))
                .font(fonts.footnote)
                .foregroundColor(Color(colors.staticColorText))
        }
        .padding(.all, 4)
        .background(Color.black.opacity(0.7))
        .cornerRadius(8)
        .padding(.all, 8)
    }

    private func progressDisplay(for progress: CGFloat) -> String {
        let value = Int(progress * 100)
        return "\(value)%"
    }
}
