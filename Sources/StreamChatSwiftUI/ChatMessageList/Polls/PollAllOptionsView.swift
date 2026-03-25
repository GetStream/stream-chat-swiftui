//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct PollAllOptionsView<Factory: ViewFactory>: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    @Injected(\.tokens) var tokens

    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var viewModel: PollAttachmentViewModel

    let factory: Factory

    var body: some View {
        NavigationContainerView(embedInNavigationView: true) {
            content
        }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: tokens.spacing2xl) {
                questionSection
                optionsSection
                totalVotesFooter
            }
            .padding(.horizontal, tokens.spacingMd)
            .padding(.top, tokens.spacingMd)
            .padding(.bottom, tokens.spacing3xl)
        }
        .background(Color(colors.backgroundElevation1).ignoresSafeArea())
        .toolbarThemed {
            ToolbarItem(placement: .principal) {
                Text(L10n.Message.Polls.Toolbar.optionsTitle)
                    .font(fonts.bodyBold)
                    .foregroundColor(Color(colors.navigationBarTitle))
            }

            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var questionSection: some View {
        VStack(alignment: .leading, spacing: tokens.spacingXxs) {
            Text(L10n.Message.Polls.question)
                .font(fonts.subheadline)
                .foregroundColor(Color(colors.textTertiary))
            Text(viewModel.poll.name)
                .font(fonts.title3.weight(.semibold))
                .foregroundColor(Color(colors.textPrimary))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(tokens.spacingMd)
        .background(Color(colors.backgroundCoreSurfaceCard))
        .cornerRadius(tokens.radiusLg)
    }

    private var optionsSection: some View {
        VStack(spacing: tokens.spacingMd) {
            ForEach(viewModel.poll.options) { option in
                PollOptionView(
                    viewModel: viewModel,
                    factory: factory,
                    option: option,
                    optionVotes: viewModel.poll.voteCount(for: option),
                    maxVotes: viewModel.poll.currentMaximumVoteCount,
                    message: viewModel.message
                )
            }
        }
        .padding(tokens.spacingMd)
        .background(Color(colors.backgroundCoreSurfaceCard))
        .cornerRadius(tokens.radiusLg)
    }

    private var totalVotesFooter: some View {
        Text(L10n.Message.Polls.votesTotal(viewModel.poll.voteCount))
            .font(fonts.body)
            .foregroundColor(Color(colors.textPrimary))
            .frame(maxWidth: .infinity, alignment: .center)
    }
}
