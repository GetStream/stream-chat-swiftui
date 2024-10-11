//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI

public struct ChatThreadListHeaderView: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images

    @ObservedObject private var viewModel: ChatThreadListViewModel

    init(
        viewModel: ChatThreadListViewModel
    ) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Group {
            if viewModel.isReloading {
                LoadingView()
                    .frame(height: 40)
            } else if viewModel.hasNewThreads {
                ActionBannerView(
                    text: L10n.Thread.newThreads(viewModel.newThreadsCount),
                    image: images.restart
                ) {
                    viewModel.loadThreads()
                }
            } else {
                EmptyView()
            }
        }
    }
}
