//
//  Created by Martin Mitrevski on 22.10.21.
//  Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SwiftUI
import StreamChatSwiftUI

public struct CustomChannelHeader: ToolbarContent {
    
    @Injected(\.fonts) var fonts
    @Injected(\.images) var images
        
    public var title: String
    public var onTapLeading: () -> ()
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(title)
                .font(fonts.bodyBold)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink {
                Text("This is injected view")
            } label: {
                Image(uiImage: images.messageActionEdit)
                    .resizable()
            }
        }
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                onTapLeading()
            } label: {
                Image(systemName: "line.3.horizontal")
                    .resizable()
            }
        }
    }
}

struct CustomChannelModifier: ChannelListHeaderViewModifier {
    
    var title: String
    
    @State var profileShown = false
    
    func body(content: Content) -> some View {
        content.toolbar {
            CustomChannelHeader(title: title) {
                profileShown = true
            }
        }
        .sheet(isPresented: $profileShown) {
            Text("Profile View")
        }
    }
    
}
