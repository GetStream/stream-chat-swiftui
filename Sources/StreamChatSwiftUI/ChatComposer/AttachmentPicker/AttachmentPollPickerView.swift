//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the poll attachment picker.
/// Shows a prompt to create a poll, and presents the poll
/// creation view in a sheet.
struct AttachmentPollPickerView: View {
    @State private var showsCreatePoll = false

    let channelController: ChatChannelController
    let messageController: ChatMessageController?

    var body: some View {
        PollCreatePromptView(onTap: {
            showsCreatePoll = true
        })
        .sheet(isPresented: $showsCreatePoll) {
            CreatePollView(
                chatController: channelController,
                messageController: messageController
            )
        }
        .onLoad {
            showsCreatePoll = true
        }
    }
}

// MARK: - Prompt View

/// Prompt view displayed when the poll tab is selected.
public struct PollCreatePromptView: View {
    @Injected(\.images) private var images

    var onTap: @MainActor () -> Void

    public init(onTap: @escaping @MainActor () -> Void) {
        self.onTap = onTap
    }

    public var body: some View {
        AttachmentPickerPromptView(
            image: Image(uiImage: images.attachmentPollIcon),
            description: L10n.Composer.Polls.createPollDescription,
            buttonText: L10n.Composer.Polls.createPoll,
            onTap: onTap
        )
    }
}
