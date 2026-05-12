//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor final class GiphyAttachmentView_Tests: StreamChatTestCase {
    // MARK: - Accessibility Label

    func test_giphyAccessibilityLabel_whenTitleIsPresent_includesTitle() {
        let view = makeView(giphyTitle: "happy cat")

        XCTAssertEqual(view.giphyAccessibilityLabel, "Giphy, happy cat")
    }

    func test_giphyAccessibilityLabel_whenTitleIsNil_isJustGiphy() {
        let view = makeView(giphyTitle: nil)

        XCTAssertEqual(view.giphyAccessibilityLabel, "Giphy")
    }

    func test_giphyAccessibilityLabel_whenTitleIsEmpty_isJustGiphy() {
        let view = makeView(giphyTitle: "")

        XCTAssertEqual(view.giphyAccessibilityLabel, "Giphy")
    }

    func test_giphyAccessibilityLabel_whenTitleIsWhitespaceOnly_isJustGiphy() {
        let view = makeView(giphyTitle: "   \n\t  ")

        XCTAssertEqual(view.giphyAccessibilityLabel, "Giphy")
    }

    func test_giphyAccessibilityLabel_whenTitleHasSurroundingWhitespace_isTrimmed() {
        let view = makeView(giphyTitle: "  happy cat  ")

        XCTAssertEqual(view.giphyAccessibilityLabel, "Giphy, happy cat")
    }

    // MARK: - Helpers

    private func makeView(
        giphyTitle: String?
    ) -> GiphyAttachmentView<DefaultViewFactory> {
        let attachment = ChatMessageGiphyAttachment(
            id: .unique,
            type: .giphy,
            payload: GiphyAttachmentPayload(
                title: giphyTitle,
                previewURL: ChatChannelTestHelpers.testURL,
                actions: []
            ),
            downloadingState: nil,
            uploadingState: nil
        )
        .asAnyAttachment

        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: .unique),
            attachments: [attachment]
        )

        return GiphyAttachmentView(
            factory: DefaultViewFactory.shared,
            message: message,
            width: 300,
            isFirst: true,
            scrolledId: .constant(nil)
        )
    }
}
