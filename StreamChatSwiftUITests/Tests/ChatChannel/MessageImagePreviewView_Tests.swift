//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor class MessageImagePreviewView_Tests: StreamChatTestCase {
    private let containerSize = CGSize(width: 80, height: 80)

    // MARK: - Snapshot

    func test_messageImagePreviewView_defaultSize() {
        // Given
        let view = containerView {
            MessageImagePreviewView(url: .localYodaImage)
        }

        // Then
        AssertSnapshot(view, variants: [.defaultLight], size: containerSize)
    }

    func test_messageImagePreviewView_customSize() {
        // Given
        let customSize: CGFloat = 60
        let container = CGSize(width: customSize + 20, height: customSize + 20)
        let view = containerView(size: container) {
            MessageImagePreviewView(url: .localYodaImage, size: customSize)
        }

        // Then
        AssertSnapshot(view, variants: [.defaultLight], size: container)
    }

    // MARK: - Image Loading

    func test_messageImagePreviewView_loadsImage() {
        // Given
        let imageLoader = streamChat?.utils.imageLoader as? ImageLoader_Mock
        let view = MessageImagePreviewView(url: .localYodaImage)

        // When
        showView(view)

        let expectation = expectation(description: "Image loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)

        // Then
        XCTAssertEqual(imageLoader?.loadImageCalled, true)
    }

    // MARK: - Helpers

    private var testWindow: UIWindow?

    @discardableResult
    private func showView<V: View>(_ view: V) -> UIHostingController<V> {
        let hostingController = UIHostingController(rootView: view)
        let window = UIWindow(frame: CGRect(origin: .zero, size: CGSize(width: 200, height: 200)))
        window.rootViewController = hostingController
        window.makeKeyAndVisible()
        testWindow = window
        hostingController.view.layoutIfNeeded()
        return hostingController
    }

    override func tearDown() {
        testWindow?.isHidden = true
        testWindow = nil
        super.tearDown()
    }

    private func containerView<Content: View>(
        size: CGSize? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        let size = size ?? containerSize
        return ZStack {
            Color(UIColor.systemBackground)
            content()
        }
        .frame(width: size.width, height: size.height)
    }
}
