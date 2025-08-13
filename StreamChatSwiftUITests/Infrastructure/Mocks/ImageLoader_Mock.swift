//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChat
import StreamChatSwiftUI
import UIKit
import XCTest

class ImageLoader_Mock: ImageLoading {
    static let defaultLoadedImage = UIImage(systemName: "checkmark")!

    func loadImage(
        url: URL?,
        imageCDN: ImageCDN,
        resize: Bool,
        preferredSize: CGSize?,
        completion: @escaping ((Result<UIImage, Error>) -> Void)
    ) {
        // Check if this is a test URL and return appropriate test image
        if let url = url, url.scheme == "test" {
            let testImage = getTestImage(for: url)
            completion(.success(testImage))
        } else {
            // For non-test URLs, return a default test image
            completion(.success(Self.defaultLoadedImage))
        }
    }

    func loadImages(
        from urls: [URL],
        placeholders: [UIImage],
        loadThumbnails: Bool,
        thumbnailSize: CGSize,
        imageCDN: ImageCDN,
        completion: @escaping (([UIImage]) -> Void)
    ) {
        let result = urls.map { url in
            if url.scheme == "test" {
                return getTestImage(for: url)
            } else {
                return Self.defaultLoadedImage
            }
        }
        completion(result)
    }

    // MARK: - Private methods

    private func getTestImage(for url: URL) -> UIImage {
        // Extract filename from test URL by removing the scheme
        let urlString = url.absoluteString
        let filename = urlString.replacingOccurrences(of: "test://", with: "").lowercased()

        if filename.contains("chewbacca") {
            return XCTestCase.TestImages.chewbacca.image
        } else if filename.contains("r2") {
            return XCTestCase.TestImages.r2.image
        } else if filename.contains("vader") {
            return XCTestCase.TestImages.vader.image
        } else {
            return XCTestCase.TestImages.yoda.image
        }
    }
}
