//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import XCTest

class MessageReadIndicatorView_Tests: StreamChatTestCase {
    func test_messageReadIndicatorView_snapshotMessageSent() {
        // Given
        let view = MessageReadIndicatorView(
            readUsers: []
        )
        .frame(width: 50, height: 16)
     
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_messageReadIndicatorView_snapshotMessageReadDirect() {
        // Given
        let view = MessageReadIndicatorView(
            readUsers: [.mock(id: .unique)]
        )
        .frame(width: 50, height: 16)
     
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_messageReadIndicatorView_snapshotMessageReadGroup() {
        // Given
        let view = MessageReadIndicatorView(
            readUsers: [.mock(id: .unique)]
        )
        .frame(width: 50, height: 16)
     
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_messageReadIndicatorView_snapshotPendingSend() {
        // Given
        let view = MessageReadIndicatorView(
            readUsers: [],
            localState: .pendingSend
        )
        .frame(width: 50, height: 16)
     
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_messageReadIndicatorView_snapshotSending() {
        // Given
        let view = MessageReadIndicatorView(
            readUsers: [],
            localState: .sending
        )
        .frame(width: 50, height: 16)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_messageReadIndicatorView_snapshotSyncing() {
        // Given
        let view = MessageReadIndicatorView(
            readUsers: [],
            localState: .syncing
        )
        .frame(width: 50, height: 16)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_messageReadIndicatorView_snapshotSyncing_whenShowReadCount() {
        // Given
        let view = MessageReadIndicatorView(
            readUsers: [.mock(id: .unique)],
            localState: .syncing
        )
        .frame(width: 50, height: 16)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_messageReadIndicatorView_snapshotMessageFailed() {
        // Given
        let view = MessageReadIndicatorView(
            readUsers: [],
            localState: .sendingFailed
        )
        .frame(width: 50, height: 16)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_messageReadIndicatorView_snapshotMessageEditingFailed() {
        // Given
        let view = MessageReadIndicatorView(
            readUsers: [],
            localState: .syncingFailed
        )
        .frame(width: 50, height: 16)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_messageReadIndicatorView_snapshotMessageDelivered() {
        // Given
        let view = MessageReadIndicatorView(
            readUsers: [],
            showDelivered: true
        )
        .frame(width: 50, height: 16)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_messageReadIndicatorView_snapshotMessageDeliveredAndRead() {
        // Given
        let view = MessageReadIndicatorView(
            readUsers: [.mock(id: .unique), .mock(id: .unique)],
            showDelivered: true
        )
        .frame(width: 50, height: 16)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
}
