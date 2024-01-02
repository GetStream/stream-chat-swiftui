//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

final class AudioRecordingNameFormatter_Tests: XCTestCase {

    func test_audioRecordingNameFormatter_index0() {
        // Given
        let formatter: AudioRecordingNameFormatter = DefaultAudioRecordingNameFormatter()
        
        // When
        let title = formatter.title(forItemAtURL: .localYodaImage, index: 0)
        
        // Then
        XCTAssert(title == "Recording")
    }
    
    func test_audioRecordingNameFormatter_index1() {
        // Given
        let formatter: AudioRecordingNameFormatter = DefaultAudioRecordingNameFormatter()
        
        // When
        let title = formatter.title(forItemAtURL: .localYodaImage, index: 1)
        
        // Then
        XCTAssert(title == "Recording(1)")
    }
}
