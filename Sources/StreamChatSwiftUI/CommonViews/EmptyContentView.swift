//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Default view displayed when there's no content for different types of data (channels, messages, media).
struct EmptyContentView: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors

    var image: UIImage
    var title: String?
    var description: String
    var shouldRotateImage: Bool = false
    var size: CGSize = CGSize(width: 32, height: 32)

    public var body: some View {
        VStack(spacing: 8) {
            Spacer()

            VStack(spacing: 8) {
                Image(uiImage: image)
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size.width, height: size.height)
                    .rotation3DEffect(
                        shouldRotateImage ? .degrees(180) : .zero, axis: (x: 0, y: 1, z: 0)
                    )
                    .foregroundColor(Color(colors.textTertiary))
                title.map { Text($0) }
                    .font(fonts.headline)
                    .foregroundColor(Color(colors.textPrimary))
                Text(description)
                    .font(fonts.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(colors.textSecondary))
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color(colors.backgroundCoreApp))
    }

    private var bottomButtonPadding: CGFloat {
        bottomSafeArea + 40
    }
}
