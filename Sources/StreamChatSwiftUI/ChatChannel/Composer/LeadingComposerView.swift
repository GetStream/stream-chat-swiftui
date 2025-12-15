//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct LeadingComposerView: View {
    @Injected(\.colors) var colors
    
    var body: some View {
        HStack {
            if #available(iOS 26.0, *) {
                Button {} label: {
                    Image(systemName: "plus")
                        .fontWeight(.semibold)
                }
                .padding(.all, 12)
                .background(
                    Circle()
                        .stroke(Color(colors.innerBorder), lineWidth: 0.5)
                        .shadow(
                            color: .black.opacity(0.2),
                            radius: 12,
                            y: 6
                        )
                )
                .foregroundStyle(.primary)
                .glassEffect(.regular, in: .circle)
            } else {
                Button {} label: {
                    Image(systemName: "plus")
                }
                .padding(.all, 12)
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(.circle)
            }
        }
        .padding(.leading, 8)
    }
}
