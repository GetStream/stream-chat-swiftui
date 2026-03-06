//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct CreatePollView: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    @StateObject private var viewModel: CreatePollViewModel
    @Environment(\.presentationMode) private var presentationMode

    @State private var listId = UUID()

    public init(chatController: ChatChannelController, messageController: ChatMessageController?) {
        _viewModel = StateObject(
            wrappedValue: CreatePollViewModel(
                chatController: chatController,
                messageController: messageController
            )
        )
    }

    public var body: some View {
        NavigationContainerView(embedInNavigationView: true) {
            List {
                questionSection
                optionsSection
                settingsSpacer
                settingsSection
                Spacer()
                    .modifier(CreatePollRowModifier(topSpacing: 0, bottomSpacing: 0))
            }
            .environment(\.defaultMinListRowHeight, 1)
            .background(Color(colors.background).ignoresSafeArea())
            .listStyle(.plain)
            .id(listId)
            .toolbarThemed { toolbarContent }
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $viewModel.errorShown) {
                Alert.defaultErrorAlert
            }
        }
    }

    // MARK: - Sections

    private var questionSection: some View {
        VStack(alignment: .leading, spacing: tokens.spacingXs) {
            Text(L10n.Composer.Polls.question)
                .font(fonts.body)
                .foregroundColor(Color(colors.textPrimary))
            TextField(L10n.Composer.Polls.askQuestion, text: $viewModel.question)
                .font(fonts.body)
                .foregroundColor(Color(colors.inputTextDefault))
                .padding(.horizontal, tokens.spacingMd)
                .padding(.vertical, tokens.spacingSm)
                .frame(minHeight: 48)
                .background(
                    RoundedRectangle(cornerRadius: tokens.radiusLg)
                        .strokeBorder(Color(colors.borderCoreDefault), lineWidth: 1)
                )
        }
        .modifier(CreatePollRowModifier(
            topSpacing: tokens.spacingXxs,
            bottomSpacing: tokens.spacingSm
        ))
    }

    @ViewBuilder
    private var optionsSection: some View {
        Text(L10n.Composer.Polls.options)
            .font(fonts.body)
            .foregroundColor(Color(colors.textPrimary))
            .modifier(CreatePollRowModifier(
                topSpacing: tokens.spacingSm,
                bottomSpacing: tokens.spacingXxs
            ))

        ForEach(viewModel.options.indices, id: \.self) { index in
            CreatePollOptionRow(
                text: viewModel.options[index],
                showsReorderIcon: !viewModel.options[index].isEmpty,
                showsDeleteButton: index < viewModel.options.count - 1,
                showsError: viewModel.showsOptionError(for: index),
                onTextChanged: { newValue in
                    Task { @MainActor in
                        viewModel.updateOption(at: index, value: newValue)
                    }
                },
                onDelete: {
                    Task { @MainActor in
                        viewModel.removeOption(at: index)
                    }
                }
            )
        }
        .onMove { from, to in
            Task { @MainActor in
                viewModel.moveOptions(from: from, to: to)
                listId = UUID()
            }
        }
        .modifier(CreatePollRowModifier(
            topSpacing: tokens.spacingXxs,
            bottomSpacing: tokens.spacingXxs
        ))
    }

    private var settingsSpacer: some View {
        Color.clear
            .frame(height: tokens.spacingLg)
            .modifier(CreatePollRowModifier(topSpacing: 0, bottomSpacing: 0))
    }

    @ViewBuilder
    private var settingsSection: some View {
        if viewModel.multipleAnswersShown {
            multipleVotesCard
        }

        if viewModel.anonymousPollShown {
            CreatePollSettingCard(
                title: L10n.Composer.Polls.anonymousPoll,
                subtitle: L10n.Composer.Polls.hideWhoVoted
            ) {
                Toggle("", isOn: $viewModel.anonymousPoll).labelsHidden()
            }
        }

        if viewModel.suggestAnOptionShown {
            CreatePollSettingCard(
                title: L10n.Composer.Polls.suggestOption,
                subtitle: L10n.Composer.Polls.letOthersAddOptions
            ) {
                Toggle("", isOn: $viewModel.suggestAnOption).labelsHidden()
            }
        }

        if viewModel.addCommentsShown {
            CreatePollSettingCard(
                title: L10n.Composer.Polls.addComment,
                subtitle: L10n.Composer.Polls.allowOthersToAddComments
            ) {
                Toggle("", isOn: $viewModel.allowComments).labelsHidden()
            }
        }
    }

    // MARK: - Multiple Votes Card

    private var multipleVotesCard: some View {
        VStack(alignment: .leading, spacing: tokens.spacingMd) {
            HStack(spacing: tokens.spacingMd) {
                VStack(alignment: .leading, spacing: tokens.spacingXxs) {
                    Text(L10n.Composer.Polls.multipleAnswers)
                        .font(fonts.body)
                        .foregroundColor(Color(colors.textPrimary))
                    Text(L10n.Composer.Polls.selectMoreThanOneOption)
                        .font(fonts.subheadline)
                        .foregroundColor(Color(colors.textTertiary))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Toggle("", isOn: $viewModel.multipleAnswers)
                    .labelsHidden()
            }

            if viewModel.multipleAnswers, viewModel.maxVotesShown {
                VStack(alignment: .leading, spacing: tokens.spacingXs) {
                    HStack(spacing: tokens.spacingSm) {
                        VStack(alignment: .leading, spacing: tokens.spacingXxs) {
                            Text(L10n.Composer.Polls.maximumVotesPerPerson)
                                .font(fonts.body)
                                .foregroundColor(Color(colors.textPrimary))
                            Text(L10n.Composer.Polls.typeNumberMinMaxRange)
                                .font(fonts.subheadline)
                                .foregroundColor(Color(colors.textTertiary))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Toggle("", isOn: $viewModel.maxVotesEnabled)
                            .labelsHidden()
                    }
                    .padding(.vertical, tokens.spacingXxxs)

                    if viewModel.maxVotesEnabled {
                        CreatePollMaxVotesStepper(
                            text: viewModel.maxVotesText,
                            canDecrement: viewModel.canDecrementMaxVotes,
                            canIncrement: viewModel.canIncrementMaxVotes,
                            onDecrement: viewModel.decrementMaxVotes,
                            onIncrement: viewModel.incrementMaxVotes
                        )
                    }
                }
            }
        }
        .padding(tokens.spacingMd)
        .background(Color(colors.backgroundCoreSurfaceCard))
        .clipShape(RoundedRectangle(cornerRadius: tokens.radiusLg))
        .modifier(CreatePollRowModifier(
            topSpacing: tokens.spacingXs,
            bottomSpacing: tokens.spacingXs
        ))
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                if viewModel.canShowDiscardConfirmation {
                    viewModel.discardConfirmationShown = true
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            } label: {
                Image(uiImage: images.close)
            }
            .actionSheet(isPresented: $viewModel.discardConfirmationShown) {
                ActionSheet(
                    title: Text(L10n.Composer.Polls.actionSheetDiscardTitle),
                    buttons: [
                        .destructive(Text(L10n.Alert.Actions.discardChanges)) {
                            presentationMode.wrappedValue.dismiss()
                        },
                        .default(Text(L10n.Alert.Actions.keepEditing))
                    ]
                )
            }
        }

        ToolbarItem(placement: .principal) {
            Text(L10n.Composer.Polls.createPoll)
                .bold()
                .foregroundColor(Color(colors.navigationBarTitle))
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.createPoll {
                    presentationMode.wrappedValue.dismiss()
                }
            } label: {
                Image(systemName: "checkmark")
                    .font(.system(size: tokens.iconSizeSm, weight: .semibold))
                    .foregroundColor(Color(colors.buttonPrimaryTextOnAccent))
            }
            .frame(width: tokens.buttonVisualHeightSm, height: tokens.buttonVisualHeightSm)
            .background(Circle().fill(Color(colors.buttonPrimaryBackground)))
            .clipShape(Circle())
            .disabled(!viewModel.canCreatePoll)
        }
    }
}

// MARK: - Option Row

private struct CreatePollOptionRow: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    let text: String
    let showsReorderIcon: Bool
    let showsDeleteButton: Bool
    let showsError: Bool
    let onTextChanged: @Sendable (String) -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: tokens.spacingXs) {
                if showsReorderIcon {
                    Image(uiImage: images.pollReorderIcon)
                        .font(.system(size: tokens.iconSizeSm))
                        .foregroundColor(Color(colors.textTertiary))
                }
                TextField(
                    L10n.Composer.Polls.addOption,
                    text: Binding(get: { text }, set: onTextChanged)
                )
                .font(fonts.body)
                .foregroundColor(Color(colors.inputTextDefault))
                if showsDeleteButton {
                    Button(action: onDelete) {
                        Image(systemName: "minus.circle")
                            .font(.system(size: tokens.iconSizeSm))
                            .foregroundColor(Color(colors.textTertiary))
                    }
                    .frame(width: tokens.iconSizeSm, height: tokens.iconSizeSm)
                }
            }
            .padding(.horizontal, tokens.spacingMd)
            .padding(.vertical, tokens.spacingSm)
            .frame(minHeight: 48)

            duplicateErrorLabel
        }
        .background(
            RoundedRectangle(cornerRadius: tokens.radiusLg)
                .strokeBorder(Color(colors.borderCoreDefault), lineWidth: 1)
        )
        .moveDisabled(!showsDeleteButton)
    }

    private var duplicateErrorLabel: some View {
        HStack(spacing: tokens.spacingXs) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: tokens.iconSizeSm))
            Text(L10n.Composer.Polls.duplicateOption)
                .font(fonts.subheadline)
        }
        .foregroundColor(Color(colors.alert))
        .padding(.horizontal, tokens.spacingMd)
        .padding(.bottom, showsError ? tokens.spacingSm : 0)
        .frame(height: showsError ? nil : 0, alignment: .top)
        .clipped()
        .opacity(showsError ? 1 : 0)
    }
}

// MARK: - Setting Card

private struct CreatePollSettingCard<Content: View>: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    let title: String
    let subtitle: String
    @ViewBuilder let content: Content

    var body: some View {
        HStack(alignment: .top, spacing: tokens.spacingMd) {
            VStack(alignment: .leading, spacing: tokens.spacingXxs) {
                Text(title)
                    .font(fonts.body)
                    .foregroundColor(Color(colors.textPrimary))
                Text(subtitle)
                    .font(fonts.caption1)
                    .foregroundColor(Color(colors.textTertiary))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            content
        }
        .padding(tokens.spacingMd)
        .background(Color(colors.backgroundCoreSurfaceCard))
        .clipShape(RoundedRectangle(cornerRadius: tokens.radiusLg))
        .modifier(CreatePollRowModifier(
            topSpacing: tokens.spacingXs,
            bottomSpacing: tokens.spacingXs
        ))
    }
}

// MARK: - Max Votes Stepper

private struct CreatePollMaxVotesStepper: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    let text: String
    let canDecrement: Bool
    let canIncrement: Bool
    let onDecrement: () -> Void
    let onIncrement: () -> Void

    var body: some View {
        HStack(spacing: tokens.spacingXxs) {
            stepperButton(systemName: "minus", enabled: canDecrement, action: onDecrement)

            Text(text)
                .font(fonts.body)
                .foregroundColor(Color(colors.textPrimary))
                .frame(width: tokens.buttonVisualHeightMd, height: tokens.buttonVisualHeightLg)

            stepperButton(systemName: "plus", enabled: canIncrement, action: onIncrement)
        }
    }

    private func stepperButton(
        systemName: String,
        enabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            guard enabled else { return }
            action()
        } label: {
            Image(systemName: systemName)
                .font(.system(size: tokens.iconSizeSm))
                .foregroundColor(Color(enabled ? colors.textPrimary : colors.textTertiary))
                .frame(width: tokens.buttonVisualHeightMd, height: tokens.buttonVisualHeightMd)
                .background(
                    Circle()
                        .strokeBorder(
                            Color(enabled ? colors.buttonSecondaryBorder : colors.borderUtilityDisabled),
                            lineWidth: 1
                        )
                )
                .contentShape(Circle())
        }
        .buttonStyle(.borderless)
        .frame(width: tokens.buttonVisualHeightLg, height: tokens.buttonVisualHeightLg)
    }
}

// MARK: - Row Modifier

private struct CreatePollRowModifier: ViewModifier {
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    var topSpacing: CGFloat
    var bottomSpacing: CGFloat

    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .listRowSeparator(.hidden)
                .listRowBackground(Color(colors.background))
                .listRowInsets(EdgeInsets(
                    top: topSpacing,
                    leading: tokens.spacingMd,
                    bottom: bottomSpacing,
                    trailing: tokens.spacingMd
                ))
        } else {
            content
                .padding(.horizontal, tokens.spacingMd)
                .padding(.top, topSpacing)
                .padding(.bottom, bottomSpacing)
        }
    }
}

struct ListRowModifier: ViewModifier {
    @Injected(\.colors) private var colors

    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .listRowSeparator(.hidden)
                .listRowBackground(Color(colors.background))
        } else {
            content
        }
    }
}

struct ComposerPollView: View {
    @State private var showsOnAppear = true
    @State private var showsCreatePoll = false

    let channelController: ChatChannelController
    let messageController: ChatMessageController?

    var body: some View {
        VStack {
            Spacer()
            Button {
                showsCreatePoll = true
            } label: {
                Text(L10n.Composer.Polls.createPoll)
            }
            Spacer()
        }
        .fullScreenCover(isPresented: $showsCreatePoll) {
            CreatePollView(chatController: channelController, messageController: messageController)
        }
        .onAppear {
            guard showsOnAppear else { return }
            showsOnAppear = false
            showsCreatePoll = true
        }
    }
}
