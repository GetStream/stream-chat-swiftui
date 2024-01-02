//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChatSwiftUI
import SwiftUI

struct GroupNameView: View, KeyboardReadable {

    @Injected(\.fonts) var fonts
    @Injected(\.colors) var colors

    @StateObject var viewModel: CreateGroupViewModel

    @Binding var isNewChatShown: Bool

    @State private var keyboardShown = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("NAME")
                    .font(fonts.footnote)
                    .foregroundColor(Color(colors.textLowEmphasis))

                TextField(
                    "Choose a group chat name",
                    text: $viewModel.groupName
                )

                Spacer()

                GroupControlsView(
                    viewModel: viewModel,
                    isNewChatShown: $isNewChatShown
                )
            }
            .padding()

            UsersHeaderView(title: "\(viewModel.selectedUsers.count) Members")

            List(viewModel.selectedUsers) { user in
                HStack {
                    ChatUserView(
                        user: user,
                        onlineText: viewModel.onlineInfo(for: user),
                        isSelected: false
                    )

                    Spacer()

                    Button {
                        viewModel.userTapped(user)
                    } label: {
                        Image(systemName: "xmark")
                            .renderingMode(.template)
                            .foregroundColor(Color(colors.text))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Name of Group Chat")
        .alert(isPresented: $viewModel.errorShown) {
            Alert.defaultErrorAlert
        }
        .onReceive(keyboardWillChangePublisher) { visible in
            keyboardShown = visible
        }
        .modifier(HideKeyboardOnTapGesture(shouldAdd: keyboardShown))
    }
}

struct GroupControlsView: View {

    @Injected(\.colors) var colors

    @StateObject var viewModel: CreateGroupViewModel
    @Binding var isNewChatShown: Bool

    var body: some View {
        HStack {
            Button {
                viewModel.showChannelView()
            } label: {
                Image(systemName: "checkmark")
                    .renderingMode(.template)
                    .foregroundColor(
                        viewModel.canCreateGroup ? colors.tintColor : Color(colors.textLowEmphasis)
                    )
            }
            .disabled(!viewModel.canCreateGroup)

            Button {
                viewModel.groupName = ""
            } label: {
                Image(systemName: "xmark.circle")
                    .renderingMode(.template)
                    .foregroundColor(Color(colors.textLowEmphasis))
            }

            NavigationLink(
                isActive: $viewModel.showGroupConversation,
                destination: {
                    if let controller = viewModel.channelController {
                        ChatChannelView(
                            viewFactory: DemoAppFactory.shared,
                            channelController: controller
                        )
                        .onDisappear {
                            isNewChatShown = false
                        }
                    } else {
                        EmptyView()
                    }
                }
            ) {
                EmptyView()
            }
            .isDetailLink(false)
        }
    }
}
