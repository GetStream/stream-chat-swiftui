//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// View for the discard button.
struct DiscardButtonView: View {
    
    var color = Color.black.opacity(0.8)
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 16, height: 16)
            
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(color)
        }
        .padding(.all, 4)
    }
}
