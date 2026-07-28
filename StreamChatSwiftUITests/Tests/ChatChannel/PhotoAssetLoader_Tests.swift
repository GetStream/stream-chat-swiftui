//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Photos
@testable import StreamChat
@testable import StreamChatSwiftUI
import UniformTypeIdentifiers
import XCTest

@MainActor class PhotoAssetLoader_Tests: StreamChatTestCase {
    // MARK: - Cache

    func test_cachedImage_whenAssetIsCached_returnsImage() {
        // Given
        let loader = PhotoAssetLoader()
        let asset = PHAsset_Mock()
        let image = UIImage.testImage(color: .red)

        // When
        loader.cache(image, for: asset)

        // Then
        XCTAssertEqual(loader.cachedImage(for: asset), image)
    }

    func test_cachedImage_whenAssetIsNotCached_returnsNil() {
        // Given
        let loader = PhotoAssetLoader()

        // Then
        XCTAssertNil(loader.cachedImage(for: PHAsset_Mock()))
    }

    func test_cachedImage_whenAnotherAssetIsCached_returnsNil() {
        // Given
        let loader = PhotoAssetLoader()
        loader.cache(UIImage.testImage(color: .red), for: PHAsset_Mock(id: "asset-1"))

        // Then
        XCTAssertNil(loader.cachedImage(for: PHAsset_Mock(id: "asset-2")))
    }

    func test_didReceiveMemoryWarning_clearsCachedImages() {
        // Given
        let loader = PhotoAssetLoader()
        let asset = PHAsset_Mock()
        loader.cache(UIImage.testImage(color: .red), for: asset)

        // When
        loader.didReceiveMemoryWarning()

        // Then
        XCTAssertNil(loader.cachedImage(for: asset))
    }

    // MARK: - Loading

    func test_loadImage_whenAssetIsCached_completesWithCachedImage() {
        // Given
        let loader = PhotoAssetLoader()
        let asset = PHAsset_Mock()
        let image = UIImage.testImage(color: .green)
        loader.cache(image, for: asset)

        // When
        var loadedImage: UIImage?
        loader.loadImage(for: asset, targetSize: CGSize(width: 250, height: 250)) { image in
            loadedImage = image
        }

        // Then
        XCTAssertEqual(loadedImage, image)
    }

    // MARK: - Cancellation

    func test_cancelImageLoad_whenNoRequestIsInFlight_doesNothing() {
        // Given
        let loader = PhotoAssetLoader()

        // When
        loader.cancelImageLoad(for: PHAsset_Mock())

        // Then
        XCTAssertNil(loader.cachedImage(for: PHAsset_Mock()))
    }

    func test_cancelAllImageLoads_whenNoRequestsAreInFlight_keepsCachedImages() {
        // Given
        let loader = PhotoAssetLoader()
        let asset = PHAsset_Mock()
        let image = UIImage.testImage(color: .blue)
        loader.cache(image, for: asset)

        // When
        loader.cancelAllImageLoads()

        // Then
        XCTAssertEqual(loader.cachedImage(for: asset), image)
    }

    // MARK: - Compression

    func test_compressAsset_whenAssetIsAnImage_completesWithoutURL() {
        // Given
        let loader = PhotoAssetLoader()
        let url = try! makeTemporaryFile(named: "image.jpg", contents: Data([0x01]))

        // When
        let expectation = expectation(description: "Compression completed")
        var completedURL: URL?
        loader.compressAsset(at: url, type: .image) { url in
            completedURL = url
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation], timeout: defaultTimeout)
        XCTAssertNil(completedURL)
    }

    func test_compressAsset_whenVideoCannotBeExported_completesWithoutURL() {
        // Given
        let loader = PhotoAssetLoader()
        let url = try! makeTemporaryFile(named: "not-a-video.mp4", contents: Data([0x01, 0x02, 0x03]))

        // When
        let expectation = expectation(description: "Compression completed")
        var completedURL: URL?
        loader.compressAsset(at: url, type: .video) { url in
            completedURL = url
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation], timeout: 10)
        XCTAssertNil(completedURL)
    }

    // MARK: - Temporary JPG

    func test_temporaryJpgURL_whenDataIsJpg_writesItWithoutConverting() throws {
        // Given
        let data = try XCTUnwrap(UIImage.testImage(color: .red).jpegData(compressionQuality: 1))

        // When
        let url = try XCTUnwrap(PhotoAssetLoader.temporaryJpgURL(for: data, dataUTI: UTType.jpeg.identifier))

        // Then
        XCTAssertEqual(url.pathExtension, "jpg")
        XCTAssertEqual(try Data(contentsOf: url), data)
    }

    func test_temporaryJpgURL_whenDataIsNotJpg_convertsItToJpg() throws {
        // Given
        let data = try XCTUnwrap(UIImage.testImage(color: .red).pngData())

        // When
        let url = try XCTUnwrap(PhotoAssetLoader.temporaryJpgURL(for: data, dataUTI: UTType.png.identifier))

        // Then
        XCTAssertEqual(url.pathExtension, "jpg")
        XCTAssertNotNil(UIImage(data: try Data(contentsOf: url)))
        XCTAssertNotEqual(try Data(contentsOf: url), data)
    }

    func test_temporaryJpgURL_whenDataIsNotAnImage_returnsNil() {
        // Then
        XCTAssertNil(PhotoAssetLoader.temporaryJpgURL(for: Data([0x01, 0x02]), dataUTI: nil))
    }

    // MARK: - Allowed Size

    func test_assetExceedsAllowedSize_whenURLIsNil_returnsFalse() {
        // Given
        let loader = PhotoAssetLoader()

        // Then
        XCTAssertFalse(loader.assetExceedsAllowedSize(url: nil))
    }

    func test_assetExceedsAllowedSize_whenAssetIsSmallerThanMaxSize_returnsFalse() throws {
        // Given
        streamChat = StreamChat(
            chatClient: chatClient,
            utils: Utils(composerConfig: ComposerConfig(maxAttachmentSize: 1024))
        )
        let loader = PhotoAssetLoader()
        let url = try makeTemporaryFile(named: "small.mp4", contents: Data(repeating: 0, count: 10))

        // Then
        XCTAssertFalse(loader.assetExceedsAllowedSize(url: url))
    }

    func test_assetExceedsAllowedSize_whenAssetIsLargerThanMaxSize_returnsTrue() throws {
        // Given
        streamChat = StreamChat(
            chatClient: chatClient,
            utils: Utils(composerConfig: ComposerConfig(maxAttachmentSize: 10))
        )
        let loader = PhotoAssetLoader()
        let url = try makeTemporaryFile(named: "large.mp4", contents: Data(repeating: 0, count: 1024))

        // Then
        XCTAssertTrue(loader.assetExceedsAllowedSize(url: url))
    }

    // MARK: - PHFetchResultCollection

    func test_fetchResultCollection_exposesTheFetchedAssets() {
        // Given
        let assets = [PHAsset_Mock(id: "asset-0"), PHAsset_Mock(id: "asset-1")]
        let collection = PHFetchResultCollection(fetchResult: PHFetchResult_Mock(assets: assets))

        // Then
        XCTAssertEqual(collection.count, 2)
        XCTAssertEqual(collection.startIndex, 0)
        XCTAssertEqual(collection.endIndex, 2)
        XCTAssertEqual(collection[0].localIdentifier, "asset-0")
        XCTAssertEqual(collection[1].localIdentifier, "asset-1")
    }

    func test_fetchResultCollection_whenEmpty_isEmpty() {
        // Given
        let collection = PHFetchResultCollection(fetchResult: PHFetchResult_Mock(assets: []))

        // Then
        XCTAssertTrue(collection.isEmpty)
    }

    func test_fetchResultCollection_whenFetchResultIsTheSame_areEqual() {
        // Given
        let fetchResult = PHFetchResult_Mock(assets: [PHAsset_Mock()])

        // Then
        XCTAssertEqual(
            PHFetchResultCollection(fetchResult: fetchResult),
            PHFetchResultCollection(fetchResult: fetchResult)
        )
    }

    func test_fetchResultCollection_whenFetchResultIsDifferent_areNotEqual() {
        // Given
        let asset = PHAsset_Mock()

        // Then
        XCTAssertNotEqual(
            PHFetchResultCollection(fetchResult: PHFetchResult_Mock(assets: [asset])),
            PHFetchResultCollection(fetchResult: PHFetchResult_Mock(assets: [asset]))
        )
    }

    // MARK: - Helpers

    private func makeTemporaryFile(named name: String, contents: Data) throws -> URL {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("\(UUID().uuidString)-\(name)")
        try contents.write(to: url)
        return url
    }
}

extension UIImage {
    static func testImage(color: UIColor, size: CGSize = CGSize(width: 20, height: 20)) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
