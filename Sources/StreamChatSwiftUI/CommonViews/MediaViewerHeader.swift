//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View used for the gallery header, for images and videos.
struct MediaViewerHeader: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.images) private var images

    var title: String
    var subtitle: String

    @Binding var isShown: Bool

    var body: some View {
        ZStack {
            HStack {
                StreamIconButton(role: .primary, style: .ghost, size: .medium) {
                    isShown = false
                } icon: {
                    Image(uiImage: images.back)
                        .customizable()
                        .foregroundColor(closeImageColor)
                        .frame(height: 16)
                }
                .padding()

                Spacer()
            }

            VStack {
                Text(title)
                    .font(fonts.headline)
                    .foregroundColor(Color(colors.textPrimary))
                Text(subtitle)
                    .font(fonts.subheadline)
                    .foregroundColor(Color(colors.textSecondary))
            }
        }
        .modifier(GalleryHeaderViewAppearanceViewModifier())
    }
    
    private var closeImageColor: Color {
        // Note that default design uses `text` color
        guard colors.navigationBarTintColor != colors.accentPrimary else { return Color(colors.textPrimary) }
        return Color(colors.navigationBarTintColor)
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
