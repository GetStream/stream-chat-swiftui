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
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(title)
                .font(fonts.bodyBold)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink {
                NewChatView()
            } label: {
                Image(uiImage: images.messageActionEdit)
                    .resizable()
            }
        }
    }

}

struct CustomChannelModifier: ChannelListHeaderViewModifier {
    
    var title: String
    
    func body(content: Content) -> some View {
        content.toolbar {
            CustomChannelHeader(title: title)
        }
    }
    
}
