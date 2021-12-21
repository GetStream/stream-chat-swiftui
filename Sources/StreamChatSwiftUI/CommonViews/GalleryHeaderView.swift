//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View used for the gallery header, for images and videos.
struct GalleryHeaderView: View {
    
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    
    var title: String
    var subtitle: String
    
    @Binding var isShown: Bool
    
    var body: some View {
        ZStack {
            HStack {
                Button {
                    isShown = false
                } label: {
                    Image(systemName: "xmark")
                }
                .padding()
                .foregroundColor(Color(colors.text))
                
                Spacer()
            }
            
            VStack {
                Text(title)
                    .font(fonts.bodyBold)
                Text(subtitle)
                    .font(fonts.footnote)
                    .foregroundColor(Color(colors.textLowEmphasis))
            }
        }
    }
}
