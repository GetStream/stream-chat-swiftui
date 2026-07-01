//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import AVKit
@testable import StreamChat
import StreamChatCommonUI
@testable import StreamChatSwiftUI
import XCTest

final class StreamVideoPlayer_AVPlayerLoader_Tests: XCTestCase {
    private var root: URL!
    private var cacheDirectory: URL!
    private var tempDirectory: URL!
    private let fileManager = FileManager.default

    override func setUpWithError() throws {
        try super.setUpWithError()
        root = fileManager.temporaryDirectory
            .appendingPathComponent("StreamVideoPlayer_AVPlayerLoader_Tests", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        cacheDirectory = root.appendingPathComponent("cache", isDirectory: true)
        tempDirectory = root.appendingPathComponent("temps", isDirectory: true)
        try fileManager.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? fileManager.removeItem(at: root)
        root = nil
        cacheDirectory = nil
        tempDirectory = nil
        try super.tearDownWithError()
    }

    @MainActor
    func test_load_whenCacheDisabled_streamsRemoteAndSkipsPrefetch() async throws {
        let url = URL(string: "https://example.com/video.mp4")!
        let mediaLoader = MediaLoaderSpy(videoAssetResult: .success(MediaLoaderVideoAsset(asset: AVURLAsset(url: url))))
        let player = AVPlayer()
        let provider = AVPlayerProviderSpy(result: .success(player))
        let loader = makeLoader(url: url, mediaLoader: mediaLoader, avPlayerProvider: provider, cacheEnabled: false)

        let result = await load(loader)

        XCTAssertTrue(try XCTUnwrap(result.get()) === player)
        XCTAssertEqual(mediaLoader.loadedVideoAssetURLs, [url])
        XCTAssertEqual(mediaLoader.loadedFileRequestURLs, [])
        XCTAssertEqual(provider.receivedAssets.count, 1)
    }

    @MainActor
    func test_load_whenURLIsNotCacheable_streamsRemoteAndSkipsPrefetch() async throws {
        let urls = [
            URL(fileURLWithPath: "/tmp/local-upload.mov"),
            URL(string: "https://example.com/video.m3u8")!
        ]

        for url in urls {
            let mediaLoader = MediaLoaderSpy(videoAssetResult: .success(MediaLoaderVideoAsset(asset: AVURLAsset(url: url))))
            let provider = AVPlayerProviderSpy(result: .success(AVPlayer()))
            let loader = makeLoader(url: url, mediaLoader: mediaLoader, avPlayerProvider: provider, cacheEnabled: true)

            _ = await load(loader)

            XCTAssertEqual(mediaLoader.loadedVideoAssetURLs, [url])
            XCTAssertEqual(mediaLoader.loadedFileRequestURLs, [])
            XCTAssertEqual(provider.receivedAssets.count, 1)
        }
    }

    @MainActor
    func test_load_whenCacheMiss_streamsRemoteAndRequestsPrefetch() async throws {
        let url = URL(string: "https://example.com/video.mp4")!
        let mediaLoader = MediaLoaderSpy(
            videoAssetResult: .success(MediaLoaderVideoAsset(asset: AVURLAsset(url: url))),
            fileRequestResult: .failure(LoaderTestError())
        )
        let provider = AVPlayerProviderSpy(result: .success(AVPlayer()))
        let loader = makeLoader(url: url, mediaLoader: mediaLoader, avPlayerProvider: provider)

        _ = await load(loader)

        XCTAssertEqual(mediaLoader.loadedVideoAssetURLs, [url])
        XCTAssertEqual(mediaLoader.loadedFileRequestURLs, [url])
        XCTAssertEqual(provider.receivedAssets.count, 1)
    }

    @MainActor
    func test_load_whenCachedFileIsNotPlayable_evictsCacheAndStreamsRemote() async throws {
        let url = URL(string: "https://example.com/video.mp4")!
        let cache = makeCache()
        _ = await cache.store(fileAt: try makeTempFile(byteCount: 100), forKey: url.path, fileExtension: "mp4")
        let storedURL = await cache.cachedFileURL(forKey: url.path, fileExtension: "mp4")
        XCTAssertNotNil(storedURL)
        let mediaLoader = MediaLoaderSpy(videoAssetResult: .success(MediaLoaderVideoAsset(asset: AVURLAsset(url: url))))
        let provider = AVPlayerProviderSpy(result: .success(AVPlayer()))
        let loader = makeLoader(
            url: url,
            mediaLoader: mediaLoader,
            avPlayerProvider: provider,
            cache: cache,
            isPlayable: { _ in false }
        )

        _ = await load(loader)

        let evictedURL = await cache.cachedFileURL(forKey: url.path, fileExtension: "mp4")
        XCTAssertNil(evictedURL)
        XCTAssertEqual(mediaLoader.loadedVideoAssetURLs, [url])
        XCTAssertEqual(provider.receivedAssets.count, 1)
    }

    @MainActor
    func test_load_whenPlayerProviderFails_completesWithError() async throws {
        let url = URL(string: "https://example.com/video.mp4")!
        let expectedError = LoaderTestError()
        let mediaLoader = MediaLoaderSpy(videoAssetResult: .success(MediaLoaderVideoAsset(asset: AVURLAsset(url: url))))
        let provider = AVPlayerProviderSpy(result: .failure(expectedError))
        let loader = makeLoader(url: url, mediaLoader: mediaLoader, avPlayerProvider: provider, cacheEnabled: false)

        let result = await load(loader)

        do {
            _ = try result.get()
            XCTFail("Expected player provider to fail")
        } catch {
            XCTAssertTrue(error is LoaderTestError)
        }
        XCTAssertEqual(provider.receivedAssets.count, 1)
    }

    @MainActor
    private func makeLoader(
        url: URL,
        mediaLoader: MediaLoaderSpy = MediaLoaderSpy(),
        avPlayerProvider: AVPlayerProviderSpy = AVPlayerProviderSpy(),
        cache: LRUDiskCache? = nil,
        cacheEnabled: Bool = true,
        isPlayable: @escaping @Sendable (URL) async -> Bool = { _ in true }
    ) -> StreamVideoPlayer.AVPlayerLoader {
        StreamVideoPlayer.AVPlayerLoader(
            url: url,
            mediaLoader: mediaLoader,
            avPlayerProvider: avPlayerProvider,
            cache: cache ?? makeCache(),
            cacheEnabled: cacheEnabled,
            isPlayable: isPlayable
        )
    }

    @MainActor
    private func load(_ loader: StreamVideoPlayer.AVPlayerLoader) async -> Result<AVPlayer, Error> {
        await loader.load()
    }

    private func makeCache() -> LRUDiskCache {
        LRUDiskCache(directory: cacheDirectory, maxSizeInBytes: 1_000_000)
    }

    private func makeTempFile(byteCount: Int) throws -> URL {
        let url = tempDirectory.appendingPathComponent(UUID().uuidString)
        try Data(repeating: 0xab, count: byteCount).write(to: url)
        return url
    }
}

private final class MediaLoaderSpy: MediaLoader, @unchecked Sendable {
    var loadedVideoAssetURLs: [URL] = []
    var loadedFileRequestURLs: [URL] = []
    private let videoAssetResult: Result<MediaLoaderVideoAsset, Error>
    private let fileRequestResult: Result<MediaLoaderFileRequest, Error>

    init(
        videoAssetResult: Result<MediaLoaderVideoAsset, Error> = .success(MediaLoaderVideoAsset(asset: AVURLAsset(url: URL(string: "https://example.com/default.mp4")!))),
        fileRequestResult: Result<MediaLoaderFileRequest, Error> = .failure(LoaderTestError())
    ) {
        self.videoAssetResult = videoAssetResult
        self.fileRequestResult = fileRequestResult
    }

    func loadImage(
        url: URL?,
        options: ImageLoadOptions,
        completion: @escaping @MainActor (Result<MediaLoaderImage, Error>) -> Void
    ) {
        Task { @MainActor in completion(.failure(LoaderTestError())) }
    }

    func loadVideoAsset(
        at url: URL,
        options: VideoLoadOptions,
        completion: @escaping @MainActor (Result<MediaLoaderVideoAsset, Error>) -> Void
    ) {
        loadedVideoAssetURLs.append(url)
        let videoAssetResult = self.videoAssetResult
        Task { @MainActor in completion(videoAssetResult) }
    }

    func loadVideoPreview(
        with attachment: ChatMessageVideoAttachment,
        options: VideoLoadOptions,
        completion: @escaping @MainActor (Result<MediaLoaderVideoPreview, Error>) -> Void
    ) {
        Task { @MainActor in completion(.failure(LoaderTestError())) }
    }

    func loadVideoPreview(
        at url: URL,
        options: VideoLoadOptions,
        completion: @escaping @MainActor (Result<MediaLoaderVideoPreview, Error>) -> Void
    ) {
        Task { @MainActor in completion(.failure(LoaderTestError())) }
    }

    func loadFileRequest(
        for url: URL,
        options: DownloadFileRequestOptions,
        completion: @escaping @MainActor (Result<MediaLoaderFileRequest, Error>) -> Void
    ) {
        loadedFileRequestURLs.append(url)
        let fileRequestResult = self.fileRequestResult
        Task { @MainActor in completion(fileRequestResult) }
    }
}

private final class AVPlayerProviderSpy: AVPlayerProvider {
    var receivedAssets: [MediaLoaderVideoAsset] = []
    private let result: Result<AVPlayer, Error>

    init(result: Result<AVPlayer, Error> = .success(AVPlayer())) {
        self.result = result
    }

    func player(
        from videoAsset: MediaLoaderVideoAsset,
        completion: @escaping (Result<AVPlayer, Error>) -> Void
    ) {
        receivedAssets.append(videoAsset)
        completion(result)
    }
}

private struct LoaderTestError: Error {}
