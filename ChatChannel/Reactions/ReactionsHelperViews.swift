//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct ReactionsHStack<Content: View>: View {
    var message: ChatMessage
    var content: () -> Content
    
    var body: some View {
        HStack {
            if !message.isSentByCurrentUser {
                Spacer()
            }
            
            content()
            
            if message.isSentByCurrentUser {
                Spacer()
            }
        }
    }
}
