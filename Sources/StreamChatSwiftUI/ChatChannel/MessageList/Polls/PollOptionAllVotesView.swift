//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct PollOptionAllVotesView: View {

    @StateObject var viewModel: PollOptionAllVotesViewModel
    
    init(poll: Poll, option: PollOption) {
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
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(viewModel.option.text)
                    .bold()
            }
        }
    }
}
