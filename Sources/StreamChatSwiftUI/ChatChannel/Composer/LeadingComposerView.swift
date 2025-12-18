//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct LeadingComposerView<Factory: ViewFactory>: View {
    @Injected(\.colors) var colors
    
    var factory: Factory
    
    var body: some View {
        HStack {
            if #available(iOS 26.0, *) {
                Button {} label: {
                    Image(systemName: "plus")
                        .fontWeight(.semibold)
                }
                .padding(.all, 12)
                .modifier(factory.styles.composerButtonViewModifier)
                .foregroundStyle(.primary)
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
