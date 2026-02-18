//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

/// Demo app commands container: when GIF grid is enabled and user selected Giphy, shows horizontally scrollable GIF grid; otherwise default commands (mentions, instant commands).
struct DemoAppCommandsContainerView<Factory: ViewFactory>: View {
    @EnvironmentObject private var viewModel: MessageComposerViewModel
    @State private var isSubmitting = false

    var factory: Factory
    var suggestions: [String: Any]
    var handleCommand: ([String: Any]) -> Void

    var body: some View {
        ZStack {
            if AppConfiguration.default.isGiphyGridEnabled,
               viewModel.composerCommand?.id == "/giphy" {
                GiphyGridView(
                    searchQuery: $viewModel.text,
                    isSelectionDisabled: isSubmitting,
                    onSelect: { item in
                        addGiphyAndDismiss(item: item)
                    }
                )
                .accessibilityIdentifier("GiphyGridView")
            } else {
                CommandsContainerView(
                    factory: factory,
                    suggestions: suggestions,
                    handleCommand: handleCommand
                )
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func addGiphyAndDismiss(item: GiphyService.GiphyItem) {
        guard !isSubmitting else { return }
        guard let url = item.fullURL ?? item.previewURL else { return }
        isSubmitting = true
        let payload = CustomGiphyAttachmentPayload(
            title: item.title ?? "GIF",
            previewURL: url
        )
        let anyPayload = AnyAttachmentPayload(payload: payload)
        let custom = CustomAttachment(id: item.id, content: anyPayload)
        viewModel.addedCustomAttachments.append(custom)
        viewModel.composerCommand = nil
        viewModel.text = ""

        viewModel.sendMessage(
            quotedMessage: viewModel.quotedMessage?.wrappedValue,
            editedMessage: nil
        ) {
            viewModel.quotedMessage?.wrappedValue = nil
            isSubmitting = false
        } onError: { _ in
            isSubmitting = false
        }
    }
}
