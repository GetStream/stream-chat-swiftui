//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import XCTest

// MARK: Actions

extension UserRobot {
    @discardableResult
    func swipeChannel(channelCellIndex: Int = 0) -> Self {
        waitForChannelListToLoad()
        ChannelListPage.cells.element(boundBy: channelCellIndex).waitForHitPoint().swipeLeft()
        return self
    }

    @discardableResult
    func tapOnMoreSwipeAction() -> Self {
        ChannelActionsPage.SwipeActions.more.wait().safeTap()
        return self
    }

    @discardableResult
    func tapOnMuteSwipeAction() -> Self {
        ChannelActionsPage.SwipeActions.mute.wait().safeTap()
        ChannelActionsPage.MuteAlert.mute.wait().safeTap()
        return self
    }

    @discardableResult
    func tapOnUnmuteSwipeAction() -> Self {
        ChannelActionsPage.SwipeActions.unmute.wait().safeTap()
        ChannelActionsPage.MuteAlert.unmute.wait().safeTap()
        return self
    }

    @discardableResult
    func tapOnViewChannelInfo() -> Self {
        ChannelActionsPage.Sheet.viewInfo.wait().safeTap()
        return self
    }

    @discardableResult
    func tapOnDeleteGroup() -> Self {
        ChannelActionsPage.Sheet.deleteGroup.wait().safeTap()
        ChannelActionsPage.Sheet.confirmDelete.wait().safeTap()
        return self
    }

    @discardableResult
    func tapOnLeaveGroupInChannelInfo() -> Self {
        let leaveButton = ChannelActionsPage.ChannelInfo.leaveGroup.wait()
        if !leaveButton.isHittable {
            app.swipeUp()
        }
        leaveButton.waitForHitPoint().safeTap()
        ChannelActionsPage.ChannelInfo.confirmLeave.wait().safeTap()
        return self
    }
}

// MARK: Asserts

extension UserRobot {
    @discardableResult
    func assertChannelActionsSheetForGroupChannel(file: StaticString = #filePath, line: UInt = #line) -> Self {
        let sheet = ChannelActionsPage.Sheet.self
        XCTAssertTrue(sheet.viewInfo.wait().exists, "View info option is not shown", file: file, line: line)
        XCTAssertTrue(sheet.muteChannel.exists, "Mute channel option is not shown", file: file, line: line)
        XCTAssertTrue(sheet.deleteGroup.exists, "Delete group option is not shown", file: file, line: line)
        return self
    }

    @discardableResult
    func assertGroupChannelInfoScreen(channelName: String, file: StaticString = #filePath, line: UInt = #line) -> Self {
        let info = ChannelActionsPage.ChannelInfo.self
        XCTAssertTrue(info.title.wait().exists, "Group info title is not shown", file: file, line: line)
        XCTAssertTrue(info.channelName(channelName).exists, "Channel name is not shown", file: file, line: line)
        XCTAssertTrue(info.pinnedMessagesOption.exists, "Pinned messages option is not shown", file: file, line: line)
        return self
    }

    @discardableResult
    func assertChannelListIsEmpty(file: StaticString = #filePath, line: UInt = #line) -> Self {
        XCTAssertTrue(
            ChannelActionsPage.emptyChannelsView.wait(timeout: XCUIElement.longWaitTimeout).exists,
            "Empty channel list placeholder is not shown",
            file: file,
            line: line
        )
        XCTAssertEqual(ChannelListPage.cells.count, 0, "Channel list is not empty", file: file, line: line)
        return self
    }

    @discardableResult
    func assertChannelIsMuted(
        _ isMuted: Bool,
        at cellIndex: Int = 0,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Self {
        let mutedIcon = ChannelActionsPage.mutedIcon(in: ChannelListPage.cells.element(boundBy: cellIndex))
        if isMuted {
            XCTAssertTrue(mutedIcon.wait().exists, "Muted icon is not shown", file: file, line: line)
        } else {
            XCTAssertFalse(mutedIcon.waitForDisappearance().exists, "Muted icon is shown", file: file, line: line)
        }
        return self
    }
}
