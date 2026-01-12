//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

struct ChooseChannelQueryView: View {
    static var queryIdentifiers: [ChannelListQueryIdentifier] {
        ChannelListQueryIdentifier.allCases.sorted(by: { $0.title < $1.title })
    }
    
    var body: some View {
        ForEach(Self.queryIdentifiers) { queryIdentifier in
            Button {
                AppState.shared.setChannelQueryIdentifier(queryIdentifier)
            } label: {
                Text(queryIdentifier.title)
            }
        }
    }
}
