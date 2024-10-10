//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI

public struct ChatThreadListFooterView: View {
    @ObservedObject private var viewModel: ChatThreadListViewModel

    init(
        viewModel: ChatThreadListViewModel
    ) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Group {
            if viewModel.isLoadingMoreThreads {
                LoadingView()
                    .frame(height: 40)
            } else {
                EmptyView()
            }
        }
    }
}
