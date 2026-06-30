//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChatSwiftUI
import XCTest

final class LRUDiskCache_Tests: XCTestCase {
    private var root: URL!
    private var directory: URL!
    private var tempDirectory: URL!
    private let fileManager = FileManager.default

    override func setUpWithError() throws {
        try super.setUpWithError()
        root = fileManager.temporaryDirectory
            .appendingPathComponent("LRUDiskCache_Tests", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        directory = root.appendingPathComponent("cache", isDirectory: true)
        tempDirectory = root.appendingPathComponent("temps", isDirectory: true)
        try fileManager.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        // Removing the whole root reclaims both the cache dir and any temp files that store() did
        // not consume, so nothing leaks into the system temp dir.
        try? fileManager.removeItem(at: root)
        root = nil
        directory = nil
        tempDirectory = nil
        try super.tearDownWithError()
    }

    // Writes `byteCount` bytes to a fresh temp file (under the per-test temp dir) and returns its URL.
    private func makeTempFile(byteCount: Int) throws -> URL {
        let url = tempDirectory.appendingPathComponent(UUID().uuidString)
        try Data(repeating: 0xab, count: byteCount).write(to: url)
        return url
    }

    func test_store_thenCachedFileURL_returnsStoredFileWithContents() throws {
        let cache = LRUDiskCache(directory: directory, maxSizeInBytes: 1_000_000)
        let temp = try makeTempFile(byteCount: 100)

        let storedURL = cache.store(fileAt: temp, forKey: "/path/video.mp4", fileExtension: "mp4")
        let cachedURL = cache.cachedFileURL(forKey: "/path/video.mp4", fileExtension: "mp4")

        XCTAssertNotNil(storedURL)
        XCTAssertEqual(cachedURL, storedURL)
        XCTAssertEqual(try Data(contentsOf: try XCTUnwrap(cachedURL)).count, 100)
    }

    func test_cachedFileURL_whenNotStored_returnsNil() {
        let cache = LRUDiskCache(directory: directory, maxSizeInBytes: 1_000_000)
        XCTAssertNil(cache.cachedFileURL(forKey: "/missing.mp4", fileExtension: "mp4"))
    }

    func test_store_whenFileExceedsMaxSize_cachesFile() throws {
        let cache = LRUDiskCache(directory: directory, maxSizeInBytes: 50)
        let temp = try makeTempFile(byteCount: 100)

        let storedURL = cache.store(fileAt: temp, forKey: "/big.mp4", fileExtension: "mp4")
        let cachedURL = cache.cachedFileURL(forKey: "/big.mp4", fileExtension: "mp4")

        XCTAssertNotNil(storedURL)
        XCTAssertEqual(cachedURL, storedURL)
        XCTAssertEqual(try Data(contentsOf: try XCTUnwrap(cachedURL)).count, 100)
    }

    func test_store_whenOverMaxFileIsLeastRecentlyUsed_evictsOnNextStore() throws {
        let cache = LRUDiskCache(directory: directory, maxSizeInBytes: 50)
        _ = cache.store(fileAt: try makeTempFile(byteCount: 100), forKey: "big", fileExtension: nil)
        _ = cache.store(fileAt: try makeTempFile(byteCount: 25), forKey: "small", fileExtension: nil)

        XCTAssertNil(cache.cachedFileURL(forKey: "big", fileExtension: nil))
        XCTAssertNotNil(cache.cachedFileURL(forKey: "small", fileExtension: nil))
    }

    func test_store_whenOverCapacity_evictsLeastRecentlyUsed() throws {
        let cache = LRUDiskCache(directory: directory, maxSizeInBytes: 250)
        _ = cache.store(fileAt: try makeTempFile(byteCount: 100), forKey: "a", fileExtension: nil) // order 0
        _ = cache.store(fileAt: try makeTempFile(byteCount: 100), forKey: "b", fileExtension: nil) // order 1
        _ = cache.cachedFileURL(forKey: "a", fileExtension: nil) // touch a -> newer than b
        _ = cache.store(fileAt: try makeTempFile(byteCount: 100), forKey: "c", fileExtension: nil) // 300 > 250 -> evict LRU (b)

        XCTAssertNotNil(cache.cachedFileURL(forKey: "a", fileExtension: nil), "recently used -> survives")
        XCTAssertNil(cache.cachedFileURL(forKey: "b", fileExtension: nil), "least recently used -> evicted")
        XCTAssertNotNil(cache.cachedFileURL(forKey: "c", fileExtension: nil), "just stored -> survives")
    }

    func test_store_overwritingExistingKey_replacesContents() throws {
        let cache = LRUDiskCache(directory: directory, maxSizeInBytes: 1_000_000)
        _ = cache.store(fileAt: try makeTempFile(byteCount: 100), forKey: "/v.mp4", fileExtension: "mp4")
        _ = cache.store(fileAt: try makeTempFile(byteCount: 175), forKey: "/v.mp4", fileExtension: "mp4")

        let cachedURL = cache.cachedFileURL(forKey: "/v.mp4", fileExtension: "mp4")
        XCTAssertEqual(try Data(contentsOf: try XCTUnwrap(cachedURL)).count, 175)
    }

    func test_remove_deletesCachedEntry() throws {
        let cache = LRUDiskCache(directory: directory, maxSizeInBytes: 1_000_000)
        _ = cache.store(fileAt: try makeTempFile(byteCount: 100), forKey: "/v.mp4", fileExtension: "mp4")

        cache.remove(forKey: "/v.mp4", fileExtension: "mp4")

        XCTAssertNil(cache.cachedFileURL(forKey: "/v.mp4", fileExtension: "mp4"))
    }

    func test_remove_afterRemoval_canStoreSameKeyAgain() throws {
        let cache = LRUDiskCache(directory: directory, maxSizeInBytes: 1_000_000)
        _ = cache.store(fileAt: try makeTempFile(byteCount: 100), forKey: "/v.mp4", fileExtension: "mp4")
        cache.remove(forKey: "/v.mp4", fileExtension: "mp4")

        let storedURL = cache.store(fileAt: try makeTempFile(byteCount: 120), forKey: "/v.mp4", fileExtension: "mp4")

        XCTAssertNotNil(storedURL)
        XCTAssertEqual(try Data(contentsOf: try XCTUnwrap(cache.cachedFileURL(forKey: "/v.mp4", fileExtension: "mp4"))).count, 120)
    }

    func test_newInstance_seesFilesStoredByPreviousInstance() throws {
        let cache1 = LRUDiskCache(directory: directory, maxSizeInBytes: 1_000_000)
        _ = cache1.store(fileAt: try makeTempFile(byteCount: 100), forKey: "/v.mp4", fileExtension: "mp4")

        let cache2 = LRUDiskCache(directory: directory, maxSizeInBytes: 1_000_000)
        XCTAssertNotNil(cache2.cachedFileURL(forKey: "/v.mp4", fileExtension: "mp4"))
    }

    func test_removeAll_clearsCache() throws {
        let cache = LRUDiskCache(directory: directory, maxSizeInBytes: 1_000_000)
        _ = cache.store(fileAt: try makeTempFile(byteCount: 100), forKey: "/v.mp4", fileExtension: "mp4")

        cache.removeAll()

        XCTAssertNil(cache.cachedFileURL(forKey: "/v.mp4", fileExtension: "mp4"))
    }
}
