//
// Copyright © 2024 Stream.io Inc. All rights reserved.
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

            if viewModel.state != .channel {
                CreateGroupButton(isNewChatShown: $isNewChatShown)
                UsersHeaderView()
            }

            if viewModel.state == .loading {
                VerticallyCenteredView {
                    ProgressView()
                }
            } else if viewModel.state == .loaded {
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
                    Text("No user matches these keywords")
                        .font(.title2)
                        .foregroundColor(Color(colors.textLowEmphasis))
                }
            } else if viewModel.state == .error {
                VerticallyCenteredView {
                    Text("Error loading the users")
                        .font(.title2)
                        .foregroundColor(Color(colors.textLowEmphasis))
                }
            } else if viewModel.state == .channel, let controller = viewModel.channelController {
                Divider()
                ChatChannelView(
                    viewFactory: DemoAppFactory.shared,
                    channelController: controller
                )
            } else {
                Spacer()
            }
        }
        .navigationTitle("New Chat")
        .onReceive(keyboardWillChangePublisher) { visible in
            keyboardShown = visible
        }
        .modifier(HideKeyboardOnTapGesture(shouldAdd: keyboardShown))
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

    @StateObject var viewModel: NewChatViewModel

    var body: some View {
        HStack {
            TextField("Type a name", text: $viewModel.searchText)
            Button {
                if viewModel.state == .channel {
                    withAnimation {
                        viewModel.state = .loaded
                    }
                }
            } label: {
                Image(systemName: "person.badge.plus")
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

    var title = "On the platform"

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
