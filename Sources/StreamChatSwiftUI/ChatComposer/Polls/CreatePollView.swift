//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct CreatePollView<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    @StateObject private var viewModel: CreatePollViewModel
    @Environment(\.presentationMode) private var presentationMode

    let factory: Factory

    public init(
        factory: Factory = DefaultViewFactory.shared,
        chatController: ChatChannelController,
        messageController: ChatMessageController?
    ) {
        self.factory = factory
        _viewModel = StateObject(
            wrappedValue: CreatePollViewModel(
                chatController: chatController,
                messageController: messageController
            )
        )
    }

    init(factory: Factory = DefaultViewFactory.shared, viewModel: CreatePollViewModel) {
        self.factory = factory
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List {
                    if #available(iOS 15.0, *) {
                        CreatePollFocusableFields(viewModel: viewModel)
                    } else {
                        questionSection
                        optionsSection
                    }
                    settingsSpacer
                    settingsSection
                    Spacer()
                        .modifier(CreatePollRowModifier(topSpacing: 0, bottomSpacing: 0))
                        .accessibilityHidden(true)
                }
                .environment(\.defaultMinListRowHeight, 1)
                .listStyle(.plain)
                .modifier(CreatePollScrollDismissesKeyboardModifier())
            }
            .background(Color(colors.backgroundCoreElevation1).ignoresSafeArea())
            .modifier(
                CreatePollToolbarModifier(
                    factory: factory,
                    canCreatePoll: viewModel.canCreatePoll,
                    onClose: {
                        if viewModel.canShowDiscardConfirmation {
                            viewModel.discardConfirmationShown = true
                        } else {
                            presentationMode.wrappedValue.dismiss()
                        }
                    },
                    onConfirm: {
                        viewModel.createPoll {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                )
            )
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: postScreenChangedAnnouncement)
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
        .alert(isPresented: $viewModel.errorShown) {
            Alert.defaultErrorAlert
        }
    }

    // MARK: - Sections

    private var questionSection: some View {
        CreatePollQuestionContainer {
            TextField(L10n.Composer.Polls.askQuestion, text: $viewModel.question)
        }
    }

    @ViewBuilder
    private var optionsSection: some View {
        CreatePollOptionsLabelRow()

        let reorderableCount = viewModel.reorderableOptionCount
        ForEach(Array(viewModel.options.enumerated()), id: \.element.id) { index, option in
            let isLast = viewModel.isLastOption(option)
            CreatePollOptionRow(
                position: option.text.isEmpty ? nil : index + 1,
                totalCount: reorderableCount,
                showsReorderIcon: !option.text.isEmpty,
                showsDeleteButton: !isLast,
                showsError: viewModel.showsOptionError(for: option),
                onDelete: {
                    let id = option.id
                    Task { @MainActor in
                        viewModel.removeOption(id: id)
                    }
                },
                onAccessibilityMove: { direction in
                    let id = option.id
                    return viewModel.moveOption(id: id, direction: direction)
                },
                field: {
                    TextField(
                        L10n.Composer.Polls.addOption,
                        text: Binding(
                            get: { option.text },
                            set: { newText in
                                let id = option.id
                                Task { @MainActor in
                                    viewModel.updateOption(id: id, value: newText)
                                }
                            }
                        )
                    )
                }
            )
        }
        .onMove { indices, newOffset in
            Task { @MainActor in
                viewModel.moveOptions(from: indices, to: newOffset)
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
            .accessibilityHidden(true)
    }

    /// Posts a VoiceOver screen change announcement naming the sheet so users
    /// orient themselves on open instead of landing on the bare "Close" button.
    private func postScreenChangedAnnouncement() {
        ComposerAccessibilityAnnouncer.announce(
            L10n.Composer.Polls.createPoll,
            kind: .screenChanged
        )
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
            .accessibilityElement(children: .combine)

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
                    .accessibilityElement(children: .combine)

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
}

// MARK: - Toolbar

private struct CreatePollToolbarModifier<Factory: ViewFactory>: ViewModifier {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    let factory: Factory
    let canCreatePoll: Bool
    let onClose: () -> Void
    let onConfirm: () -> Void

    func body(content: Content) -> some View {
        content
            .toolbarThemed {
                toolbarContent()
            }
    }

    @ToolbarContentBuilder private func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .renderingMode(.template)
                    .font(.system(size: 12))
                    .foregroundColor(Color(colors.buttonSecondaryText))
            }
        }

        ToolbarItem(placement: .principal) {
            Text(L10n.Composer.Polls.createPoll)
                .font(fonts.bodyBold)
                .foregroundColor(Color(colors.navigationBarTitle))
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button(action: onConfirm) {
                Image(systemName: "checkmark")
                    .renderingMode(.template)
                    .font(.system(size: 16))
                    .foregroundColor(Color(colors.buttonPrimaryTextOnAccent))
            }
            .modifier(factory.styles.makeToolbarConfirmActionModifier(options: .init()))
            .disabled(!canCreatePoll)
            .accessibilityLabel(Text(L10n.Composer.Polls.Accessibility.saveButton))
            .accessibilityRemoveTraits(.isSelected)
        }
    }
}

// MARK: - Question Container

/// Renders the "Question" label plus a styled rounded container around an
/// arbitrary text field. The field is injected so callers can attach the
/// SwiftUI Focus API (iOS 15+) without duplicating the container chrome.
private struct CreatePollQuestionContainer<Field: View>: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    @ViewBuilder var field: () -> Field

    var body: some View {
        VStack(alignment: .leading, spacing: tokens.spacingXs) {
            Text(L10n.Composer.Polls.question)
                .font(fonts.body)
                .foregroundColor(Color(colors.textPrimary))
            field()
                .font(fonts.body)
                .foregroundColor(Color(colors.inputTextDefault))
                .multilineTextAlignment(.leading)
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
}

// MARK: - Options Label Row

private struct CreatePollOptionsLabelRow: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    var body: some View {
        Text(L10n.Composer.Polls.options)
            .font(fonts.body)
            .foregroundColor(Color(colors.textPrimary))
            .modifier(CreatePollRowModifier(
                topSpacing: tokens.spacingSm,
                bottomSpacing: tokens.spacingXxs
            ))
    }
}

// MARK: - Option Row

private struct CreatePollOptionRow<Field: View>: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    let position: Int?
    let totalCount: Int
    let showsReorderIcon: Bool
    let showsDeleteButton: Bool
    let showsError: Bool
    let onDelete: () -> Void
    let onAccessibilityMove: (AccessibilityAdjustmentDirection) -> Bool
    @ViewBuilder var field: () -> Field

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: tokens.spacingXs) {
                if showsReorderIcon {
                    reorderHandle
                }
                field()
                    .font(fonts.body)
                    .foregroundColor(Color(colors.inputTextDefault))
                    .multilineTextAlignment(.leading)
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

    private var reorderHandle: some View {
        Image(uiImage: images.pollOptionDragIcon)
            .renderingMode(.template)
            .font(.system(size: tokens.iconSizeSm))
            .foregroundColor(Color(colors.textTertiary))
            .accessibilityElement()
            .accessibilityLabel(Text(L10n.Composer.Polls.Accessibility.reorderOption))
            .accessibilityValue(Text(reorderAccessibilityValue))
            .accessibilityAdjustableAction { direction in
                _ = onAccessibilityMove(direction)
            }
    }

    private var reorderAccessibilityValue: String {
        guard let position else { return "" }
        return L10n.Composer.Polls.Accessibility.reorderOptionPosition(position, totalCount)
    }

    private var duplicateErrorLabel: some View {
        HStack(spacing: tokens.spacingXs) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: tokens.iconSizeSm))
            Text(L10n.Composer.Polls.duplicateOption)
                .font(fonts.subheadline)
        }
        .foregroundColor(Color(colors.accentError))
        .padding(.horizontal, tokens.spacingMd)
        .padding(.bottom, showsError ? tokens.spacingSm : 0)
        .frame(height: showsError ? nil : 0, alignment: .top)
        .clipped()
        .opacity(showsError ? 1 : 0)
    }
}

// MARK: - Focusable Fields (iOS 15+)

/// Routes the keyboard's "next" return-key action between the question and
/// option text fields using SwiftUI's Focus API. Lives in a separate view so
/// `@FocusState` (iOS 15+) can be declared without lowering the public view's
/// availability.
@available(iOS 15.0, *)
private struct CreatePollFocusableFields: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    @ObservedObject var viewModel: CreatePollViewModel
    @FocusState private var focusedField: CreatePollFocusField?

    var body: some View {
        Group {
            questionRow
            CreatePollOptionsLabelRow()
            optionRows
        }
    }

    private var questionRow: some View {
        CreatePollQuestionContainer {
            TextField(L10n.Composer.Polls.askQuestion, text: $viewModel.question)
                .focused($focusedField, equals: .question)
                .submitLabel(.next)
                .onSubmit(focusFirstOption)
        }
    }

    @ViewBuilder
    private var optionRows: some View {
        let reorderableCount = viewModel.reorderableOptionCount
        ForEach(Array(viewModel.options.enumerated()), id: \.element.id) { index, option in
            let isLast = viewModel.isLastOption(option)
            CreatePollOptionRow(
                position: option.text.isEmpty ? nil : index + 1,
                totalCount: reorderableCount,
                showsReorderIcon: !option.text.isEmpty,
                showsDeleteButton: !isLast,
                showsError: viewModel.showsOptionError(for: option),
                onDelete: {
                    let id = option.id
                    Task { @MainActor in
                        viewModel.removeOption(id: id)
                    }
                },
                onAccessibilityMove: { direction in
                    let id = option.id
                    return viewModel.moveOption(id: id, direction: direction)
                },
                field: {
                    let optionID = option.id
                    TextField(
                        L10n.Composer.Polls.addOption,
                        text: Binding(
                            get: { option.text },
                            set: { newText in
                                Task { @MainActor in
                                    viewModel.updateOption(id: optionID, value: newText)
                                }
                            }
                        )
                    )
                    .focused($focusedField, equals: .option(optionID))
                    .submitLabel(.next)
                    .onSubmit { advanceFocus(after: optionID) }
                }
            )
        }
        .onMove { indices, newOffset in
            Task { @MainActor in
                viewModel.moveOptions(from: indices, to: newOffset)
            }
        }
        .modifier(CreatePollRowModifier(
            topSpacing: tokens.spacingXxs,
            bottomSpacing: tokens.spacingXxs
        ))
    }

    private func focusFirstOption() {
        guard let first = viewModel.options.first else {
            focusedField = nil
            return
        }
        focusedField = .option(first.id)
    }

    /// Moves focus to the option after `id`. If the user just typed into the
    /// trailing empty placeholder, the view model has already appended a new
    /// placeholder so focus lands on it; otherwise the keyboard dismisses.
    private func advanceFocus(after id: UUID) {
        guard let index = viewModel.options.firstIndex(where: { $0.id == id }) else {
            focusedField = nil
            return
        }
        let nextIndex = index + 1
        guard nextIndex < viewModel.options.count else {
            focusedField = nil
            return
        }
        focusedField = .option(viewModel.options[nextIndex].id)
    }
}

private enum CreatePollFocusField: Hashable {
    case question
    case option(UUID)
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
                    .font(fonts.subheadline)
                    .foregroundColor(Color(colors.textTertiary))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            content
        }
        .padding(tokens.spacingMd)
        .background(Color(colors.backgroundCoreSurfaceCard))
        .clipShape(RoundedRectangle(cornerRadius: tokens.radiusLg))
        .accessibilityElement(children: .combine)
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
            stepperButton(
                systemName: "minus",
                enabled: canDecrement,
                accessibilityLabel: L10n.Composer.Polls.Accessibility.decreaseVoteLimit,
                action: onDecrement
            )

            Text(text)
                .font(fonts.body)
                .foregroundColor(Color(colors.textPrimary))
                .frame(width: tokens.buttonVisualHeightMd, height: tokens.buttonVisualHeightLg)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(L10n.Composer.Polls.Accessibility.voteLimit))
                .accessibilityValue(Text(text))

            stepperButton(
                systemName: "plus",
                enabled: canIncrement,
                accessibilityLabel: L10n.Composer.Polls.Accessibility.increaseVoteLimit,
                action: onIncrement
            )
        }
    }

    private func stepperButton(
        systemName: String,
        enabled: Bool,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: tokens.iconSizeSm))
                .foregroundColor(Color(enabled ? colors.textPrimary : colors.textTertiary))
                .frame(width: tokens.buttonVisualHeightMd, height: tokens.buttonVisualHeightMd)
                .background(
                    Circle()
                        .strokeBorder(
                            Color(enabled ? colors.buttonSecondaryBorder : colors.borderUtilityDisabledOnSurface),
                            lineWidth: 1
                        )
                )
                .contentShape(Circle())
        }
        .buttonStyle(.borderless)
        .disabled(!enabled)
        .frame(width: tokens.buttonVisualHeightLg, height: tokens.buttonVisualHeightLg)
        .accessibilityLabel(Text(accessibilityLabel))
    }
}

// MARK: - Scroll Dismisses Keyboard

/// Dismisses the keyboard interactively when the user drags the list. Lets
/// people pull the keyboard down without first tapping outside any text
/// field. Gated on iOS 16+ where `scrollDismissesKeyboard` is available.
private struct CreatePollScrollDismissesKeyboardModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.scrollDismissesKeyboard(.interactively)
        } else {
            content
        }
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
                .listRowBackground(Color(colors.backgroundCoreElevation1))
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
