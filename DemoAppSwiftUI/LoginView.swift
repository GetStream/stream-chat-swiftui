//
// Copyright © 2025 Stream.io Inc. All rights reserved.
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
            
            Button("Configuration") {
                viewModel.showsConfiguration = true
            }
            .buttonStyle(.borderedProminent)

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
            }
            .listStyle(.plain)

            Spacer()
        }
        .overlay(
            viewModel.loading ? ProgressView() : nil
        )
        .sheet(isPresented: $viewModel.showsConfiguration) {
            AppConfigurationView()
        }
    }
}

struct DemoUserView: View {
    @Injected(\.fonts) var fonts
    @Injected(\.colors) var colors

    var user: UserCredentials

    private let imageSize: CGFloat = 44

    var body: some View {
        HStack {
            if user.isGuest {
                Image(systemName: "person.fill")
                    .resizable()
                    .foregroundColor(colors.tintColor)
                    .frame(width: imageSize, height: imageSize)
                    .aspectRatio(contentMode: .fit)
                    .background(Color(colors.background6))
                    .clipShape(Circle())
            } else {
                StreamLazyImage(
                    url: user.avatarURL,
                    size: CGSize(width: imageSize, height: imageSize)
                )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(fonts.bodyBold)
                Text(user.isGuest ? "Login as Guest" : "Stream test account")
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
