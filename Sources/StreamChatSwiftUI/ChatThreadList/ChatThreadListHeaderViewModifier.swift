//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct ChatThreadListHeaderViewModifier: ViewModifier {
    @Injected(\.fonts) private var fonts

    let title: String

    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(fonts.bodyBold)
                }
            }
    }
}
