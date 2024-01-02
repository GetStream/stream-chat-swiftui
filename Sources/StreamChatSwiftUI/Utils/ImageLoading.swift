//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import UIKit

/// ImageLoading is providing set of functions for downloading of images from URLs.
public protocol ImageLoading: AnyObject {
    /// Load images from a given URLs
    /// - Parameters:
    ///   - urls: The URLs to load the images from
    ///   - placeholders: The placeholder images. Placeholders are used when an image fails to load from a URL. The placeholders are used rotationally
    ///   - loadThumbnails: Should load the images as thumbnails. If this is set to `true`, the thumbnail URL is derived from the `imageCDN` object
    ///   - thumbnailSize: The size of the thumbnail. This parameter is used only if the `loadThumbnails` parameter is true
    ///   - imageCDN: The imageCDN to be used
    ///   - completion: Completion that gets called when all the images finish downloading
    func loadImages(
        from urls: [URL],
        placeholders: [UIImage],
        loadThumbnails: Bool,
        thumbnailSize: CGSize,
        imageCDN: ImageCDN,
        completion: @escaping (([UIImage]) -> Void)
    )

    /// Loads an image from the provided url.
    /// - Parameters:
    ///   - url: The URL to load the images from.
    ///   - imageCDN: The imageCDN to be used
    ///   - resize: whether the image should be resized.
    ///   - preferredSize: if resized, what should be the preferred size.
    ///   - completion: Completion that gets called when all the images finish downloading
    func loadImage(
        url: URL?,
        imageCDN: ImageCDN,
        resize: Bool,
        preferredSize: CGSize?,
        completion: @escaping ((Result<UIImage, Error>) -> Void)
    )
}

public extension ImageLoading {
    func loadImages(
        from urls: [URL],
        placeholders: [UIImage],
        loadThumbnails: Bool = true,
        thumbnailSize: CGSize = .avatarThumbnailSize,
        imageCDN: ImageCDN,
        completion: @escaping (([UIImage]) -> Void)
    ) {
        loadImages(
            from: urls,
            placeholders: placeholders,
            loadThumbnails: loadThumbnails,
            thumbnailSize: thumbnailSize,
            imageCDN: imageCDN,
            completion: completion
        )
    }
}
