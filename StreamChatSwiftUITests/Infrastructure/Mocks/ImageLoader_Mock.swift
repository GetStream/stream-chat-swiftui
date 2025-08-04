//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChat
import StreamChatSwiftUI
import UIKit

class ImageLoader_Mock: ImageLoading {
    static let defaultLoadedImage = UIImage(systemName: "checkmark")!

    func loadImage(
        url: URL?,
        imageCDN: ImageCDN,
        resize: Bool,
        preferredSize: CGSize?,
        completion: @escaping @MainActor @Sendable(Result<UIImage, Error>) -> Void
    ) {
        StreamConcurrency.onMain {
            completion(.success(Self.defaultLoadedImage))
        }
    }

    func loadImages(
        from urls: [URL],
        placeholders: [UIImage],
        loadThumbnails: Bool,
        thumbnailSize: CGSize,
        imageCDN: ImageCDN,
        completion: @escaping @MainActor @Sendable([UIImage]) -> Void
    ) {
        let result = urls.map { _ in
            Self.defaultLoadedImage
        }
        StreamConcurrency.onMain {
            completion(result)
        }
    }
}
