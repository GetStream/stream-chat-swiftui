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
                
                Toggle("Anonymous poll", isOn: $viewModel.anonymousPoll)
                
                Toggle("Suggest an option", isOn: $viewModel.suggestAnOption)
                
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
