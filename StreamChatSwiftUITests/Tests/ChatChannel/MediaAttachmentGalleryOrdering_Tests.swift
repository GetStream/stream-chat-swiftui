//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import XCTest

final class MediaAttachmentGalleryOrdering_Tests: XCTestCase {
    func test_galleryOrderedMediaAttachments_preservesMessageAttachmentOrder_imageThenVideo() {
        let image = ChatChannelTestHelpers.imageAttachments[0]
        let video = ChatChannelTestHelpers.videoAttachments[0]
        let message = ChatMessage.mock(attachments: [image, video])

        let ordered = MediaAttachment.galleryOrdered(from: message)

        XCTAssertEqual(ordered.count, 2)
        XCTAssertEqual(ordered[0].type.rawValue, MediaAttachmentType.image.rawValue)
        XCTAssertEqual(ordered[1].type.rawValue, MediaAttachmentType.video.rawValue)
    }

    func test_galleryOrderedMediaAttachments_preservesMessageAttachmentOrder_videoThenImage() {
        let image = ChatChannelTestHelpers.imageAttachments[0]
        let video = ChatChannelTestHelpers.videoAttachments[0]
        let message = ChatMessage.mock(attachments: [video, image])

        let ordered = MediaAttachment.galleryOrdered(from: message)

        XCTAssertEqual(ordered.count, 2)
        XCTAssertEqual(ordered[0].type.rawValue, MediaAttachmentType.video.rawValue)
        XCTAssertEqual(ordered[1].type.rawValue, MediaAttachmentType.image.rawValue)
    }
}
