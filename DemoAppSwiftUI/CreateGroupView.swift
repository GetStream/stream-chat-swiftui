//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

struct CreateGroupView: View, KeyboardReadable {
    
    @Injected(\.fonts) var fonts
    @Injected(\.colors) var colors
    
    @StateObject var viewModel = CreateGroupViewModel()
    
    @Binding var isNewChatShown: Bool
    
    @State private var keyboardShown = false
    
    var body: some View {
        VStack(spacing: 0) {
            SearchBar(text: $viewModel.searchText)
                .padding(.vertical, !viewModel.selectedUsers.isEmpty ? 0 : 16)
            
            ScrollView(.horizontal) {
                HStack(spacing: 16) {
                    ForEach(viewModel.selectedUsers) { user in
                        SelectedUserGroupView(
                            viewModel: viewModel,
                            user: user
                        )
                    }
                }
                .padding(.all, !viewModel.selectedUsers.isEmpty ? 16 : 0)
            }
            
            UsersHeaderView()
            List(viewModel.chatUsers) { user in
                Button {
                    withAnimation {
                        viewModel.userTapped(user)
                    }
                } label: {
                    ChatUserView(
                        user: user,
                        onlineText: viewModel.onlineInfo(for: user),
                        isSelected: viewModel.isSelected(user: user)
                    )
                }
            }
            .listStyle(.plain)
        }
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    GroupNameView(
                        viewModel: viewModel,
                        isNewChatShown: $isNewChatShown
                    )
                } label: {
                    Image(systemName: "arrow.forward")
                }
                .isDetailLink(false)
                .disabled(viewModel.selectedUsers.isEmpty)
            }
        })
        .navigationTitle("Add group members")
        .alert(isPresented: $viewModel.errorShown) {
            Alert.defaultErrorAlert
        }
        .onReceive(keyboardWillChangePublisher) { visible in
            keyboardShown = visible
        }
        .modifier(HideKeyboardOnTapGesture(shouldAdd: keyboardShown))
    }
}

struct SelectedUserGroupView: View {
    
    @Injected(\.fonts) var fonts
    
    private let avatarSize: CGFloat = 50
    
    @StateObject var viewModel: CreateGroupViewModel
    var user: ChatUser
    
    var body: some View {
        VStack {
            MessageAvatarView(
                avatarURL: user.imageURL,
                size: CGSize(width: avatarSize, height: avatarSize)
            )
            
            Text(user.name ?? user.id)
                .lineLimit(1)
                .font(fonts.footnote)
        }
        .overlay(
            TopRightView {
                Button(action: {
                    withAnimation {
                        viewModel.userTapped(user)
                    }
                }, label: {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 16, height: 16)
                        
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color.black.opacity(0.8))
                    }
                    .padding(.all, 4)
                })
            }
            .offset(x: 6, y: -4)
        )
        .frame(width: avatarSize)
    }
}

struct SearchBar: View {
    
    @Injected(\.colors) var colors
    
    @Binding var text: String
    
    @State private var isEditing = false
    
    var body: some View {
        HStack {
            
            TextField("Search ...", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(colors.background1))
                .cornerRadius(16)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if isEditing {
                            Button(action: {
                                self.text = ""
                                
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .padding(.horizontal, 10)
                .onTapGesture {
                    self.isEditing = true
                }
            
            if isEditing {
                Button(action: {
                    self.isEditing = false
                    self.text = ""
                    
                    // Dismiss the keyboard
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                }) {
                    Text("Cancel")
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
        }
    }
}
