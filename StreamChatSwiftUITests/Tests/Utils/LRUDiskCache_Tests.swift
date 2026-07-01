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

    func test_store_thenCachedFileURL_returnsStoredFileWithContents() async throws {
        let cache = LRUDiskCache(directory: directory, maxSizeInBytes: 1_000_000)
        let temp = try makeTempFile(byteCount: 100)

        let storedURL = await cache.store(fileAt: temp, forKey: "/path/video.mp4", fileExtension: "mp4")
        let cachedURL = await cache.cachedFileURL(forKey: "/path/video.mp4", fileExtension: "mp4")

        XCTAssertNotNil(storedURL)
        XCTAssertEqual(cachedURL, storedURL)
        XCTAssertEqual(try Data(contentsOf: try XCTUnwrap(cachedURL)).count, 100)
    }

    func test_cachedFileURL_whenNotStored_returnsNil() async {
        let cache = LRUDiskCache(directory: directory, maxSizeInBytes: 1_000_000)
        let cachedURL = await cache.cachedFileURL(forKey: "/missing.mp4", fileExtension: "mp4")
        XCTAssertNil(cachedURL)
    }

    func test_store_whenFileExceedsMaxSize_cachesFile() async throws {
        let cache = LRUDiskCache(directory: directory, maxSizeInBytes: 50)
        let temp = try makeTempFile(byteCount: 100)

        let storedURL = await cache.store(fileAt: temp, forKey: "/big.mp4", fileExtension: "mp4")
        let cachedURL = await cache.cachedFileURL(forKey: "/big.mp4", fileExtension: "mp4")

        XCTAssertNotNil(storedURL)
        XCTAssertEqual(cachedURL, storedURL)
        XCTAssertEqual(try Data(contentsOf: try XCTUnwrap(cachedURL)).count, 100)
    }

    func test_store_whenOverMaxFileIsLeastRecentlyUsed_evictsOnNextStore() async throws {
        let cache = LRUDiskCache(directory: directory, maxSizeInBytes: 50)
        _ = await cache.store(fileAt: try makeTempFile(byteCount: 100), forKey: "big", fileExtension: nil)
        _ = await cache.store(fileAt: try makeTempFile(byteCount: 25), forKey: "small", fileExtension: nil)

        let big = await cache.cachedFileURL(forKey: "big", fileExtension: nil)
        let small = await cache.cachedFileURL(forKey: "small", fileExtension: nil)
        XCTAssertNil(big)
        XCTAssertNotNil(small)
    }

    func test_store_whenOverCapacity_evictsLeastRecentlyUsed() async throws {
        let cache = LRUDiskCache(directory: directory, maxSizeInBytes: 250)
        _ = await cache.store(fileAt: try makeTempFile(byteCount: 100), forKey: "a", fileExtension: nil) // order 0
        _ = await cache.store(fileAt: try makeTempFile(byteCount: 100), forKey: "b", fileExtension: nil) // order 1
        _ = await cache.cachedFileURL(forKey: "a", fileExtension: nil) // touch a -> newer than b
        _ = await cache.store(fileAt: try makeTempFile(byteCount: 100), forKey: "c", fileExtension: nil) // 300 > 250 -> evict LRU (b)

        let a = await cache.cachedFileURL(forKey: "a", fileExtension: nil)
        let b = await cache.cachedFileURL(forKey: "b", fileExtension: nil)
        let c = await cache.cachedFileURL(forKey: "c", fileExtension: nil)
        XCTAssertNotNil(a, "recently used -> survives")
        XCTAssertNil(b, "least recently used -> evicted")
        XCTAssertNotNil(c, "just stored -> survives")
    }

    func test_store_overwritingExistingKey_replacesContents() async throws {
        let cache = LRUDiskCache(directory: directory, maxSizeInBytes: 1_000_000)
        _ = await cache.store(fileAt: try makeTempFile(byteCount: 100), forKey: "/v.mp4", fileExtension: "mp4")
        _ = await cache.store(fileAt: try makeTempFile(byteCount: 175), forKey: "/v.mp4", fileExtension: "mp4")

        let cachedURL = await cache.cachedFileURL(forKey: "/v.mp4", fileExtension: "mp4")
        XCTAssertEqual(try Data(contentsOf: try XCTUnwrap(cachedURL)).count, 175)
    }

    func test_remove_deletesCachedEntry() async throws {
        let cache = LRUDiskCache(directory: directory, maxSizeInBytes: 1_000_000)
        _ = await cache.store(fileAt: try makeTempFile(byteCount: 100), forKey: "/v.mp4", fileExtension: "mp4")

        await cache.remove(forKey: "/v.mp4", fileExtension: "mp4")

        let cachedURL = await cache.cachedFileURL(forKey: "/v.mp4", fileExtension: "mp4")
        XCTAssertNil(cachedURL)
    }

    func test_remove_afterRemoval_canStoreSameKeyAgain() async throws {
        let cache = LRUDiskCache(directory: directory, maxSizeInBytes: 1_000_000)
        _ = await cache.store(fileAt: try makeTempFile(byteCount: 100), forKey: "/v.mp4", fileExtension: "mp4")
        await cache.remove(forKey: "/v.mp4", fileExtension: "mp4")

        let storedURL = await cache.store(fileAt: try makeTempFile(byteCount: 120), forKey: "/v.mp4", fileExtension: "mp4")

        XCTAssertNotNil(storedURL)
        let cachedURL = await cache.cachedFileURL(forKey: "/v.mp4", fileExtension: "mp4")
        XCTAssertEqual(try Data(contentsOf: try XCTUnwrap(cachedURL)).count, 120)
    }

    func test_newInstance_seesFilesStoredByPreviousInstance() async throws {
        let cache1 = LRUDiskCache(directory: directory, maxSizeInBytes: 1_000_000)
        _ = await cache1.store(fileAt: try makeTempFile(byteCount: 100), forKey: "/v.mp4", fileExtension: "mp4")

        let cache2 = LRUDiskCache(directory: directory, maxSizeInBytes: 1_000_000)
        let cachedURL = await cache2.cachedFileURL(forKey: "/v.mp4", fileExtension: "mp4")
        XCTAssertNotNil(cachedURL)
    }

    func test_cachedFileURL_bumpsModificationDate_soRecencySurvivesReload() async throws {
        let cache = LRUDiskCache(directory: directory, maxSizeInBytes: 250)
        _ = await cache.store(fileAt: try makeTempFile(byteCount: 100), forKey: "a", fileExtension: nil)
        _ = await cache.store(fileAt: try makeTempFile(byteCount: 100), forKey: "b", fileExtension: nil)
        _ = await cache.cachedFileURL(forKey: "a", fileExtension: nil) // touch a -> newer modification date than b

        // A fresh instance rebuilds its index from on-disk modification dates.
        let reloaded = LRUDiskCache(directory: directory, maxSizeInBytes: 250)
        _ = await reloaded.store(fileAt: try makeTempFile(byteCount: 100), forKey: "c", fileExtension: nil) // 300 > 250 -> evict LRU

        let a = await reloaded.cachedFileURL(forKey: "a", fileExtension: nil)
        let b = await reloaded.cachedFileURL(forKey: "b", fileExtension: nil)
        let c = await reloaded.cachedFileURL(forKey: "c", fileExtension: nil)
        XCTAssertNotNil(a, "touched before reload -> survives")
        XCTAssertNil(b, "least recently used -> evicted after reload")
        XCTAssertNotNil(c, "just stored -> survives")
    }

    func test_removeAll_clearsCache() async throws {
        let cache = LRUDiskCache(directory: directory, maxSizeInBytes: 1_000_000)
        _ = await cache.store(fileAt: try makeTempFile(byteCount: 100), forKey: "/v.mp4", fileExtension: "mp4")

        await cache.removeAll()

        let cachedURL = await cache.cachedFileURL(forKey: "/v.mp4", fileExtension: "mp4")
        XCTAssertNil(cachedURL)
    }
}
