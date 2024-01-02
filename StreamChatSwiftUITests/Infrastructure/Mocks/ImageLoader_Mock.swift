//
// Copyright © 2024 Stream.io Inc. All rights reserved.
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
        completion: @escaping ((Result<UIImage, Error>) -> Void)
    ) {
        completion(.success(Self.defaultLoadedImage))
    }

    func loadImages(
        from urls: [URL],
        placeholders: [UIImage],
        loadThumbnails: Bool,
        thumbnailSize: CGSize,
        imageCDN: ImageCDN,
        completion: @escaping (([UIImage]) -> Void)
    ) {
        let result = urls.map { _ in
            Self.defaultLoadedImage
        }
        completion(result)
    }
}
