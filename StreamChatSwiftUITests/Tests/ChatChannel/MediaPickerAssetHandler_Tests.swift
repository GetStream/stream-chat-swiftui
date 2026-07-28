//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import AVFoundation
import Photos
@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

@MainActor
final class MediaPickerAssetHandler_Tests: StreamChatTestCase {
    // MARK: - Appear

    func test_onAppear_loadsThumbnailWithExpectedTargetSize() {
        // Given
        let assetLoader = PhotoAssetLoader_Mock()
        let asset = PHAsset_Mock()
        let handler = MediaPickerAssetHandler(asset: asset, assetLoader: assetLoader)

        // When
        handler.onAppear()

        // Then
        XCTAssertEqual(assetLoader.loadImageCalls.count, 1)
        XCTAssertTrue(assetLoader.loadImageCalls.first?.asset === asset)
        XCTAssertEqual(assetLoader.loadImageCalls.first?.targetSize, CGSize(width: 250, height: 250))
    }

    func test_onAppear_withImageAsset_requestsContentEditingInputWithoutNetworkAccess() {
        // Given
        let asset = PHAsset_Mock(mediaType: .image)
        let handler = MediaPickerAssetHandler(asset: asset, assetLoader: PhotoAssetLoader_Mock())

        // When
        handler.onAppear()

        // Then
        XCTAssertEqual(asset.contentEditingInputRequests.count, 1)
        XCTAssertEqual(asset.contentEditingInputRequests.first?.isNetworkAccessAllowed, false)
    }

    func test_onAppear_withVideoAsset_doesNotRequestContentEditingInput() {
        // Given
        let asset = PHAsset_Mock(mediaType: .video, duration: 12)
        let assetLoader = PhotoAssetLoader_Mock()
        let handler = MediaPickerAssetHandler(asset: asset, assetLoader: assetLoader)

        // When
        handler.onAppear()

        // Then
        XCTAssertTrue(asset.contentEditingInputRequests.isEmpty)
        XCTAssertEqual(assetLoader.loadImageCalls.count, 1)
    }

    func test_onAppear_withLocalImage_preparesJpgURL() throws {
        // Given
        let imageURL = try makeTemporaryJPEG()
        let asset = PHAsset_Mock(mediaType: .image)
        asset.contentEditingInput = PHContentEditingInput_Mock(fullSizeImageURL: imageURL)
        let handler = MediaPickerAssetHandler(asset: asset, assetLoader: PhotoAssetLoader_Mock())

        // When
        handler.onAppear()
        waitFor {
            handler.jpgURL != nil
        }

        // Then
        XCTAssertEqual(handler.assetURL, imageURL)
        XCTAssertNotNil(handler.jpgURL)
        XCTAssertEqual(handler.jpgURL?.pathExtension.lowercased(), "jpg")
        XCTAssertEqual(handler.readyURL, handler.jpgURL)
    }

    // MARK: - Disappear

    func test_onDisappear_cancelsThumbnailLoadAndClearsThumbnail() {
        // Given
        let assetLoader = PhotoAssetLoader_Mock()
        let asset = PHAsset_Mock()
        let image = UIImage.testImage(color: .red)
        assetLoader.cache(image, for: asset)
        let handler = MediaPickerAssetHandler(asset: asset, assetLoader: assetLoader)
        handler.onAppear()
        XCTAssertEqual(handler.currentImage, image)

        // When — force a local thumbnail then clear it on disappear.
        handler.onDisappear()

        // Then
        XCTAssertEqual(assetLoader.cancelledImageLoads.count, 1)
        XCTAssertTrue(assetLoader.cancelledImageLoads.first === asset)
        XCTAssertNil(handler.thumbnail)
    }

    func test_onDisappear_cancelsPendingContentEditingInputRequest() {
        // Given
        let asset = PHAsset_Mock(mediaType: .image)
        asset.contentEditingInputRequestId = 7
        let handler = MediaPickerAssetHandler(asset: asset, assetLoader: PhotoAssetLoader_Mock())
        handler.onAppear()
        XCTAssertEqual(handler.requestId, 7)

        // When
        handler.onDisappear()

        // Then
        XCTAssertEqual(asset.cancelledContentEditingInputRequestIds, [7])
        XCTAssertNil(handler.requestId)
        XCTAssertFalse(handler.loading)
    }

    func test_onDisappear_whenContentEditingInputResolvedSynchronously_doesNotCancelIt() {
        // Given
        let asset = PHAsset_Mock(mediaType: .image)
        asset.contentEditingInput = PHContentEditingInput_Mock(
            fullSizeImageURL: URL(fileURLWithPath: "/tmp/photo.heic")
        )
        let handler = MediaPickerAssetHandler(asset: asset, assetLoader: PhotoAssetLoader_Mock())
        handler.onAppear()

        // When
        handler.onDisappear()

        // Then
        XCTAssertTrue(asset.cancelledContentEditingInputRequestIds.isEmpty)
        XCTAssertNil(handler.requestId)
    }

    // MARK: - Tap: already prepared / selected

    func test_handleTap_whenAlreadySelected_selectsImmediately() throws {
        // Given
        let imageURL = try makeTemporaryJPEG()
        let asset = PHAsset_Mock(id: "photo-1", mediaType: .image)
        asset.contentEditingInput = PHContentEditingInput_Mock(fullSizeImageURL: imageURL)
        let handler = MediaPickerAssetHandler(asset: asset, assetLoader: PhotoAssetLoader_Mock())
        handler.onAppear()
        waitFor { handler.jpgURL != nil }

        var selected: AddedAsset?
        let image = UIImage.testImage(color: .blue)

        // When
        handler.handleTap(image: image, currentlySelected: true) { selected = $0 }

        // Then
        XCTAssertEqual(selected?.id, "photo-1")
        XCTAssertEqual(selected?.type, .image)
        XCTAssertEqual(selected?.url, handler.jpgURL)
        XCTAssertEqual(asset.contentEditingInputRequests.count, 1, "No additional resolve on deselect")
    }

    func test_handleTap_whenImageAlreadyPrepared_selectsImmediatelyWithoutNetwork() throws {
        // Given
        let imageURL = try makeTemporaryJPEG()
        let asset = PHAsset_Mock(mediaType: .image)
        asset.contentEditingInput = PHContentEditingInput_Mock(fullSizeImageURL: imageURL)
        let handler = MediaPickerAssetHandler(asset: asset, assetLoader: PhotoAssetLoader_Mock())
        handler.onAppear()
        waitFor { handler.jpgURL != nil }
        let requestsBeforeTap = asset.contentEditingInputRequests.count

        var selected: AddedAsset?
        handler.handleTap(image: UIImage.testImage(color: .green), currentlySelected: false) {
            selected = $0
        }

        // Then
        XCTAssertNotNil(selected)
        XCTAssertEqual(selected?.url, handler.jpgURL)
        XCTAssertEqual(asset.contentEditingInputRequests.count, requestsBeforeTap)
    }

    func test_handleTap_whenCompressing_ignoresTap() throws {
        // Given — video that needs compression, with an async compress that never finishes.
        let videoURL = try makeTemporaryFile(named: "video.mp4", contents: Data(repeating: 1, count: 32))
        let assetLoader = PhotoAssetLoader_Mock()
        assetLoader.exceedsAllowedSize = true
        assetLoader.hangCompression = true
        let asset = PHAsset_Mock(mediaType: .video, duration: 9)
        asset.contentEditingInput = PHContentEditingInput_Mock(
            audiovisualAsset: AVURLAsset(url: videoURL)
        )
        let handler = MediaPickerAssetHandler(asset: asset, assetLoader: assetLoader)

        var selectedCount = 0
        handler.handleTap(image: UIImage.testImage(color: .orange), currentlySelected: false) { _ in
            selectedCount += 1
        }
        XCTAssertTrue(handler.compressing)

        // When
        handler.handleTap(image: UIImage.testImage(color: .orange), currentlySelected: false) { _ in
            selectedCount += 1
        }

        // Then
        XCTAssertEqual(selectedCount, 0)
        XCTAssertEqual(assetLoader.compressAssetCalls.count, 1)
    }

    // MARK: - Tap: resolve on demand

    func test_handleTap_withUnpreparedImage_resolvesWithNetworkAccessAndSelects() throws {
        // Given — no onAppear prepare; tap must resolve with network allowed.
        let imageURL = try makeTemporaryJPEG()
        let asset = PHAsset_Mock(id: "late-photo", mediaType: .image)
        asset.contentEditingInput = PHContentEditingInput_Mock(fullSizeImageURL: imageURL)
        let handler = MediaPickerAssetHandler(asset: asset, assetLoader: PhotoAssetLoader_Mock())

        var selected: AddedAsset?
        handler.handleTap(image: UIImage.testImage(color: .purple), currentlySelected: false) {
            selected = $0
        }

        // Then
        XCTAssertEqual(asset.contentEditingInputRequests.count, 1)
        XCTAssertEqual(asset.contentEditingInputRequests.first?.isNetworkAccessAllowed, true)
        XCTAssertNotNil(selected)
        XCTAssertEqual(selected?.id, "late-photo")
        XCTAssertEqual(selected?.type, .image)
        XCTAssertEqual(selected?.url.pathExtension.lowercased(), "jpg")
        XCTAssertFalse(handler.loading)
        XCTAssertFalse(handler.compressing)
    }

    func test_handleTap_withVideoUnderSizeLimit_selectsWithoutCompression() throws {
        // Given
        let videoURL = try makeTemporaryFile(named: "small.mp4", contents: Data(repeating: 1, count: 16))
        let assetLoader = PhotoAssetLoader_Mock()
        assetLoader.exceedsAllowedSize = false
        let asset = PHAsset_Mock(id: "vid-1", mediaType: .video, duration: 4.5)
        asset.contentEditingInput = PHContentEditingInput_Mock(
            audiovisualAsset: AVURLAsset(url: videoURL)
        )
        let handler = MediaPickerAssetHandler(asset: asset, assetLoader: assetLoader)

        var selected: AddedAsset?
        handler.handleTap(image: UIImage.testImage(color: .cyan), currentlySelected: false) {
            selected = $0
        }

        // Then
        XCTAssertTrue(assetLoader.compressAssetCalls.isEmpty)
        XCTAssertEqual(selected?.id, "vid-1")
        XCTAssertEqual(selected?.type, .video)
        XCTAssertEqual(selected?.url, videoURL)
        XCTAssertEqual(selected?.duration, 4.5)
        XCTAssertFalse(handler.isBusy)
    }

    func test_handleTap_withOversizedVideo_compressesBeforeSelecting() throws {
        // Given
        let videoURL = try makeTemporaryFile(named: "large.mp4", contents: Data(repeating: 1, count: 64))
        let compressedURL = try makeTemporaryFile(named: "compressed.mp4", contents: Data(repeating: 2, count: 8))
        let assetLoader = PhotoAssetLoader_Mock()
        assetLoader.exceedsAllowedSize = true
        assetLoader.compressedURL = compressedURL
        let asset = PHAsset_Mock(id: "vid-large", mediaType: .video, duration: 30)
        asset.contentEditingInput = PHContentEditingInput_Mock(
            audiovisualAsset: AVURLAsset(url: videoURL)
        )
        let handler = MediaPickerAssetHandler(asset: asset, assetLoader: assetLoader)

        var selected: AddedAsset?
        handler.handleTap(image: UIImage.testImage(color: .yellow), currentlySelected: false) {
            selected = $0
        }

        // Then
        XCTAssertEqual(assetLoader.compressAssetCalls.count, 1)
        XCTAssertEqual(assetLoader.compressAssetCalls.first?.url, videoURL)
        XCTAssertEqual(assetLoader.compressAssetCalls.first?.type, .video)
        XCTAssertEqual(selected?.url, compressedURL)
        XCTAssertEqual(handler.assetURL, compressedURL)
        XCTAssertFalse(handler.compressing)
        XCTAssertFalse(handler.loading)
    }

    func test_handleTap_whenCompressionFails_selectsOriginalURL() throws {
        // Given
        let videoURL = try makeTemporaryFile(named: "fail.mp4", contents: Data(repeating: 1, count: 64))
        let assetLoader = PhotoAssetLoader_Mock()
        assetLoader.exceedsAllowedSize = true
        assetLoader.compressedURL = nil
        let asset = PHAsset_Mock(id: "vid-fail", mediaType: .video, duration: 20)
        asset.contentEditingInput = PHContentEditingInput_Mock(
            audiovisualAsset: AVURLAsset(url: videoURL)
        )
        let handler = MediaPickerAssetHandler(asset: asset, assetLoader: assetLoader)

        var selected: AddedAsset?
        handler.handleTap(image: UIImage.testImage(color: .magenta), currentlySelected: false) {
            selected = $0
        }

        // Then
        XCTAssertEqual(assetLoader.compressAssetCalls.count, 1)
        XCTAssertEqual(selected?.url, videoURL)
        XCTAssertEqual(handler.assetURL, videoURL)
        XCTAssertFalse(handler.isBusy)
    }

    func test_handleTap_whenResolveReturnsNoURL_doesNotSelect() {
        // Given — content editing input resolves to nil payload.
        let asset = PHAsset_Mock(mediaType: .video, duration: 3)
        asset.contentEditingInput = PHContentEditingInput_Mock()
        let handler = MediaPickerAssetHandler(asset: asset, assetLoader: PhotoAssetLoader_Mock())

        var selected: AddedAsset?
        handler.handleTap(image: UIImage.testImage(color: .brown), currentlySelected: false) {
            selected = $0
        }

        // Then
        XCTAssertNil(selected)
        XCTAssertNil(handler.assetURL)
        XCTAssertFalse(handler.loading)
    }

    func test_handleTap_whileLoading_ignoresAdditionalTaps() {
        // Given — first tap starts a request that never completes.
        let asset = PHAsset_Mock(mediaType: .video, duration: 2)
        // contentEditingInput left nil → completion never fires, loading stays true.
        let handler = MediaPickerAssetHandler(asset: asset, assetLoader: PhotoAssetLoader_Mock())

        var selectedCount = 0
        handler.handleTap(image: UIImage.testImage(color: .gray), currentlySelected: false) { _ in
            selectedCount += 1
        }
        XCTAssertTrue(handler.loading)
        XCTAssertEqual(asset.contentEditingInputRequests.count, 1)

        // When
        handler.handleTap(image: UIImage.testImage(color: .gray), currentlySelected: false) { _ in
            selectedCount += 1
        }

        // Then
        XCTAssertEqual(selectedCount, 0)
        XCTAssertEqual(asset.contentEditingInputRequests.count, 1)
    }

    // MARK: - Helpers

    private func makeTemporaryJPEG() throws -> URL {
        let image = UIImage.testImage(color: .red, size: CGSize(width: 40, height: 40))
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("\(UUID().uuidString).jpg")
        guard let data = image.jpegData(compressionQuality: 1) else {
            throw TestError()
        }
        try data.write(to: url)
        return url
    }

    private func makeTemporaryFile(named name: String, contents: Data) throws -> URL {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("\(UUID().uuidString)-\(name)")
        try contents.write(to: url)
        return url
    }

    private func waitFor(
        timeout: TimeInterval = defaultTimeout,
        _ condition: @escaping () -> Bool
    ) {
        let expectation = expectation(description: "Condition met")
        let deadline = Date().addingTimeInterval(timeout)
        func poll() {
            if condition() {
                expectation.fulfill()
            } else if Date() < deadline {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: poll)
            }
        }
        poll()
        wait(for: [expectation], timeout: timeout + 1)
    }
}
