//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Default wrapping view for the channel more actions full screen presented view.
struct MoreChannelActionsFullScreenWrappingView: View {
    @Injected(\.images) private var images

    let presentedView: AnyView
    let onDismiss: () -> Void

    public var body: some View {
        NavigationView {
            presentedView
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            onDismiss()
                        } label: {
                            Image(uiImage: images.close)
                                .customizable()
                                .frame(height: 16)
                        }
                    }
                }
        }
    }
}
