//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Combine
import StreamChat
import SwiftUI

@MainActor class PollOptionAllVotesViewModel: ObservableObject, PollVoteListControllerDelegate {
    
    let poll: Poll
    let option: PollOption
    let controller: PollVoteListController
    
    @Published var pollVotes = [PollVote]()
    @Published var errorShown = false
    
    private var cancellables = Set<AnyCancellable>()
    private(set) var animateChanges = false
    private var loadingVotes = false
        
    init(poll: Poll, option: PollOption) {
        self.poll = poll
        self.option = option
        let query = PollVoteListQuery(
            pollId: poll.id,
            optionId: option.id
        )
        controller = InjectedValues[\.chatClient].pollVoteListController(query: query)
        controller.delegate = self
        refresh()
        
        // No animation for initial load
        $pollVotes
            .dropFirst()
            .map { _ in true }
            .assignWeakly(to: \.animateChanges, on: self)
            .store(in: &cancellables)
    }
    
    func refresh() {
        controller.synchronize { [weak self] error in
            StreamConcurrency.onMain { [weak self] in
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
    }
    
    func onAppear(vote: PollVote) {
        guard !loadingVotes,
              let index = pollVotes.firstIndex(where: { $0 == vote }),
              index > pollVotes.count - 10 else { return }
        
        loadVotes()
    }

    nonisolated func controller(
        _ controller: PollVoteListController,
        didChangeVotes changes: [ListChange<PollVote>]
    ) {
        StreamConcurrency.onMain {
            if animateChanges {
                withAnimation {
                    self.pollVotes = Array(self.controller.votes)
                }
            } else {
                pollVotes = Array(controller.votes)
            }
        }
    }
    
    private func loadVotes() {
        loadingVotes = true

        controller.loadMoreVotes { [weak self] error in
            StreamConcurrency.onMain { [weak self] in
                guard let self else { return }
                self.loadingVotes = false
                if error != nil {
                    self.errorShown = true
                }
            }
        }
    }
}
