//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Prompt view displayed when the poll tab is selected,
/// allowing the user to create a poll.
struct PollCreatePromptView: View {
    @Injected(\.images) private var images

    @State private var showsCreatePoll = false

    let channelController: ChatChannelController
    let messageController: ChatMessageController?

    var body: some View {
        AttachmentPickerPromptView(
            image: Image(uiImage: images.attachmentPickerPollIcon),
            description: L10n.Composer.Polls.createPollDescription,
            buttonText: L10n.Composer.Polls.createPoll,
            onTap: {
                showsCreatePoll = true
            }
        )
        .fullScreenCover(isPresented: $showsCreatePoll) {
            CreatePollView(
                chatController: channelController,
                messageController: messageController
            )
        }
    }
}
