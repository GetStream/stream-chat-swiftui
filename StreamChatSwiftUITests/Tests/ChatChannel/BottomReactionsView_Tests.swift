//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

final class BottomReactionsView_Tests: StreamChatTestCase {

    func test_bottomReactions_singleRow_otherUser() {
        // Given
        let reactionScores: [MessageReactionType: Int] = [
            .init(rawValue: "like"): 2,
            .init(rawValue: "love"): 1
        ]
        let message = ChatMessage.mock(reactionScores: reactionScores)
        
        // When
        let view = BottomReactionsView(
            message: message,
            showsAllInfo: true,
            onTap: {},
            onLongPress: {}
        )
        .padding()
        .frame(width: 200)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: 0.95))
    }
    
    func test_bottomReactions_singleRow_currentUser() {
        // Given
        let reactionScores: [MessageReactionType: Int] = [
            .init(rawValue: "like"): 2,
            .init(rawValue: "love"): 1
        ]
        let message = ChatMessage.mock(
            reactionScores: reactionScores,
            isSentByCurrentUser: true
        )
        
        // When
        let view = BottomReactionsView(
            message: message,
            showsAllInfo: true,
            onTap: {},
            onLongPress: {}
        )
        .padding()
        .frame(width: 200)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: 0.95))
    }
    
    func test_bottomReactions_singleRow_currentUserReaction() {
        // Given
        let reactionScores: [MessageReactionType: Int] = [
            .init(rawValue: "like"): 2,
            .init(rawValue: "love"): 1
        ]
        let message = ChatMessage.mock(
            reactionScores: reactionScores,
            currentUserReactions: [.mock(type: .init(rawValue: "like"))]
        )
        
        // When
        let view = BottomReactionsView(
            message: message,
            showsAllInfo: true,
            onTap: {},
            onLongPress: {}
        )
        .padding()
        .frame(width: 200)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: 0.95))
    }
    
    func test_bottomReactions_multipleRows_currentUserReaction() {
        // Given
        let reactionScores: [MessageReactionType: Int] = [
            .init(rawValue: "like"): 2,
            .init(rawValue: "love"): 1,
            .init(rawValue: "haha"): 1,
            .init(rawValue: "sad"): 1,
            .init(rawValue: "wow"): 10
        ]
        let message = ChatMessage.mock(
            reactionScores: reactionScores,
            currentUserReactions: [.mock(type: .init(rawValue: "like"))]
        )
        
        // When
        let view = BottomReactionsView(
            message: message,
            showsAllInfo: true,
            onTap: {},
            onLongPress: {}
        )
        .padding()
        .frame(width: 300)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: 0.95))
    }
    
    func test_bottomReactions_multipleRows_twoPerRow() {
        // Given
        let reactionScores: [MessageReactionType: Int] = [
            .init(rawValue: "like"): 2,
            .init(rawValue: "love"): 1,
            .init(rawValue: "haha"): 1,
            .init(rawValue: "sad"): 1,
            .init(rawValue: "wow"): 10
        ]
        let message = ChatMessage.mock(
            reactionScores: reactionScores,
            currentUserReactions: [.mock(type: .init(rawValue: "like"))]
        )
        
        // When
        let view = BottomReactionsView(
            message: message,
            showsAllInfo: true,
            reactionsPerRow: 2,
            onTap: {},
            onLongPress: {}
        )
        .padding()
        .frame(width: 200)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: 0.95))
    }
    
    func test_bottomReactions_multipleRows_buttonNewRow() {
        // Given
        let reactionScores: [MessageReactionType: Int] = [
            .init(rawValue: "like"): 2,
            .init(rawValue: "love"): 1,
            .init(rawValue: "haha"): 1,
            .init(rawValue: "sad"): 1
        ]
        let message = ChatMessage.mock(
            reactionScores: reactionScores,
            currentUserReactions: [.mock(type: .init(rawValue: "like"))]
        )
        
        // When
        let view = BottomReactionsView(
            message: message,
            showsAllInfo: true,
            reactionsPerRow: 2,
            onTap: {},
            onLongPress: {}
        )
        .padding()
        .frame(width: 200)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: 0.95))
    }
}
