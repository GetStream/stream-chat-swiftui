//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import XCTest

final class ChannelAvatarsMergerTests: StreamChatTestCase {
    private var merger: ChannelAvatarsMerger!
    
    override func setUp() {
        super.setUp()
        merger = ChannelAvatarsMerger()
    }
    
    override func tearDown() {
        super.tearDown()
        merger = nil
    }
    
    func testConcurrentCalls() {
        let sourceImages: [UIImage] = [
            XCTestCase.TestImages.chewbacca.image,
            XCTestCase.TestImages.r2.image,
            XCTestCase.TestImages.vader.image,
            XCTestCase.TestImages.yoda.image
        ]
        DispatchQueue.concurrentPerform(iterations: 100) { _ in
            let images = Array(sourceImages.prefix((1...4).randomElement()!))
            let mergedImage = merger.createMergedAvatar(from: images)
            XCTAssertNotNil(mergedImage)
        }
    }
}
