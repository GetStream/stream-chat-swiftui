//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct ChatChannelInfoView: View {
    
    @StateObject private var viewModel = ChatChannelInfoViewModel()
    
    public var body: some View {
        LazyVStack {
            NavigationLink {
                PinnedMessagesView()
            } label: {
                HStack {
                    Text("Pinned Messages")
                    Spacer()
                }
                .padding()
            }
            
            Spacer()
        }
    }
}
