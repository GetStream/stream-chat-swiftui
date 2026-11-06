//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct PollOptionAllVotesView<Factory: ViewFactory>: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    @Injected(\.tokens) var tokens

    @StateObject var viewModel: PollOptionAllVotesViewModel
    let factory: Factory
    let translationLanguage: TranslationLanguage?

    init(factory: Factory, poll: Poll, option: PollOption, translationLanguage: TranslationLanguage? = nil) {
        self.factory = factory
        self.translationLanguage = translationLanguage
        _viewModel = StateObject(
            wrappedValue: PollOptionAllVotesViewModel(
                poll: poll,
                option: option
            )
        )
    }

    init(factory: Factory, viewModel: PollOptionAllVotesViewModel, translationLanguage: TranslationLanguage? = nil) {
        self.factory = factory
        self.translationLanguage = translationLanguage
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                PollOptionResultsView(
                    factory: factory,
                    poll: viewModel.poll,
                    option: viewModel.option,
                    translationLanguage: translationLanguage,
                    votes: viewModel.pollVotes,
                    onVoteAppear: viewModel.onAppear(vote:)
                )
            }
            .padding(.horizontal, tokens.spacingMd)
            .padding(.top, tokens.spacingMd)
            .padding(.bottom, tokens.spacing3xl)
        }
        .background(Color(colors.backgroundCoreElevation1).ignoresSafeArea())
        .alertBanner(
            isPresented: $viewModel.errorShown,
            action: viewModel.refresh
        )
        .toolbarThemed {
            ToolbarItem(placement: .principal) {
                Text(viewModel.option.text(in: translationLanguage))
                    .font(fonts.bodyBold)
                    .foregroundColor(Color(colors.navigationBarTitle))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
