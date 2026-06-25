//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct PollResultsView<Factory: ViewFactory>: View {
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var viewModel: PollAttachmentViewModel

    let factory: Factory

    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    @Injected(\.tokens) var tokens

    private let numberOfItemsShown = 5

    var body: some View {
        NavigationContainerView(embedInNavigationView: true) {
            content
        }
    }

    var content: some View {
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
        .background(Color(colors.backgroundCoreElevation1).ignoresSafeArea())
        .toolbarThemed {
            ToolbarItem(placement: .principal) {
                Text(L10n.Message.Polls.Toolbar.resultsTitle)
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(PollAccessibility.questionLabel(question: L10n.Message.Polls.question, name: viewModel.poll.name))
    }

    private var optionsSection: some View {
        VStack(spacing: tokens.spacingMd) {
            ForEach(Array(viewModel.poll.options.enumerated()), id: \.element.id) { index, option in
                PollOptionResultsView(
                    factory: factory,
                    poll: viewModel.poll,
                    option: option,
                    optionIndex: index + 1,
                    votes: Array(
                        option.latestVotes
                            .prefix(numberOfItemsShown)
                    ),
                    hasMostVotes: viewModel.hasMostVotes(for: option),
                    allButtonShown: option.latestVotes.count > numberOfItemsShown
                )
            }
        }
    }

    private var totalVotesFooter: some View {
        Text(L10n.Message.Polls.votesTotal(viewModel.poll.voteCount))
            .font(fonts.body)
            .foregroundColor(Color(colors.textPrimary))
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

struct PollOptionResultsView<Factory: ViewFactory>: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    @Injected(\.tokens) var tokens
    @Injected(\.utils) var utils

    let factory: Factory
    var poll: Poll
    var option: PollOption
    var optionIndex: Int?
    var votes: [PollVote]
    var hasMostVotes: Bool = false
    var allButtonShown = false
    var onVoteAppear: ((PollVote) -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            optionHeading
            if !votes.isEmpty {
                votersList
            }
            if allButtonShown {
                viewAllButton
            }
        }
        .background(Color(colors.backgroundCoreSurfaceCard))
        .cornerRadius(tokens.radiusLg)
    }

    // MARK: - Heading

    private var optionHeading: some View {
        VStack(alignment: .leading, spacing: tokens.spacingXxs) {
            if let optionIndex {
                Text(L10n.Message.Polls.option(optionIndex))
                    .font(fonts.subheadline)
                    .foregroundColor(Color(colors.textTertiary))
            }
            HStack(spacing: tokens.spacingMd) {
                Text(option.text)
                    .font(fonts.title3.weight(.semibold))
                    .foregroundColor(Color(colors.textPrimary))
                Spacer()
                votesLabel
            }
        }
        .padding(.horizontal, tokens.spacingMd)
        .padding(.top, tokens.spacingMd)
        .padding(.bottom, votes.isEmpty && !allButtonShown ? tokens.spacingMd : 0)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(optionHeadingAccessibilityLabel)
    }

    private var optionHeadingAccessibilityLabel: String {
        PollAccessibility.resultsOptionHeadingLabel(
            optionIndex: optionIndex,
            optionText: option.text,
            hasMostVotes: hasMostVotes,
            voteCount: poll.voteCountsByOption?[option.id] ?? 0
        )
    }

    private var votesLabel: some View {
        HStack(spacing: tokens.spacingXs) {
            if hasMostVotes {
                Image(systemName: "trophy")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: tokens.iconSizeMd, height: tokens.iconSizeMd)
                    .accessibilityHidden(true)
            }
            Text(voteCountText)
                .font(fonts.body)
                .foregroundColor(Color(colors.textPrimary))
        }
    }

    private var voteCountText: String {
        let count = poll.voteCountsByOption?[option.id] ?? 0
        return count == 1
            ? L10n.Message.Polls.voteSingular(count)
            : L10n.Message.Polls.votes(count)
    }

    // MARK: - Voters List

    private var votersList: some View {
        VStack(spacing: 0) {
            ForEach(votes, id: \.displayId) { vote in
                voterRow(for: vote)
                    .onAppear {
                        onVoteAppear?(vote)
                    }
            }
        }
        .padding(.vertical, tokens.spacingXs)
    }

    private func voterRow(for vote: PollVote) -> some View {
        HStack(spacing: tokens.spacingSm) {
            if poll.votingVisibility != .anonymous, let user = vote.user {
                factory.makeUserAvatarView(
                    options: UserAvatarViewOptions(
                        user: user,
                        size: AvatarSize.medium,
                        showsIndicator: false
                    )
                )
                .accessibilityHidden(true)
            }
            Text(vote.user?.name ?? (vote.user?.id ?? L10n.Message.Polls.unknownVoteAuthor))
                .font(fonts.body)
                .foregroundColor(Color(colors.textPrimary))
                .lineLimit(1)
            Spacer()
            Text(utils.pollsDateFormatter.formatDay(vote.createdAt))
                .font(fonts.body)
                .foregroundColor(Color(colors.textTertiary))
                .frame(width: 120, alignment: .trailing)
        }
        .padding(.horizontal, tokens.spacingMd)
        .padding(.vertical, tokens.spacingXs)
        .frame(minHeight: 40)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(voterRowAccessibilityLabel(for: vote))
    }

    private func voterRowAccessibilityLabel(for vote: PollVote) -> String {
        let name = vote.user?.name ?? (vote.user?.id ?? L10n.Message.Polls.unknownVoteAuthor)
        let date = utils.pollsDateFormatter.formatDay(vote.createdAt)
        return PollAccessibility.voterLabel(name: name, date: date)
    }

    // MARK: - View All Button

    private var viewAllButton: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color(colors.borderCoreDefault))
            NavigationLink {
                PollOptionAllVotesView(factory: factory, poll: poll, option: option)
            } label: {
                Text(L10n.Message.Polls.Button.showAll)
                    .font(fonts.body)
                    .foregroundColor(Color(colors.buttonSecondaryText))
                    .frame(maxWidth: .infinity)
                    .frame(height: tokens.buttonHitTargetMinHeight)
            }
        }
        .padding(.horizontal, tokens.spacingMd)
    }
}

extension PollVote {
    var displayId: String {
        "\(id)-\(optionId ?? user?.id ?? "")-\(pollId)"
    }
}
