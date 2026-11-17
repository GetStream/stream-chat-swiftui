//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

extension Compatibility where Content: View {
    func presentationDetents(_ sheetSizes: [SheetSize]) -> some View {
        content.modifier(PresentationDetentsModifier(sheetSizes: sheetSizes))
    }

    @ViewBuilder
    func presentationDragIndicatorVisible() -> some View {
        if #available(iOS 16.0, *) {
            content.presentationDragIndicator(.visible)
        } else {
            content
        }
    }
}
