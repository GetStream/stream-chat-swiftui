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
    
    @StateObject var viewModel = CreatePollViewModel()
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Text("Question")
                    .modifier(ListRowModifier())
                TextField("Add a question", text: $viewModel.question)
                    .modifier(ListRowModifier())

                Text("Options")
                    .modifier(ListRowModifier())
                
                ForEach($viewModel.options, id: \.self) { option in
                    TextField("Add an option", text: option)
                        .modifier(ListRowModifier())
                }
                .onMove(perform: move)
                
                HStack {
                    TextField("Add an option", text: $viewModel.blankOption)
                    Spacer()
                    Button {
                        if !viewModel.blankOption.isEmpty {
                            viewModel.options.append(viewModel.blankOption)
                            viewModel.blankOption = ""
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .disabled(viewModel.blankOption.isEmpty)
                }
                .modifier(ListRowModifier())
                
                Toggle("Multiple answers", isOn: $viewModel.multipleAnswers)
                
                if viewModel.multipleAnswers {
                    HStack {
                        TextField("Type a number between 1 and 10", text: $viewModel.maxVotes)
                            .disabled(!viewModel.maxVotesEnabled)
                        Toggle("", isOn: $viewModel.maxVotesEnabled)
                            .frame(width: 64)
                    }
                }
                
                Toggle("Anonymous poll", isOn: $viewModel.anonymousPoll)
                
                Toggle("Suggest an option", isOn: $viewModel.suggestAnOption)
                
                Toggle("Add a comment", isOn: $viewModel.allowComments)
                
                Spacer()
                    .modifier(ListRowModifier())
            }
            .listStyle(.plain)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Create poll")
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.createPoll {
                            presentationMode.wrappedValue.dismiss()
                        }
                    } label: {
                        Text("Add")
                    }
                }
            }
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        viewModel.options.move(fromOffsets: source, toOffset: destination)
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
