//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SwiftUI

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
