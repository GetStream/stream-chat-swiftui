//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class SearchResultsView_Tests: StreamChatTestCase {

    func test_searchResultsView_snapshotResults() {
        // Given
        let channel1 = ChatChannel.mock(cid: .unique, name: "Test 1")
        let message1 = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Test 1",
            author: .mock(id: .unique)
        )
        let result1 = ChannelSelectionInfo(
            channel: channel1,
            message: message1
        )
        let channel2 = ChatChannel.mock(cid: .unique, name: "Test 2")
        let message2 = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Test 2",
            author: .mock(id: .unique)
        )
        let result2 = ChannelSelectionInfo(
            channel: channel2,
            message: message2
        )
        let searchResults = [result1, result2]

        // When
        let view = SearchResultsView(
            factory: DefaultViewFactory.shared,
            selectedChannel: .constant(nil),
            searchResults: searchResults,
            loadingSearchResults: false,
            onlineIndicatorShown: { _ in false },
            channelNaming: { $0.name ?? "" },
            imageLoader: { _ in UIImage(systemName: "person.circle")! },
            onSearchResultTap: { _ in },
            onItemAppear: { _ in }
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image)
    }

    func test_searchResultsView_snapshotResults_whenChannelSearch() {
        // Given
        let channel1 = ChatChannel.mock(cid: .unique, name: "Test 1")
        let message1 = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Test 1",
            author: .mock(id: .unique, name: "Luke")
        )
        let result1 = ChannelSelectionInfo(
            channel: channel1,
            message: message1,
            searchType: .channels
        )
        let channel2 = ChatChannel.mock(cid: .unique, name: "Test 2")
        let message2 = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Test 2",
            author: .mock(id: .unique, name: "Han Solo")
        )
        let result2 = ChannelSelectionInfo(
            channel: channel2,
            message: message2,
            searchType: .channels
        )
        let searchResults = [result1, result2]

        // When
        let view = SearchResultsView(
            factory: DefaultViewFactory.shared,
            selectedChannel: .constant(nil),
            searchResults: searchResults,
            loadingSearchResults: false,
            onlineIndicatorShown: { _ in false },
            channelNaming: { $0.name ?? "" },
            imageLoader: { _ in UIImage(systemName: "person.circle")! },
            onSearchResultTap: { _ in },
            onItemAppear: { _ in }
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image)
    }

    func test_searchResultsView_snapshotNoResults() {
        // Given
        let searchResults = [ChannelSelectionInfo]()

        // When
        let view = SearchResultsView(
            factory: DefaultViewFactory.shared,
            selectedChannel: .constant(nil),
            searchResults: searchResults,
            loadingSearchResults: false,
            onlineIndicatorShown: { _ in false },
            channelNaming: { $0.name ?? "" },
            imageLoader: { _ in UIImage(systemName: "person.circle")! },
            onSearchResultTap: { _ in },
            onItemAppear: { _ in }
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image)
    }

    func test_searchResultsView_snapshotLoading() {
        // Given
        let searchResults = [ChannelSelectionInfo]()

        // When
        let view = SearchResultsView(
            factory: DefaultViewFactory.shared,
            selectedChannel: .constant(nil),
            searchResults: searchResults,
            loadingSearchResults: true,
            onlineIndicatorShown: { _ in false },
            channelNaming: { $0.name ?? "" },
            imageLoader: { _ in UIImage(systemName: "person.circle")! },
            onSearchResultTap: { _ in },
            onItemAppear: { _ in }
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image)
    }
}
