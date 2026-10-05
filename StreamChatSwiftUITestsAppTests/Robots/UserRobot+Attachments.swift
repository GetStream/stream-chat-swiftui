//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import XCTest

extension UserRobot {
    @discardableResult
    func attachImages(count: Int = 1) -> Self {
        openAttachmentPicker()
        MessageListPage.AttachmentMenu.photoOrVideoButton.wait().safeTap()
        let photos = ComposerAttachmentsPage.Picker.photos.waitCount(count)
        XCTAssertGreaterThanOrEqual(photos.count, count, "There are not enough photos in the picker")
        for index in 0..<count {
            photos.element(boundBy: index).safeTap()
        }
        ComposerAttachmentsPage.images.waitCount(count)
        return closeAttachmentPicker()
    }

    @discardableResult
    func attachFiles(count: Int = 1) -> Self {
        LocalFiles.seed()
        openAttachmentPicker()
        MessageListPage.AttachmentMenu.fileButton.wait().safeTap()
        openLocalFilesInDocumentPicker()
        for name in LocalFiles.pdfNames.prefix(count) {
            DocumentPickerPage.file(named: name).wait().safeTap()
        }
        let openButton = DocumentPickerPage.openButton
        if openButton.waitForExistence(timeout: 2) {
            openButton.safeTap()
        }
        ComposerAttachmentsPage.files.waitCount(count)
        return closeAttachmentPicker()
    }

    @discardableResult
    func tapOnSendButton() -> Self {
        composer.sendButton.wait().safeTap()
        return self
    }

    private var isAttachmentPickerOpen: Bool {
        composer.attachmentButton.wait().label == ComposerAttachmentsPage.closePickerLabel
    }

    @discardableResult
    private func openAttachmentPicker() -> Self {
        if !isAttachmentPickerOpen {
            composer.attachmentButton.wait().safeTap()
        }
        allowPhotoLibraryAccessIfAsked()
        composer.attachmentButton.waitForText(ComposerAttachmentsPage.closePickerLabel)
        return self
    }

    /// The picker opens on the photos tab, which asks for the photo library access on the first launch.
    /// The alert must be answered before anything else is tapped, otherwise XCTest dismisses it with "Don't Allow".
    private func allowPhotoLibraryAccessIfAsked() {
        let photos = ComposerAttachmentsPage.Picker.photos.firstMatch
        let accessPrompt = SpringBoard.photoAccessPopUp
        let endTime = Date().addingTimeInterval(XCUIElement.waitTimeout)
        while !photos.exists && !accessPrompt.exists && !ComposerAttachmentsPage.Picker.noAccessPrompt.exists && Date() < endTime {
            usleep(200_000)
        }
        if accessPrompt.exists {
            accessPrompt.safeTap()
        }
    }

    @discardableResult
    private func closeAttachmentPicker() -> Self {
        if isAttachmentPickerOpen {
            composer.attachmentButton.wait().safeTap()
            composer.attachmentButton.waitForText(ComposerAttachmentsPage.openPickerLabel)
        }
        return self
    }

    @discardableResult
    func assertMediaAttachmentInPreview(
        isDisplayed: Bool,
        count: Int = 1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Self {
        assertComposerAttachments(ComposerAttachmentsPage.images, isDisplayed: isDisplayed, count: count, file: file, line: line)
    }

    @discardableResult
    func assertFileAttachmentInPreview(
        isDisplayed: Bool,
        count: Int = 1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Self {
        assertComposerAttachments(ComposerAttachmentsPage.files, isDisplayed: isDisplayed, count: count, file: file, line: line)
    }

    private func assertComposerAttachments(
        _ attachments: XCUIElementQuery,
        isDisplayed: Bool,
        count: Int,
        file: StaticString,
        line: UInt
    ) -> Self {
        if isDisplayed {
            XCTAssertEqual(count, attachments.waitCount(count).count, "Wrong number of attachments in composer", file: file, line: line)
            XCTAssertEqual(count, ComposerAttachmentsPage.removeButtons.count, "Wrong number of remove buttons in composer", file: file, line: line)
        } else {
            XCTAssertFalse(attachments.firstMatch.waitForDisappearance().exists, "Attachments are displayed in composer", file: file, line: line)
            XCTAssertEqual(0, ComposerAttachmentsPage.removeButtons.count, "Remove buttons are displayed in composer", file: file, line: line)
        }
        return self
    }

    @discardableResult
    func assertImages(
        isDisplayed: Bool,
        count: Int = 1,
        at messageCellIndex: Int? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Self {
        let messageCell = messageCell(withIndex: messageCellIndex, file: file, line: line)
        let images = messageCell.images.matching(identifier: "MessageMediaAttachmentsContainerView")
        if isDisplayed {
            XCTAssertEqual(count, images.waitCount(count).count, "Wrong number of images", file: file, line: line)
            let preloader = attributes.imagePreloader(in: messageCell).waitForDisappearance()
            XCTAssertFalse(preloader.exists, "Image uploading has not finished", file: file, line: line)
        } else {
            XCTAssertFalse(images.firstMatch.waitForDisappearance().exists, "Images are displayed", file: file, line: line)
        }
        return self
    }

    /// The document picker reopens the last visited location, so it may already show the local files.
    private func openLocalFilesInDocumentPicker() {
        let firstFile = DocumentPickerPage.file(named: LocalFiles.pdfNames[0])
        if firstFile.waitForExistence(timeout: 5) { return }
        if DocumentPickerPage.browseTab.exists {
            DocumentPickerPage.browseTab.safeTap()
            if firstFile.waitForExistence(timeout: 3) { return }
        }
        DocumentPickerPage.onMyDeviceLocation.wait().safeTap()
    }

    /// Opens the image at the given position (from the left) of the message in the full-screen gallery.
    @discardableResult
    func openImageInGallery(imageIndex: Int = 0, messageCellIndex: Int? = nil) -> Self {
        let messageCell = messageCell(withIndex: messageCellIndex)
        let images = messageCell.buttons.matching(identifier: "MessageMediaAttachmentsContainerView").waitCount(imageIndex + 1).allElementsBoundByIndex
        let sortedImages = images.sorted { $0.frame.minX < $1.frame.minX }
        sortedImages[imageIndex].waitForHitPoint().safeTap()
        return self
    }

    @discardableResult
    func swipeToNextImageInGallery() -> Self {
        app.swipeLeft()
        return self
    }

    @discardableResult
    func assertGalleryPosition(
        _ position: Int,
        of count: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Self {
        let expected = "\(position) of \(count)"
        let counter = app.staticTexts.matching(NSPredicate(format: "label MATCHES %@", "[0-9]+ of [0-9]+")).firstMatch
        XCTAssertEqual(expected, counter.wait().waitForText(expected).text, file: file, line: line)
        return self
    }
}
