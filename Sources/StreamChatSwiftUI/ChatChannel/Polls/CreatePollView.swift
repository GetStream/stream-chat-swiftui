//
// Copyright © 2024 Stream.io Inc. All rights reserved.
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

struct CreatePollView: View {
    
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    
    @StateObject var viewModel: CreatePollViewModel
    
    @Environment(\.presentationMode) var presentationMode
    
    @Environment(\.editMode) var editMode
    
    @State private var listId = UUID()
    
    init(chatController: ChatChannelController, messageController: ChatMessageController?) {
        _viewModel = StateObject(
            wrappedValue: CreatePollViewModel(
                chatController: chatController,
                messageController: messageController
            )
        )
    }
                
    var body: some View {
        NavigationView {
            List {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.Composer.Polls.question)
                        .modifier(ListRowModifier())
                        .padding(.bottom, 4)
                    TextField(L10n.Composer.Polls.askQuestion, text: $viewModel.question)
                        .modifier(CreatePollItemModifier())
                }
                .modifier(ListRowModifier())
                                
                Text(L10n.Composer.Polls.options)
                    .modifier(ListRowModifier())
                    .padding(.bottom, -16)
                
                ForEach(viewModel.options.indices, id: \.self) { index in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            if viewModel.showsOptionError(for: index) {
                                Text(L10n.Composer.Polls.duplicateOption)
                                    .foregroundColor(Color(colors.alert))
                                    .font(fonts.caption1)
                                    .transition(.opacity)
                            }
                            TextField(L10n.Composer.Polls.addOption, text: Binding(
                                get: { viewModel.options[index] },
                                set: { newValue in
                                    viewModel.options[index] = newValue
                                    // Check if the current text field is the last one
                                    if index == viewModel.options.count - 1,
                                       !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        // Add a new text field
                                        withAnimation {
                                            viewModel.options.append("")
                                        }
                                    }
                                }
                            ))
                        }
                        Spacer()
                        if index < viewModel.options.count - 1 {
                            Image(systemName: "equal")
                                .foregroundColor(Color(colors.textLowEmphasis))
                        }
                    }
                    .padding(.vertical, viewModel.showsOptionError(for: index) ? -8 : 0)
                    .modifier(CreatePollItemModifier())
                    .moveDisabled(index == viewModel.options.count - 1)
                    .animation(.easeIn, value: viewModel.optionsErrorIndices)
                }
                .onMove(perform: move)
                .onDelete { indices in
                    // Allow deletion of any text field
                    viewModel.options.remove(atOffsets: indices)
                }
                .modifier(ListRowModifier())
                                
                if viewModel.multipleAnswersShown {
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle(L10n.Composer.Polls.multipleAnswers, isOn: $viewModel.multipleAnswers)
                        if viewModel.multipleAnswers {
                            HStack(alignment: .textFieldToggle) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(L10n.Composer.Polls.typeNumberFrom1And10)
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
                            .padding(.top, 8)
                        }
                    }
                    .modifier(CreatePollItemModifier())
                    .padding(.top, 16)
                }
                
                if viewModel.anonymousPollShown {
                    Toggle(L10n.Composer.Polls.anonymousPoll, isOn: $viewModel.anonymousPoll)
                        .modifier(CreatePollItemModifier())
                }
                
                if viewModel.suggestAnOptionShown {
                    Toggle(L10n.Composer.Polls.suggestOption, isOn: $viewModel.suggestAnOption)
                        .modifier(CreatePollItemModifier())
                }
                
                if viewModel.addCommentsShown {
                    Toggle(L10n.Composer.Polls.addComment, isOn: $viewModel.allowComments)
                        .modifier(CreatePollItemModifier())
                }
                
                Spacer()
                    .modifier(ListRowModifier())
            }
            .background(Color(colors.background).ignoresSafeArea())
            .listStyle(.plain)
            .id(listId)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        if viewModel.canShowDiscardConfirmation {
                            viewModel.discardConfirmationShown = true
                        } else {
                            presentationMode.wrappedValue.dismiss()
                        }
                    } label: {
                        Text(L10n.Alert.Actions.cancel)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text(L10n.Composer.Polls.createPoll)
                        .bold()
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.createPoll {
                            presentationMode.wrappedValue.dismiss()
                        }
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(colors.tintColor)
                    }
                    .disabled(!viewModel.canCreatePoll)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .actionSheet(isPresented: $viewModel.discardConfirmationShown) {
                ActionSheet(
                    title: Text(L10n.Composer.Polls.actionSheetDiscardTitle),
                    buttons: [
                        .destructive(Text(L10n.Alert.Actions.discardChanges)) {
                            presentationMode.wrappedValue.dismiss()
                        },
                        .cancel(Text(L10n.Alert.Actions.keepEditing))
                    ]
                )
            }
            .alert(isPresented: $viewModel.errorShown) {
                Alert.defaultErrorAlert
            }
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        viewModel.options.move(fromOffsets: source, toOffset: destination)
        listId = UUID()
    }
}

struct CreatePollItemModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .modifier(ListRowModifier())
            .withPollsBackground()
            .padding(.vertical, -4)
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
    private struct TextFieldToggleAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[VerticalAlignment.center]
        }
    }

    /// Alignment for a text field with extra text and a toggle.
    static let textFieldToggle = VerticalAlignment(
        TextFieldToggleAlignment.self
    )
}
