//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct ChatThreadListHeaderViewModifier: ViewModifier {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    let title: String

    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .tintedToolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(fonts.bodyBold)
                        .foregroundColor(Color(colors.navigationTitle))
                }
            }
    }
}
