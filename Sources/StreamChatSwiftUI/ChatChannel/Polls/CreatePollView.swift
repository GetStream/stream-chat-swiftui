//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct ComposerPollView: View {
    
    @State var createPollShown = false
    
    var body: some View {
        VStack {
            Spacer()
            Button {
                createPollShown = true
            } label: {
                Text(L10n.Composer.Polls.createPoll)
            }

            Spacer()
        }
        .sheet(isPresented: $createPollShown) {
            CreatePollView()
        }
        .onAppear {
            createPollShown = true
        }
    }
}

struct CreatePollView: View {
    
    @Injected(\.colors) var colors
    
    @StateObject var viewModel = CreatePollViewModel()
    
    @Environment(\.presentationMode) var presentationMode
    
    @Environment(\.editMode) var editMode
    
    @State var listId = UUID()
                
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
                        
                        Spacer()
                        if index < viewModel.options.count - 1 {
                            Image(systemName: "equal")
                                .foregroundColor(Color(colors.textLowEmphasis))
                        }
                    }
                    .modifier(CreatePollItemModifier())
                    .moveDisabled(index == viewModel.options.count - 1)
                }
                .onMove(perform: move)
                .onDelete { indices in
                    // Allow deletion of any text field
                    viewModel.options.remove(atOffsets: indices)
                }
                .modifier(ListRowModifier())
                                
                VStack(alignment: .leading) {
                    Toggle(L10n.Composer.Polls.multipleAnswers, isOn: $viewModel.multipleAnswers)
                    
                    if viewModel.multipleAnswers {
                        HStack {
                            TextField(L10n.Composer.Polls.typeNumberFrom1And10, text: $viewModel.maxVotes)
                                .disabled(!viewModel.maxVotesEnabled)
                            Toggle("", isOn: $viewModel.maxVotesEnabled)
                                .frame(width: 64)
                        }
                    }
                }
                .modifier(CreatePollItemModifier())
                .padding(.top, 16)
                
                Toggle(L10n.Composer.Polls.anonymousPoll, isOn: $viewModel.anonymousPoll)
                    .modifier(CreatePollItemModifier())
                
                Toggle(L10n.Composer.Polls.suggestOption, isOn: $viewModel.suggestAnOption)
                    .modifier(CreatePollItemModifier())
                
                Toggle(L10n.Composer.Polls.addComment, isOn: $viewModel.allowComments)
                    .modifier(CreatePollItemModifier())
                
                Spacer()
                    .modifier(ListRowModifier())
            }
            .listStyle(.plain)
            .id(listId)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(L10n.Composer.Polls.createPoll)
                        .bold()
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.createPoll {
                            presentationMode.wrappedValue.dismiss()
                        }
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(colors.tintColor)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
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
    
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .listRowSeparator(.hidden)
        } else {
            content
        }
    }
}
