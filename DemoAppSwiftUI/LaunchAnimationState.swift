//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI

class LaunchAnimationState: ObservableObject {

    @Published var showAnimation = true

    init() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.showAnimation = false
        }
    }
}
