//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChatSwiftUI
import SwiftUI

struct LoginView: View {

    @StateObject var viewModel = LoginViewModel()

    var body: some View {
        VStack {
            Image("STREAMMARK")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 40)
                .padding(.all, 24)

            Text("Welcome to Stream Chat")
                .font(.title)
                .padding(.all, 8)

            Text("Select a user to try the iOS SDK:")
                .font(.body)
                .padding(.all, 8)
                .padding(.bottom, 16)

            List(viewModel.demoUsers) { user in
                Button {
                    viewModel.demoUserTapped(user)
                } label: {
                    DemoUserView(user: user)
                }
                .padding(.vertical, 4)
                .animation(nil)
            }
            .listStyle(.plain)

            Spacer()
        }
        .overlay(
            viewModel.loading ? ProgressView() : nil
        )
    }
}

struct DemoUserView: View {

    @Injected(\.fonts) var fonts
    @Injected(\.colors) var colors

    var user: UserCredentials

    private let imageSize: CGFloat = 44

    var body: some View {
        HStack {
            StreamLazyImage(
                url: user.avatarURL,
                size: CGSize(width: imageSize, height: imageSize)
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(fonts.bodyBold)
                Text("Stream test account")
                    .font(fonts.footnote)
                    .foregroundColor(Color(colors.textLowEmphasis))
            }

            Spacer()

            Image(systemName: "arrow.forward")
                .renderingMode(.template)
                .foregroundColor(colors.tintColor)
        }
    }
}
