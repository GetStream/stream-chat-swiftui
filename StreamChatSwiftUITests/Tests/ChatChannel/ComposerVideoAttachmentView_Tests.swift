//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor class ComposerVideoAttachmentView_Tests: StreamChatTestCase {
    private let containerSize = CGSize(width: 100, height: 100)

    func test_composerVideoAttachmentView_durationFromProperty() {
        let asset = AddedAsset(
            image: TestImages.yoda.image,
            id: .unique,
            url: TestImages.yoda.url,
            type: .video,
            duration: 45
        )

        let view = containerView {
            ComposerVideoAttachmentView(
                attachment: asset,
                onDiscardAttachment: { _ in }
            )
        }

        AssertSnapshot(view, variants: [.defaultLight], size: containerSize)
    }

    func test_composerVideoAttachmentView_durationFromExtraData() {
        let asset = AddedAsset(
            image: TestImages.yoda.image,
            id: .unique,
            url: TestImages.yoda.url,
            type: .video,
            extraData: ["duration": .number(120)]
        )

        let view = containerView {
            ComposerVideoAttachmentView(
                attachment: asset,
                onDiscardAttachment: { _ in }
            )
        }

        AssertSnapshot(view, variants: [.defaultLight], size: containerSize)
    }

    func test_composerVideoAttachmentView_durationPropertyTakesPrecedence() {
        let asset = AddedAsset(
            image: TestImages.yoda.image,
            id: .unique,
            url: TestImages.yoda.url,
            type: .video,
            extraData: ["duration": .number(120)],
            duration: 8
        )

        let view = containerView {
            ComposerVideoAttachmentView(
                attachment: asset,
                onDiscardAttachment: { _ in }
            )
        }

        AssertSnapshot(view, variants: [.defaultLight], size: containerSize)
    }

    func test_composerVideoAttachmentView_noDuration() {
        let asset = AddedAsset(
            image: TestImages.yoda.image,
            id: .unique,
            url: TestImages.yoda.url,
            type: .video
        )

        let view = containerView {
            ComposerVideoAttachmentView(
                attachment: asset,
                onDiscardAttachment: { _ in }
            )
        }

        AssertSnapshot(view, variants: [.defaultLight], size: containerSize)
    }

    // MARK: - Helper

    private func containerView<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ZStack {
            Color(UIColor.systemBackground)
            content()
        }
        .frame(width: containerSize.width, height: containerSize.height)
    }
}
