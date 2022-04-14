//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct PinnedMessagesView: View {
    
    @StateObject private var viewModel = PinnedMessagesViewModel()
    
    var body: some View {
        Text("Pinned messages view")
    }
}
