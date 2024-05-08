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
                Text("Create poll")
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
                    Text("Question")
                        .modifier(ListRowModifier())
                        .padding(.bottom, 4)
                    TextField("Add a question", text: $viewModel.question)
                        .modifier(CreatePollItemModifier())
                    
                }
                .modifier(ListRowModifier())
                                
                Text("Options")
                    .modifier(ListRowModifier())
                    .padding(.bottom, -16)
                
                ForEach(viewModel.options.indices, id: \.self) { index in
                    HStack {
                        TextField("Enter text", text: Binding(
                            get: { viewModel.options[index] },
                            set: { newValue in
                                viewModel.options[index] = newValue
                                // Check if the current text field is the last one
                                if index == viewModel.options.count - 1, !newValue.isEmpty {
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
                    Toggle("Multiple answers", isOn: $viewModel.multipleAnswers)
                    
                    if viewModel.multipleAnswers {
                        HStack {
                            TextField("Type a number between 1 and 10", text: $viewModel.maxVotes)
                                .disabled(!viewModel.maxVotesEnabled)
                            Toggle("", isOn: $viewModel.maxVotesEnabled)
                                .frame(width: 64)
                        }
                    }
                }
                .modifier(CreatePollItemModifier())
                .padding(.top, 16)
                
                Toggle("Anonymous poll", isOn: $viewModel.anonymousPoll)
                    .modifier(CreatePollItemModifier())
                
                Toggle("Suggest an option", isOn: $viewModel.suggestAnOption)
                    .modifier(CreatePollItemModifier())
                
                Toggle("Add a comment", isOn: $viewModel.allowComments)
                    .modifier(CreatePollItemModifier())
                
                Spacer()
                    .modifier(ListRowModifier())
            }
            .listStyle(.plain)
            .id(listId)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Create poll")
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
