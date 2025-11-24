//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

struct NewChatView: View, KeyboardReadable {
    @Injected(\.fonts) var fonts
    @Injected(\.colors) var colors

    @StateObject var viewModel = NewChatViewModel()

    @Binding var isNewChatShown: Bool

    @State private var keyboardShown = false

    let columns = [GridItem(.adaptive(minimum: 120), spacing: 2)]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("TO:")
                    .font(fonts.footnote)
                    .foregroundColor(Color(colors.textLowEmphasis))

                VStack {
                    if !viewModel.selectedUsers.isEmpty {
                        LazyVGrid(columns: columns, alignment: .leading) {
                            ForEach(viewModel.selectedUsers) { user in
                                SelectedUserView(user: user)
                                    .onTapGesture(
                                        perform: {
                                            withAnimation {
                                                viewModel.userTapped(user)
                                            }
                                        }
                                    )
                            }
                        }
                    }

                    SearchUsersView(viewModel: viewModel)
                }
            }
            .padding()

            // Show create group button and info label when not in selected state or when searching
            if viewModel.state != .selected || !viewModel.searchText.isEmpty {
                // Show create group button if no search text and no users selected
                if viewModel.searchText.isEmpty && viewModel.selectedUsers.isEmpty {
                    CreateGroupButton(isNewChatShown: $isNewChatShown)
                }

                // Show info label
                UsersHeaderView(title: viewModel.infoLabelText)
            }

            if viewModel.state == .loading {
                VerticallyCenteredView {
                    ProgressView()
                }
            } else if viewModel.state == .searching {
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
                        .onAppear {
                            viewModel.onChatUserAppear(user)
                        }
                    }
                }
                .listStyle(.plain)
            } else if viewModel.state == .noUsers {
                VerticallyCenteredView {
                    VStack {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(Color(colors.textLowEmphasis))
                        Text("No user matches these keywords...")
                            .font(.title2)
                            .foregroundColor(Color(colors.textLowEmphasis))
                    }
                }
            } else if viewModel.state == .selected && viewModel.searchText.isEmpty && !viewModel.isShowingSearchResults {
                if let controller = viewModel.channelController {
                    // Show custom view for new channels (channel not yet created)
                    if !viewModel.channelCreated && controller.channel == nil {
                        VStack(spacing: 0) {
                            VStack {
                                Spacer()
                                Text("No chats here yet...")
                                    .font(.title2)
                                    .foregroundColor(Color(colors.textLowEmphasis))
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                            Divider()

                            // Show composer even without synchronized channel
                            DemoAppFactory.shared.makeMessageComposerViewType(
                                with: controller,
                                messageController: nil,
                                quotedMessage: .constant(nil),
                                editedMessage: .constant(nil),
                                onMessageSent: {
                                    // After message is sent, channel will be synchronized
                                    // The delegate will trigger view update
                                }
                            )
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .modifier(TabBarVisibilityModifier())
                        .onAppear {
                            // Ensure tab bar stays hidden
                            if UIDevice.current.userInterfaceIdiom == .phone {
                                if #available(iOS 16.0, *) {
                                    // Already handled by modifier
                                } else {
                                    UITabBar.appearance().isHidden = true
                                }
                            }
                        }
                    } else {
                        // Channel exists, show normal ChatChannelView
                        ChatChannelView(
                            viewFactory: DemoAppFactory.shared,
                            channelController: controller
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .modifier(TabBarVisibilityModifier())
                        .id("channel-\(controller.cid?.rawValue ?? "new")")
                        .onAppear {
                            // Ensure tab bar stays hidden
                            if UIDevice.current.userInterfaceIdiom == .phone {
                                if #available(iOS 16.0, *) {
                                    // Already handled by modifier
                                } else {
                                    UITabBar.appearance().isHidden = true
                                }
                            }
                        }
                    }
                } else {
                    VerticallyCenteredView {
                        ProgressView()
                    }
                }
            } else if viewModel.state == .error {
                VerticallyCenteredView {
                    Text("Error loading the users")
                        .font(.title2)
                        .foregroundColor(Color(colors.textLowEmphasis))
                }
            } else {
                Spacer()
            }
        }
        .toolbarThemed {
            ToolbarItem(placement: .principal) {
                Text("New Chat")
                    .font(fonts.bodyBold)
                    .foregroundColor(Color(colors.navigationBarTitle))
            }
        }
        .onReceive(keyboardWillChangePublisher) { visible in
            keyboardShown = visible
        }
        .modifier(HideKeyboardOnTapGesture(shouldAdd: keyboardShown))
        .onAppear {
            viewModel.loadInitialUsers()
        }
    }
}

struct TabBarVisibilityModifier: ViewModifier {
    func body(content: Content) -> some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            if #available(iOS 16.0, *) {
                content.toolbar(.hidden, for: .tabBar)
            } else {
                content
                    .onAppear {
                        UITabBar.appearance().isHidden = true
                    }
                    .onDisappear {
                        UITabBar.appearance().isHidden = false
                    }
            }
        } else {
            content
        }
    }
}

struct SelectedUserView: View {
    @Injected(\.colors) var colors

    var user: ChatUser

    var body: some View {
        HStack {
            MessageAvatarView(
                avatarURL: user.imageURL,
                size: CGSize(width: 20, height: 20)
            )

            Text(user.name ?? user.id)
                .lineLimit(1)
                .padding(.vertical, 2)
                .padding(.trailing)
        }
        .background(Color(colors.background1))
        .cornerRadius(16)
    }
}

struct SearchUsersView: View {
    @ObservedObject var viewModel: NewChatViewModel

    var body: some View {
        HStack {
            TextField("Type a name", text: $viewModel.searchText)
            Button {
                if viewModel.state == .selected && viewModel.searchText.isEmpty {
                    viewModel.showSearchResults()
                }
            } label: {
                Image(systemName: viewModel.state == .selected && viewModel.searchText.isEmpty ? "person.badge.plus" : "person")
            }
        }
    }
}

struct VerticallyCenteredView<Content: View>: View {
    var content: () -> Content

    var body: some View {
        VStack {
            Spacer()
            content()
            Spacer()
        }
    }
}

struct CreateGroupButton: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts

    @Binding var isNewChatShown: Bool

    var body: some View {
        NavigationLink {
            CreateGroupView(isNewChatShown: $isNewChatShown)
        } label: {
            HStack {
                Image(systemName: "person.3")
                    .renderingMode(.template)
                    .foregroundColor(colors.tintColor)

                Text("Create a group")
                    .font(fonts.bodyBold)
                    .foregroundColor(Color(colors.text))

                Spacer()
            }
            .padding()
        }
        .isDetailLink(false)
    }
}

struct ChatUserView: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts

    var user: ChatUser
    var onlineText: String
    var isSelected: Bool

    var body: some View {
        HStack {
            LazyView(
                MessageAvatarView(avatarURL: user.imageURL)
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(user.name ?? user.id)
                    .lineLimit(1)
                    .font(fonts.bodyBold)
                Text(onlineText)
                    .font(fonts.footnote)
                    .foregroundColor(Color(colors.textLowEmphasis))
            }
            Spacer()

            if isSelected {
                Image(systemName: "checkmark")
                    .renderingMode(.template)
                    .foregroundColor(colors.tintColor)
            }
        }
    }
}

struct UsersHeaderView: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts

    var title: String

    var body: some View {
        HStack {
            Text(title)
                .padding(.horizontal)
                .padding(.vertical, 2)
                .font(fonts.body)
                .foregroundColor(Color(colors.textLowEmphasis))

            Spacer()
        }
        .background(Color(colors.background1))
    }
}
