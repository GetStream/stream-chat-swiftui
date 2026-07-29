//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Combine
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

    func test_onAppear_doesNotRequestAssetURL() {
        // Given — assets are only resolved on tap, so appearing does no Photos work
        // beyond the thumbnail.
        let assetLoader = PhotoAssetLoader_Mock()
        let asset = PHAsset_Mock(mediaType: .image)
        let handler = MediaPickerAssetHandler(asset: asset, assetLoader: assetLoader)

        // When
        handler.onAppear()

        // Then
        XCTAssertTrue(assetLoader.assetURLRequests.isEmpty)
        XCTAssertEqual(assetLoader.loadImageCalls.count, 1)
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

        // When
        handler.onDisappear()

        // Then
        XCTAssertEqual(assetLoader.cancelledImageLoads.count, 1)
        XCTAssertTrue(assetLoader.cancelledImageLoads.first === asset)
        XCTAssertNil(handler.thumbnail)
    }

    func test_onDisappear_cancelsPendingAssetURLRequest() {
        // Given — a tap starts a request that never completes.
        let assetLoader = PhotoAssetLoader_Mock()
        assetLoader.completesAssetURLRequests = false
        assetLoader.assetURLRequestId = 7
        let handler = MediaPickerAssetHandler(
            asset: PHAsset_Mock(mediaType: .image),
            assetLoader: assetLoader
        )
        handler.handleTap(image: UIImage.testImage(color: .red), currentlySelected: false) { _ in }
        XCTAssertEqual(handler.requestId, 7)

        // When
        handler.onDisappear()

        // Then
        XCTAssertEqual(assetLoader.cancelledRequestIds, [7])
        XCTAssertNil(handler.requestId)
        XCTAssertFalse(handler.loading)
    }

    func test_onDisappear_whenAssetURLResolvedSynchronously_doesNotCancelIt() throws {
        // Given — the tap's request completes immediately.
        let assetLoader = PhotoAssetLoader_Mock()
        assetLoader.assetURL = try makeTemporaryJPEG()
        let handler = MediaPickerAssetHandler(
            asset: PHAsset_Mock(mediaType: .image),
            assetLoader: assetLoader
        )
        handler.handleTap(image: UIImage.testImage(color: .red), currentlySelected: false) { _ in }

        // When
        handler.onDisappear()

        // Then
        XCTAssertTrue(assetLoader.cancelledRequestIds.isEmpty)
        XCTAssertNil(handler.requestId)
    }

    // MARK: - Tap: already resolved / selected

    func test_handleTap_whenAlreadySelected_deselectsWithoutNewRequest() throws {
        // Given — a first tap resolved and selected the asset.
        let imageURL = try makeTemporaryJPEG()
        let assetLoader = PhotoAssetLoader_Mock()
        assetLoader.assetURL = imageURL
        let asset = PHAsset_Mock(id: "photo-1", mediaType: .image)
        let handler = MediaPickerAssetHandler(asset: asset, assetLoader: assetLoader)
        handler.handleTap(image: UIImage.testImage(color: .blue), currentlySelected: false) { _ in }

        var selected: AddedAsset?

        // When
        handler.handleTap(image: UIImage.testImage(color: .blue), currentlySelected: true) { selected = $0 }

        // Then
        XCTAssertEqual(selected?.id, "photo-1")
        XCTAssertEqual(selected?.type, .image)
        XCTAssertEqual(selected?.url, imageURL)
        XCTAssertEqual(assetLoader.assetURLRequests.count, 1, "No additional resolve on deselect")
    }

    func test_handleTap_whenURLAlreadyResolved_selectsWithoutNewRequest() throws {
        // Given — a previous tap already resolved the url.
        let imageURL = try makeTemporaryJPEG()
        let assetLoader = PhotoAssetLoader_Mock()
        assetLoader.assetURL = imageURL
        let handler = MediaPickerAssetHandler(
            asset: PHAsset_Mock(mediaType: .image),
            assetLoader: assetLoader
        )
        handler.handleTap(image: UIImage.testImage(color: .green), currentlySelected: false) { _ in }

        // When
        var selected: AddedAsset?
        handler.handleTap(image: UIImage.testImage(color: .green), currentlySelected: false) {
            selected = $0
        }

        // Then
        XCTAssertEqual(selected?.url, imageURL)
        XCTAssertEqual(assetLoader.assetURLRequests.count, 1)
    }

    func test_handleTap_whenCompressing_ignoresTap() throws {
        // Given — video that needs compression, with a compression that never finishes.
        let videoURL = try makeTemporaryFile(named: "video.mp4")
        let assetLoader = PhotoAssetLoader_Mock()
        assetLoader.assetURL = videoURL
        assetLoader.exceedsAllowedSize = true
        assetLoader.hangCompression = true
        let asset = PHAsset_Mock(mediaType: .video, duration: 9)
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

    func test_handleTap_withLocalImage_resolvesAndSelectsWithoutSpinner() throws {
        // Given
        let imageURL = try makeTemporaryJPEG()
        let assetLoader = PhotoAssetLoader_Mock()
        assetLoader.assetURL = imageURL
        let asset = PHAsset_Mock(id: "late-photo", mediaType: .image)
        let handler = MediaPickerAssetHandler(asset: asset, assetLoader: assetLoader)

        var shownSpinner = false
        let spinnerObservation = handler.$loading.sink { shownSpinner = shownSpinner || $0 }
        defer { spinnerObservation.cancel() }

        // When
        var selected: AddedAsset?
        handler.handleTap(image: UIImage.testImage(color: .purple), currentlySelected: false) {
            selected = $0
        }

        // Then
        XCTAssertEqual(assetLoader.assetURLRequests.count, 1)
        XCTAssertEqual(assetLoader.assetURLRequests.first?.allowsNetworkAccess, false)
        XCTAssertEqual(selected?.id, "late-photo")
        XCTAssertEqual(selected?.type, .image)
        XCTAssertEqual(selected?.url, imageURL)
        XCTAssertFalse(shownSpinner, "Local assets must resolve without the progress indicator")
        XCTAssertFalse(handler.compressing)
    }

    func test_handleTap_withICloudImage_downloadsWithSpinnerAndSelects() throws {
        // Given — the local-only attempt fails, so the asset is downloaded from iCloud.
        let imageURL = try makeTemporaryJPEG()
        let assetLoader = PhotoAssetLoader_Mock()
        assetLoader.assetURL = imageURL
        assetLoader.assetIsInCloud = true
        let asset = PHAsset_Mock(id: "cloud-photo", mediaType: .image)
        let handler = MediaPickerAssetHandler(asset: asset, assetLoader: assetLoader)

        var shownSpinner = false
        let spinnerObservation = handler.$loading.sink { shownSpinner = shownSpinner || $0 }
        defer { spinnerObservation.cancel() }

        // When
        var selected: AddedAsset?
        handler.handleTap(image: UIImage.testImage(color: .purple), currentlySelected: false) {
            selected = $0
        }

        // Then
        XCTAssertEqual(assetLoader.assetURLRequests.map(\.allowsNetworkAccess), [false, true])
        XCTAssertEqual(selected?.id, "cloud-photo")
        XCTAssertEqual(selected?.url, imageURL)
        XCTAssertTrue(shownSpinner, "Downloads must show the progress indicator")
        XCTAssertFalse(handler.loading)
    }

    func test_handleTap_withVideoUnderSizeLimit_selectsWithoutCompression() throws {
        // Given
        let videoURL = try makeTemporaryFile(named: "small.mp4")
        let assetLoader = PhotoAssetLoader_Mock()
        assetLoader.assetURL = videoURL
        assetLoader.exceedsAllowedSize = false
        let asset = PHAsset_Mock(id: "vid-1", mediaType: .video, duration: 4.5)
        let handler = MediaPickerAssetHandler(asset: asset, assetLoader: assetLoader)

        // When
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
        let videoURL = try makeTemporaryFile(named: "large.mp4")
        let compressedURL = try makeTemporaryFile(named: "compressed.mp4")
        let assetLoader = PhotoAssetLoader_Mock()
        assetLoader.assetURL = videoURL
        assetLoader.exceedsAllowedSize = true
        assetLoader.compressedURL = compressedURL
        let asset = PHAsset_Mock(id: "vid-large", mediaType: .video, duration: 30)
        let handler = MediaPickerAssetHandler(asset: asset, assetLoader: assetLoader)

        // When
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
        let videoURL = try makeTemporaryFile(named: "fail.mp4")
        let assetLoader = PhotoAssetLoader_Mock()
        assetLoader.assetURL = videoURL
        assetLoader.exceedsAllowedSize = true
        assetLoader.compressedURL = nil
        let asset = PHAsset_Mock(id: "vid-fail", mediaType: .video, duration: 20)
        let handler = MediaPickerAssetHandler(asset: asset, assetLoader: assetLoader)

        // When
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
        // Given — the asset cannot be resolved, for example a video stored as a composition.
        let assetLoader = PhotoAssetLoader_Mock()
        assetLoader.assetURL = nil
        let handler = MediaPickerAssetHandler(
            asset: PHAsset_Mock(mediaType: .video, duration: 3),
            assetLoader: assetLoader
        )

        // When
        var selected: AddedAsset?
        handler.handleTap(image: UIImage.testImage(color: .brown), currentlySelected: false) {
            selected = $0
        }

        // Then
        XCTAssertNil(selected)
        XCTAssertNil(handler.assetURL)
        XCTAssertFalse(handler.loading)
    }

    func test_handleTap_whileResolving_ignoresAdditionalTaps() {
        // Given — first tap starts a request that never completes.
        let assetLoader = PhotoAssetLoader_Mock()
        assetLoader.completesAssetURLRequests = false
        let handler = MediaPickerAssetHandler(
            asset: PHAsset_Mock(mediaType: .video, duration: 2),
            assetLoader: assetLoader
        )

        var selectedCount = 0
        handler.handleTap(image: UIImage.testImage(color: .gray), currentlySelected: false) { _ in
            selectedCount += 1
        }
        XCTAssertNotNil(handler.requestId)
        XCTAssertEqual(assetLoader.assetURLRequests.count, 1)

        // When
        handler.handleTap(image: UIImage.testImage(color: .gray), currentlySelected: false) { _ in
            selectedCount += 1
        }

        // Then
        XCTAssertEqual(selectedCount, 0)
        XCTAssertEqual(assetLoader.assetURLRequests.count, 1)
    }

    // MARK: - Helpers

    private func makeTemporaryJPEG() throws -> URL {
        let image = UIImage.testImage(color: .red, size: CGSize(width: 40, height: 40))
        guard let data = image.jpegData(compressionQuality: 1) else {
            throw TestError()
        }
        return try makeTemporaryFile(named: "photo.jpg", contents: data)
    }

    private func makeTemporaryFile(
        named name: String,
        contents: Data = Data(repeating: 1, count: 32)
    ) throws -> URL {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("\(UUID().uuidString)-\(name)")
        try contents.write(to: url)
        return url
    }
}
