//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

class PollOptionAllVotesViewModel: ObservableObject, PollVoteListControllerDelegate {
    
    let poll: Poll
    let option: PollOption
    let controller: PollVoteListController
    
    @Published var pollVotes = [PollVote]()
    @Published var errorShown = false
    
    private var loadingVotes = false
        
    init(poll: Poll, option: PollOption) {
        self.poll = poll
        self.option = option
        let query = PollVoteListQuery(
            pollId: poll.id,
            optionId: option.id, filter: .equal(.optionId, to: option.id)
        )
        controller = InjectedValues[\.chatClient].pollVoteListController(query: query)
        controller.delegate = self
        controller.synchronize { [weak self] error in
            guard let self else { return }
            self.pollVotes = Array(self.controller.votes)
            if self.pollVotes.isEmpty {
                self.loadVotes()
            }
            if error != nil {
                self.errorShown = true
            }
        }
    }
    
    func onAppear(vote: PollVote) {
        guard !loadingVotes,
              let index = pollVotes.firstIndex(where: { $0 == vote }),
              index > pollVotes.count - 10 else { return }
        
        loadVotes()
    }

    func controller(
        _ controller: PollVoteListController,
        didChangeVotes changes: [ListChange<PollVote>]
    ) {
        withAnimation {
            self.pollVotes = Array(self.controller.votes)
        }
    }
    
    private func loadVotes() {
        loadingVotes = true

        controller.loadMoreVotes { [weak self] error in
            guard let self else { return }
            self.loadingVotes = false
            if error != nil {
                self.errorShown = true
            }
        }
    }
}
