//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

struct ChooseChannelQueryView: View {
    static let queryIdentifiers = ChannelListQueryIdentifier.allCases.sorted(using: KeyPathComparator(\.title))
    
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
