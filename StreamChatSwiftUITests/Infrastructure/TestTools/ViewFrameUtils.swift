//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import SwiftUI

extension View {

    func applyDefaultSize() -> some View {
        frame(
            width: defaultScreenSize.width,
            height: defaultScreenSize.height
        )
    }
}
