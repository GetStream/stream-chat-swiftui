//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Default wrapping view for the channel more actions full screen presented view.
struct MoreChannelActionsFullScreenWrappingView: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images

    let presentedView: AnyView
    let onDismiss: () -> Void

    public var body: some View {
        NavigationContainerView(embedInNavigationView: true) {
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
                        .accentColor(colors.navigationTintColor)
                    }
                }
        }
    }
}
