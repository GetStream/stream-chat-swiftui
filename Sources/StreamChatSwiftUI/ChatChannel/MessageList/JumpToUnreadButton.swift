//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct JumpToUnreadButton: View {
    
    @Injected(\.colors) var colors
    
    var unreadCount: Int
    var onTap: () -> Void
    var onClose: () -> Void
    
    var body: some View {
        HStack {
            Button {
                onTap()
            } label: {
                Text(L10n.Message.Unread.count(unreadCount))
                    .font(.caption)
            }
            Button {
                onClose()
            } label: {
                Image(systemName: "xmark")
                    .font(.caption.weight(.bold))
            }
        }
        .padding(.all, 10)
        .foregroundColor(.white)
        .background(Color(colors.textLowEmphasis))
        .cornerRadius(16)
    }
}
