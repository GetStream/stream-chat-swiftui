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
    @Binding var isNewChatShown: Bool
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(title)
                .font(fonts.bodyBold)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                isNewChatShown = true
            } label: {
                Image(uiImage: images.messageActionEdit)
                    .resizable()
            }            
        }
    }

}

struct CustomChannelModifier: ChannelListHeaderViewModifier {
    
    var title: String
    
    @State var isNewChatShown = false
    
    func body(content: Content) -> some View {
        ZStack {
            content.toolbar {
                CustomChannelHeader(
                    title: title,
                    isNewChatShown: $isNewChatShown
                )
            }
            
            NavigationLink(isActive: $isNewChatShown) {
                NewChatView(isNewChatShown: $isNewChatShown)
            } label: {
                EmptyView()
            }
            .isDetailLink(false)
        }
        
    }
    
}
