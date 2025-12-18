//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct TrailingInputComposerView: View {
    @ObservedObject var viewModel: MessageComposerViewModel
    var onTap: () -> Void
    
    var body: some View {
        if viewModel.text.isEmpty {
            VoiceRecordingButton(viewModel: viewModel)
        } else {
            SendMessageButton(enabled: viewModel.sendButtonEnabled) {
                onTap()
            }
        }
    }
}
