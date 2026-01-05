//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View used for the gallery header, for images and videos.
struct GalleryHeaderView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.images) private var images

    var title: String
    var subtitle: String

    @Binding var isShown: Bool

    var body: some View {
        ZStack {
            HStack {
                Button {
                    isShown = false
                } label: {
                    Image(uiImage: images.close)
                        .customizable()
                        .frame(height: 16)
                }
                .padding()
                .foregroundColor(closeImageColor)

                Spacer()
            }

            VStack {
                Text(title)
                    .font(fonts.bodyBold)
                    .foregroundColor(Color(colors.navigationBarTitle))
                Text(subtitle)
                    .font(fonts.footnote)
                    .foregroundColor(Color(colors.navigationBarSubtitle))
            }
        }
        .modifier(GalleryHeaderViewAppearanceViewModifier())
    }
    
    private var closeImageColor: Color {
        // Note that default design uses `text` color
        guard colors.navigationBarTintColor != colors.tintColor else { return Color(colors.text) }
        return colors.navigationBarTintColor
    }
}

private struct GalleryHeaderViewAppearanceViewModifier: ViewModifier {
    @Injected(\.colors) var colors
    
    func body(content: Content) -> some View {
        if let backgroundColor = colors.navigationBarBackground {
            content.background(Color(backgroundColor).edgesIgnoringSafeArea(.top))
        } else {
            content
        }
    }
}
