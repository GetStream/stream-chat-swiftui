//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct ChatThreadListHeaderViewModifier: ViewModifier {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    let title: String

    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbarThemed {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(fonts.bodyBold)
                        .foregroundColor(Color(colors.navigationBarTitle))
                }
            }
    }
}
