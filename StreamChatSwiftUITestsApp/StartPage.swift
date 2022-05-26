//
//  StartPage.swift
//  StreamChatSwiftUITestsApp
//
//  Created by Boris Bielik on 26/05/2022.
//

import SwiftUI
import StreamChatSwiftUI

struct StartPage: View {
    
    var body: some View {
        NavigationView {
            NavigationLink("Start Chat",
                           destination:
                            ChatChannelListView()
                            .navigationBarHidden(true)
            )
            .accessibilityIdentifier("TestApp.Start")
            .navigationTitle("Test UI App")
            .navigationBarHidden(true)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct StartPage_Previews: PreviewProvider {
    static var previews: some View {
        StartPage()
    }
}
