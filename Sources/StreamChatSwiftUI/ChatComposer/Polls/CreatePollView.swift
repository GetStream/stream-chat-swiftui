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
                    CreatePollInputFields(viewModel: viewModel)
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

    // MARK: - Settings

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

// MARK: - Input Fields

/// Renders the question + options portion of the form and (on iOS 15+)
/// wires the keyboard's `Next` return-key to advance focus between
/// fields. Hides the availability split from the parent view so
/// `CreatePollView.body` can reference a single entry point.
private struct CreatePollInputFields: View {
    @ObservedObject var viewModel: CreatePollViewModel

    var body: some View {
        if #available(iOS 15.0, *) {
            CreatePollFocusedInputFields(viewModel: viewModel)
        } else {
            CreatePollPlainInputFields(viewModel: viewModel)
        }
    }
}

@available(iOS 15.0, *)
private struct CreatePollFocusedInputFields: View {
    @ObservedObject var viewModel: CreatePollViewModel
    @FocusState private var focused: CreatePollInputField?

    var body: some View {
        CreatePollQuestionContainer(text: $viewModel.question) { textField in
            textField.modifier(CreatePollInputFieldFocus(
                focused: $focused,
                field: .question,
                onSubmit: { focused = firstOption }
            ))
        }
        CreatePollOptionsLabelRow()
        CreatePollOptionRows(viewModel: viewModel) { option, textField in
            textField.modifier(CreatePollInputFieldFocus(
                focused: $focused,
                field: .option(option.id),
                onSubmit: { focused = nextOption(after: option.id) }
            ))
        }
    }

    private var firstOption: CreatePollInputField? {
        viewModel.options.first.map { .option($0.id) }
    }

    /// Returns the focus target after the option identified by `id`, or `nil`
    /// when there is none (which dismisses the keyboard). If the user just
    /// typed into the trailing empty placeholder, the view model has already
    /// appended a new placeholder so focus lands on it.
    private func nextOption(after id: UUID) -> CreatePollInputField? {
        guard
            let index = viewModel.options.firstIndex(where: { $0.id == id }),
            index + 1 < viewModel.options.count
        else { return nil }
        return .option(viewModel.options[index + 1].id)
    }
}

private struct CreatePollPlainInputFields: View {
    @ObservedObject var viewModel: CreatePollViewModel

    var body: some View {
        CreatePollQuestionContainer(text: $viewModel.question)
        CreatePollOptionsLabelRow()
        CreatePollOptionRows(viewModel: viewModel)
    }
}

private enum CreatePollInputField: Hashable {
    case question
    case option(UUID)
}

/// Wraps a `TextField` so the keyboard's `Next` button moves focus to the
/// caller-supplied next target. iOS 15+ only.
@available(iOS 15.0, *)
private struct CreatePollInputFieldFocus: ViewModifier {
    let focused: FocusState<CreatePollInputField?>.Binding
    let field: CreatePollInputField
    let onSubmit: () -> Void

    func body(content: Content) -> some View {
        content
            .focused(focused, equals: field)
            .submitLabel(.next)
            .onSubmit(onSubmit)
    }
}

// MARK: - Question Container

/// Owns the question `TextField`. Callers can pass a `decorate` closure to
/// layer modifiers (e.g. focus) on the text field without duplicating the
/// container chrome or the binding. The convenience init handles the
/// common "no decoration" case.
private struct CreatePollQuestionContainer<DecoratedField: View>: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    @Binding var text: String
    @ViewBuilder var decorate: (TextField<Text>) -> DecoratedField

    var body: some View {
        VStack(alignment: .leading, spacing: tokens.spacingXs) {
            Text(L10n.Composer.Polls.question)
                .font(fonts.body)
                .foregroundColor(Color(colors.textPrimary))
            decorate(TextField(L10n.Composer.Polls.askQuestion, text: $text))
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

extension CreatePollQuestionContainer where DecoratedField == TextField<Text> {
    init(text: Binding<String>) {
        self.init(text: text, decorate: { $0 })
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

// MARK: - Option Rows

/// Renders the reorderable list of option rows. Callers can pass a
/// `decorate` closure to layer modifiers (e.g. focus) on each row's text
/// field, keeping the row layout and view-model wiring in one place.
private struct CreatePollOptionRows<DecoratedField: View>: View {
    @Injected(\.tokens) private var tokens

    @ObservedObject var viewModel: CreatePollViewModel
    @ViewBuilder var decorate: (PollOptionEntry, TextField<Text>) -> DecoratedField

    var body: some View {
        let reorderableCount = viewModel.reorderableOptionCount
        ForEach(Array(viewModel.options.enumerated()), id: \.element.id) { index, option in
            CreatePollOptionRow(
                text: option.text,
                position: option.text.isEmpty ? nil : index + 1,
                totalCount: reorderableCount,
                showsReorderIcon: !option.text.isEmpty,
                showsDeleteButton: !viewModel.isLastOption(option),
                showsError: viewModel.showsOptionError(for: option),
                onTextChanged: { newText in
                    let id = option.id
                    Task { @MainActor in
                        viewModel.updateOption(id: id, value: newText)
                    }
                },
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
                decorate: { textField in decorate(option, textField) }
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
}

extension CreatePollOptionRows where DecoratedField == TextField<Text> {
    init(viewModel: CreatePollViewModel) {
        self.init(viewModel: viewModel) { _, textField in textField }
    }
}

// MARK: - Option Row

private struct CreatePollOptionRow<DecoratedField: View>: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    let text: String
    let position: Int?
    let totalCount: Int
    let showsReorderIcon: Bool
    let showsDeleteButton: Bool
    let showsError: Bool
    let onTextChanged: @Sendable (String) -> Void
    let onDelete: () -> Void
    let onAccessibilityMove: (AccessibilityAdjustmentDirection) -> Bool
    @ViewBuilder var decorate: (TextField<Text>) -> DecoratedField

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: tokens.spacingXs) {
                if showsReorderIcon {
                    reorderHandle
                }
                decorate(
                    TextField(
                        L10n.Composer.Polls.addOption,
                        text: Binding(get: { text }, set: onTextChanged)
                    )
                )
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
