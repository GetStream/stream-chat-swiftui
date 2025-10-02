//
// Copyright © 2025 Stream.io Inc. All rights reserved.
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
    
    @MainActor func testConcurrentCalls() {
        let sourceImages: [UIImage] = [
            XCTestCase.TestImages.chewbacca.image,
            XCTestCase.TestImages.r2.image,
            XCTestCase.TestImages.vader.image,
            XCTestCase.TestImages.yoda.image
        ]
        let options = ChannelAvatarsMergerOptions()
        DispatchQueue.concurrentPerform(iterations: 100) { [merger] _ in
            let images = Array(sourceImages.prefix((1...4).randomElement()!))
            let mergedImage = merger?.createMergedAvatar(
                from: images,
                options: options
            )
            XCTAssertNotNil(mergedImage)
        }
    }
}
