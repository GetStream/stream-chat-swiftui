//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor class EditGroupView_Tests: StreamChatTestCase {
    // MARK: - EditGroupView snapshots

    func test_editGroupView_snapshot() {
        // Given
        let viewModel = mockGroupViewModel()

        // When
        let view = EditGroupView(factory: DefaultTestViewFactory.shared, viewModel: viewModel)
            .applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }

    func test_editGroupView_uploadingSnapshot() {
        // Given
        let viewModel = mockGroupViewModel()
        viewModel.isUploadingGroupAvatar = true

        // When
        let view = EditGroupView(factory: DefaultTestViewFactory.shared, viewModel: viewModel)
            .applyDefaultSize()

        // Then
        AssertSnapshot(view, variants: [.smallDark])
    }

    func test_editGroupView_filledNameRightToLeft_snapshot() {
        // Given
        let viewModel = mockGroupViewModel(name: "فريق التصميم")

        // When
        let view = EditGroupView(factory: DefaultTestViewFactory.shared, viewModel: viewModel)
            .applyDefaultSize()

        // Then
        AssertSnapshot(view, variants: [.rightToLeftLayout])
    }

    // MARK: - GroupAvatarPickerSheetView snapshots

    func test_groupAvatarPickerSheetView_snapshot() {
        // Given
        let view = GroupAvatarPickerSheetView(
            onCamera: {},
            onLibrary: {},
            onReset: {},
            onDismiss: {}
        )
        .applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }

    // MARK: - GroupAvatarPickerSheetView callbacks

    func test_groupAvatarPickerSheetView_onCamera_isCalled() {
        // Given
        var cameraTapped = false
        let view = GroupAvatarPickerSheetView(
            onCamera: { cameraTapped = true },
            onLibrary: {},
            onReset: {},
            onDismiss: {}
        )

        // When
        view.onCamera()

        // Then
        XCTAssertTrue(cameraTapped)
    }

    func test_groupAvatarPickerSheetView_onLibrary_isCalled() {
        // Given
        var libraryTapped = false
        let view = GroupAvatarPickerSheetView(
            onCamera: {},
            onLibrary: { libraryTapped = true },
            onReset: {},
            onDismiss: {}
        )

        // When
        view.onLibrary()

        // Then
        XCTAssertTrue(libraryTapped)
    }

    func test_groupAvatarPickerSheetView_onReset_isCalled() {
        // Given
        var resetTapped = false
        let view = GroupAvatarPickerSheetView(
            onCamera: {},
            onLibrary: {},
            onReset: { resetTapped = true },
            onDismiss: {}
        )

        // When
        view.onReset()

        // Then
        XCTAssertTrue(resetTapped)
    }

    func test_groupAvatarPickerSheetView_onDismiss_isCalled() {
        // Given
        var dismissed = false
        let view = GroupAvatarPickerSheetView(
            onCamera: {},
            onLibrary: {},
            onReset: {},
            onDismiss: { dismissed = true }
        )

        // When
        view.onDismiss()

        // Then
        XCTAssertTrue(dismissed)
    }

    // MARK: - saveGroupEdit with reset (nil image)

    func test_chatChannelInfoVM_saveGroupEdit_withNilImage_closesSheet() {
        // Given
        let viewModel = mockGroupViewModel()
        viewModel.editGroupShown = true

        // When - reset means passing nil image
        viewModel.saveGroupEdit(name: viewModel.channelName, image: nil)

        // Then
        XCTAssertFalse(viewModel.editGroupShown)
        XCTAssertFalse(viewModel.isUploadingGroupAvatar)
    }

    func test_chatChannelInfoVM_saveGroupEdit_nameUpdated() {
        // Given
        let viewModel = mockGroupViewModel()
        let newName = "Updated Group Name"

        // When
        viewModel.saveGroupEdit(name: newName, image: nil)

        // Then
        XCTAssertEqual(viewModel.channelName, newName)
    }

    // MARK: - L10n keys

    func test_groupAvatarPickerSheet_l10nKeys() {
        XCTAssertFalse(L10n.ChatInfo.Edit.Picture.title.isEmpty)
        XCTAssertFalse(L10n.ChatInfo.Edit.Picture.camera.isEmpty)
        XCTAssertFalse(L10n.ChatInfo.Edit.Picture.library.isEmpty)
        XCTAssertFalse(L10n.ChatInfo.Edit.Picture.reset.isEmpty)
    }

    // MARK: - Helpers

    private func mockGroupViewModel(name: String = "Test Group") -> ChatChannelInfoViewModel {
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 4,
            currentUserId: chatClient.currentUserId!
        )
        let group = ChatChannel.mock(
            cid: .unique,
            name: name,
            ownCapabilities: [.updateChannel],
            lastActiveMembers: members,
            memberCount: members.count
        )
        return ChatChannelInfoViewModel(channel: group)
    }
}
