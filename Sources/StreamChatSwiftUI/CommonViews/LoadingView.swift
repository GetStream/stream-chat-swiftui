//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Default loading view.
public struct LoadingView: View {
    public var body: some View {
        VStack {
            Spacer()
            ProgressView()
            Spacer()
        }
    }
}
