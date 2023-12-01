//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

//TODO: improve this
struct JumpToUnreadButton: View {
    
    var unreadCount: Int
    var onTap: () -> ()
    var onClose: () -> ()
    
    var body: some View {
        HStack {
            Button {
                onTap()
            } label: {
                Text("\(unreadCount) unread ")
                    .font(.caption)
            }
            Button {
                onClose()
            } label: {
                Image(systemName: "xmark")
            }
        }
        .padding()
        .foregroundColor(.white)
        .background(Color.gray)
        .cornerRadius(16)
    }
}
