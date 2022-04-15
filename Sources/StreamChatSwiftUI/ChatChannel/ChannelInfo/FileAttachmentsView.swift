//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct FileAttachmentsView: View {
    
    @StateObject private var viewModel: FileAttachmentsViewModel
    
    init(channel: ChatChannel) {
        _viewModel = StateObject(
            wrappedValue: FileAttachmentsViewModel(channel: channel)
        )
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}
