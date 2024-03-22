//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Foundation

func runOnMainActor(_ action: @escaping @MainActor () -> Void) {
    Task {
        await MainActor.run {
            action()
        }
    }
}
