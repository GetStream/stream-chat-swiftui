//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// The default header view of the thread list.
///
/// By default it shows a loading spinner if it is loading the initial threads,
/// or shows a banner notifying that there are new threads to be fetched.
public struct ChatThreadListHeaderView: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images

    @ObservedObject private var viewModel: ChatThreadListViewModel

    public init(
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
