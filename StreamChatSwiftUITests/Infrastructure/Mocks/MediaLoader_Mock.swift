//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import AVKit
import Foundation
@testable import StreamChat
import StreamChatCommonUI
@testable import StreamChatSwiftUI
import UIKit
import XCTest

/// Mock implementation of `MediaLoader`.
///
/// Returns images based on URL content when known test image names are present
/// (yoda, chewbacca, r2, vader), otherwise falls back to `defaultLoadedImage`.
class MediaLoader_Mock: MediaLoader, @unchecked Sendable {
    static let defaultLoadedImage = XCTestCase.TestImages.yoda.image
    var loadImageCalled = false
    var loadImageCallCount = 0
    var loadedURLs: [URL?] = []
    var loadImageOptions: [ImageLoadOptions] = []
    var loadVideoPreviewWithAttachmentCalled = false
    var loadVideoPreviewAtURLCalled = false
    var loadVideoPreviewOptions: [VideoLoadOptions] = []
    var loadVideoAssetOptions: [VideoLoadOptions] = []

    func loadImage(
        url: URL?,
        options: ImageLoadOptions,
        completion: @escaping @MainActor (Result<MediaLoaderImage, Error>) -> Void
    ) {
        StreamConcurrency.onMain {
            loadImageCalled = true
            loadImageCallCount += 1
            loadedURLs.append(url)
            loadImageOptions.append(options)
            let image = imageForURL(url)
            completion(.success(MediaLoaderImage(image: image)))
        }
    }

    func loadVideoAsset(
        at url: URL,
        options: VideoLoadOptions,
        completion: @escaping @MainActor (Result<MediaLoaderVideoAsset, Error>) -> Void
    ) {
        StreamConcurrency.onMain {
            loadVideoAssetOptions.append(options)
            completion(.success(MediaLoaderVideoAsset(asset: AVURLAsset(url: url))))
        }
    }

    func loadVideoPreview(
        with attachment: ChatMessageVideoAttachment,
        options: VideoLoadOptions,
        completion: @escaping @MainActor (Result<MediaLoaderVideoPreview, Error>) -> Void
    ) {
        StreamConcurrency.onMain {
            loadVideoPreviewWithAttachmentCalled = true
            loadVideoPreviewOptions.append(options)
            completion(.success(MediaLoaderVideoPreview(image: Self.defaultLoadedImage)))
        }
    }

    func loadVideoPreview(
        at url: URL,
        options: VideoLoadOptions,
        completion: @escaping @MainActor (Result<MediaLoaderVideoPreview, Error>) -> Void
    ) {
        StreamConcurrency.onMain {
            loadVideoPreviewAtURLCalled = true
            loadVideoPreviewOptions.append(options)
            completion(.success(MediaLoaderVideoPreview(image: Self.defaultLoadedImage)))
        }
    }

    func loadFileRequest(
        for url: URL,
        options: DownloadFileRequestOptions,
        completion: @escaping @MainActor (Result<MediaLoaderFileRequest, Error>) -> Void
    ) {
        StreamConcurrency.onMain {
            completion(.success(MediaLoaderFileRequest(urlRequest: URLRequest(url: url))))
        }
    }

    /// Synchronous URL-to-image mapping used both by the async `loadImage`
    /// path and by the snapshot-test sync hook installed in
    /// `StreamChatTestCase`.
    func imageForURL(_ url: URL?) -> UIImage {
        guard let url else { return Self.defaultLoadedImage }
        let urlString = url.absoluteString
        if urlString.contains("chewbacca") {
            return XCTestCase.TestImages.chewbacca.image
        } else if urlString.contains("r2") || urlString.contains("r2-d2") {
            return XCTestCase.TestImages.r2.image
        } else if urlString.contains("vader") {
            return XCTestCase.TestImages.vader.image
        } else {
            return Self.defaultLoadedImage
        }
    }
}
