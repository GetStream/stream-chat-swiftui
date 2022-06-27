//
//  StartPage.swift
//  StreamChatSwiftUITestsApp
//
//  Created by Boris Bielik on 26/05/2022.
//

import SwiftUI
import StreamChatSwiftUI

struct StartPage: View {
    
    @State var chatShown = false
    @ObservedObject var appState = AppState.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                Button {
                    appState.userState = .loggedIn
                } label: {
                    Text("Start Chat")
                }
                
                NavigationLink(isActive: $chatShown, destination: {
                    ChatChannelListView(viewFactory: DemoAppFactory.shared).navigationBarHidden(true)
                }, label: {
                    EmptyView()
                })
            }
            .accessibilityIdentifier("TestApp.Start")
            .navigationTitle("Test UI App")
            .navigationBarHidden(true)
            .onReceive(appState.$userState, perform: { value in
                chatShown = value == .loggedIn
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

class DemoAppFactory: ViewFactory {
    
    @Injected(\.chatClient) public var chatClient
    
    private init() {}
    
    public static let shared = DemoAppFactory()
    
    func makeChannelListHeaderViewModifier(title: String) -> some ChannelListHeaderViewModifier {
        CustomChannelModifier(title: title)
    }
}
