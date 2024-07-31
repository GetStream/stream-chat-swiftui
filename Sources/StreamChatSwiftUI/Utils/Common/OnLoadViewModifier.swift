//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Foundation
import SwiftUI

private struct OnLoadViewModifier: ViewModifier {
    @State private var hasLoaded = false
    
    let action: (() -> Void)
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                guard !hasLoaded else { return }
                action()
                hasLoaded = true
            }
    }
}

extension View {
    func onLoad(perform action: @escaping () -> Void) -> some View {
        modifier(OnLoadViewModifier(action: action))
    }
}
