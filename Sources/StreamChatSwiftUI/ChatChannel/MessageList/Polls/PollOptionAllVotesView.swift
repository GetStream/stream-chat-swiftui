//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct PollOptionAllVotesView<Factory: ViewFactory>: View {
    @Injected(\.colors) var colors
    @StateObject var viewModel: PollOptionAllVotesViewModel
    let factory: Factory
    
    init(factory: Factory, poll: Poll, option: PollOption) {
        self.factory = factory
        _viewModel = StateObject(
            wrappedValue: PollOptionAllVotesViewModel(
                poll: poll,
                option: option
            )
        )
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                PollOptionResultsView(
                    factory: factory,
                    poll: viewModel.poll,
                    option: viewModel.option,
                    votes: viewModel.pollVotes,
                    onVoteAppear: viewModel.onAppear(vote:)
                )
            }
        }
        .alertBanner(
            isPresented: $viewModel.errorShown,
            action: viewModel.refresh
        )
        .toolbarThemed {
            ToolbarItem(placement: .principal) {
                Text(viewModel.option.text)
                    .bold()
                    .foregroundColor(Color(colors.navigationBarTitle))
            }
        }
    }
}
