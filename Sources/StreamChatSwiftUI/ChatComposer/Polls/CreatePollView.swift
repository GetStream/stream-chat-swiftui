//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

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

public struct CreatePollView: View {
    @Injected(\.colors) var colors
    @Injected(\.images) var images
    @Injected(\.fonts) var fonts
    @Injected(\.tokens) var tokens
    
    @StateObject var viewModel: CreatePollViewModel
    
    @Environment(\.presentationMode) var presentationMode
    
    @Environment(\.editMode) var editMode
    
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
                // Question group
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

                // Options group
                Text(L10n.Composer.Polls.options)
                    .font(fonts.body)
                    .foregroundColor(Color(colors.textPrimary))
                    .modifier(CreatePollRowModifier(
                        topSpacing: tokens.spacingSm,
                        bottomSpacing: tokens.spacingXxs
                    ))

                ForEach(viewModel.options.indices, id: \.self) { index in
                    pollOptionRow(for: index)
                }
                .onMove(perform: move)
                .modifier(CreatePollRowModifier(
                    topSpacing: tokens.spacingXxs,
                    bottomSpacing: tokens.spacingXxs
                ))

                // Spacer bridging 32pt gap between Options and Settings
                Color.clear
                    .frame(height: tokens.spacingLg)
                    .modifier(CreatePollRowModifier(topSpacing: 0, bottomSpacing: 0))

                // Settings cards
                if viewModel.multipleAnswersShown {
                    pollOptionCard(
                        title: L10n.Composer.Polls.multipleAnswers,
                        subtitle: L10n.Composer.Polls.selectMoreThanOneOption
                    ) {
                        VStack(alignment: .leading, spacing: tokens.spacingXs) {
                            Toggle("", isOn: $viewModel.multipleAnswers)
                                .labelsHidden()
                            if viewModel.multipleAnswers {
                                HStack(alignment: .textFieldToggle) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(L10n.Composer.Polls.typeNumberMinMaxRange)
                                            .foregroundColor(Color(colors.alert))
                                            .font(fonts.caption1)
                                            .offset(y: viewModel.showsMaxVotesError ? 0 : 6)
                                            .opacity(viewModel.showsMaxVotesError ? 1 : 0)
                                            .animation(.easeIn, value: viewModel.showsMaxVotesError)
                                        TextField(L10n.Composer.Polls.maximumVotesPerPerson, text: $viewModel.maxVotes)
                                            .alignmentGuide(.textFieldToggle, computeValue: { $0[VerticalAlignment.center] })
                                            .disabled(!viewModel.maxVotesEnabled)
                                    }
                                    .accessibilityElement(children: .combine)
                                    if viewModel.maxVotesShown {
                                        Toggle("", isOn: $viewModel.maxVotesEnabled)
                                            .alignmentGuide(.textFieldToggle, computeValue: { $0[VerticalAlignment.center] })
                                            .frame(width: 64)
                                    }
                                }
                                .padding(.top, tokens.spacingXs)
                            }
                        }
                    }
                }

                if viewModel.anonymousPollShown {
                    pollOptionCard(
                        title: L10n.Composer.Polls.anonymousPoll,
                        subtitle: L10n.Composer.Polls.hideWhoVoted
                    ) {
                        Toggle("", isOn: $viewModel.anonymousPoll).labelsHidden()
                    }
                }

                if viewModel.suggestAnOptionShown {
                    pollOptionCard(
                        title: L10n.Composer.Polls.suggestOption,
                        subtitle: L10n.Composer.Polls.letOthersAddOptions
                    ) {
                        Toggle("", isOn: $viewModel.suggestAnOption).labelsHidden()
                    }
                }

                if viewModel.addCommentsShown {
                    pollOptionCard(
                        title: L10n.Composer.Polls.addComment,
                        subtitle: L10n.Composer.Polls.allowOthersToAddComments
                    ) {
                        Toggle("", isOn: $viewModel.allowComments).labelsHidden()
                    }
                }

                Spacer()
                    .modifier(CreatePollRowModifier(topSpacing: 0, bottomSpacing: 0))
            }
            .environment(\.defaultMinListRowHeight, 1)
            .background(Color(colors.background).ignoresSafeArea())
            .listStyle(.plain)
            .id(listId)
            .toolbarThemed {
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
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $viewModel.errorShown) {
                Alert.defaultErrorAlert
            }
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        viewModel.options.move(fromOffsets: source, toOffset: destination)
        listId = UUID()
    }

    @ViewBuilder
    private func pollOptionRow(for index: Int) -> some View {
        let showsError = viewModel.showsOptionError(for: index)
        
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: tokens.spacingXs) {
                if viewModel.options[index].isEmpty == false {
                    Image(uiImage: images.pollReorderIcon)
                        .font(.system(size: tokens.iconSizeSm))
                        .foregroundColor(Color(colors.textTertiary))
                }
                TextField(L10n.Composer.Polls.addOption, text: Binding(
                    get: { viewModel.options[index] },
                    set: { newValue in
                        viewModel.options[index] = newValue
                        if index == viewModel.options.count - 1,
                           !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            withAnimation {
                                viewModel.options.append("")
                            }
                        }
                    }
                ))
                .font(fonts.body)
                .foregroundColor(Color(colors.inputTextDefault))
                if index < viewModel.options.count - 1 {
                    Button {
                        viewModel.options.remove(at: index)
                    } label: {
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
        .background(
            RoundedRectangle(cornerRadius: tokens.radiusLg)
                .strokeBorder(Color(colors.borderCoreDefault), lineWidth: 1)
        )
        .moveDisabled(index == viewModel.options.count - 1)
    }

    @ViewBuilder
    private func pollOptionCard<Content: View>(
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
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
            content()
        }
        .padding(tokens.spacingMd)
        .background(Color(colors.backgroundCoreSurfaceCard))
        .cornerRadius(tokens.radiusLg)
        .modifier(CreatePollRowModifier(
            topSpacing: tokens.spacingXs,
            bottomSpacing: tokens.spacingXs
        ))
    }
}

private struct CreatePollRowModifier: ViewModifier {
    @Injected(\.colors) var colors
    @Injected(\.tokens) var tokens

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
    @Injected(\.colors) var colors

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

private extension VerticalAlignment {
    private final class TextFieldToggleAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[VerticalAlignment.center]
        }
    }

    /// Alignment for a text field with extra text and a toggle.
    static let textFieldToggle = VerticalAlignment(
        TextFieldToggleAlignment.self
    )
}
