//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import UIKit

public protocol ChannelAvatarsMerging: Sendable {
    /// Creates a merged avatar from the provided user images.
    /// - Parameters:
    ///   - avatars: The individual avatars
    ///   - options: Additional data for configuring the generated avatar
    /// - Returns: optional image, if the creation succeeded.
    func createMergedAvatar(from avatars: [UIImage], options: ChannelAvatarsMergerOptions) -> UIImage?
}

public final class ChannelAvatarsMergerOptions: Sendable {
    public let imageProcessor: ImageProcessor
    public let imageMerger: ImageMerging
    public let placeholder1: UIImage
    public let placeholder2: UIImage
    public let placeholder3: UIImage
    public let placeholder4: UIImage
    
    @MainActor public convenience init() {
        let utils = InjectedValues[\.utils]
        let images = InjectedValues[\.images]
        self.init(
            imageProcessor: utils.imageProcessor,
            imageMerger: utils.imageMerger,
            placeholder1: images.userAvatarPlaceholder1,
            placeholder2: images.userAvatarPlaceholder2,
            placeholder3: images.userAvatarPlaceholder3,
            placeholder4: images.userAvatarPlaceholder4
        )
    }
    
    public init(imageProcessor: ImageProcessor, imageMerger: ImageMerging, placeholder1: UIImage, placeholder2: UIImage, placeholder3: UIImage, placeholder4: UIImage) {
        self.imageProcessor = imageProcessor
        self.imageMerger = imageMerger
        self.placeholder1 = placeholder1
        self.placeholder2 = placeholder2
        self.placeholder3 = placeholder3
        self.placeholder4 = placeholder4
    }
}

/// Default implementation of `ChannelAvatarsMerging`.
public final class ChannelAvatarsMerger: ChannelAvatarsMerging {
    public init() {
        // Public init.
    }
    
    /// Creates a merged avatar from the given images
    /// - Parameters:
    ///   - avatars: The individual avatars
    ///   - options: Additional data for configuring the generated avatar
    /// - Returns: The merged avatar
    public func createMergedAvatar(from avatars: [UIImage], options: ChannelAvatarsMergerOptions) -> UIImage? {
        guard !avatars.isEmpty else {
            return nil
        }
    
        let imageProcessor = options.imageProcessor
        let imageMerger = options.imageMerger
        var combinedImage: UIImage?

        let avatarImages = avatars.compactMap {
            imageProcessor.scale(image: $0, to: .avatarThumbnailSize)
        }

        // The half of the width of the avatar
        let halfContainerSize = CGSize(width: CGSize.avatarThumbnailSize.width / 2, height: CGSize.avatarThumbnailSize.height)

        if avatarImages.count == 1 {
            combinedImage = avatarImages[0]
        } else if avatarImages.count == 2 {
            let leftImage = imageProcessor.crop(image: avatarImages[0], to: halfContainerSize)
                ?? options.placeholder1
            let rightImage = imageProcessor.crop(image: avatarImages[1], to: halfContainerSize)
                ?? options.placeholder1
            combinedImage = imageMerger.merge(
                images: [
                    leftImage,
                    rightImage
                ],
                orientation: .horizontal
            )
        } else if avatarImages.count == 3 {
            let leftImage = imageProcessor.crop(image: avatarImages[0], to: halfContainerSize)

            let rightCollage = imageMerger.merge(
                images: [
                    avatarImages[1],
                    avatarImages[2]
                ],
                orientation: .vertical
            )

            let rightImage = imageProcessor.crop(
                image: imageProcessor
                    .scale(image: rightCollage ?? options.placeholder3, to: .avatarThumbnailSize),
                to: halfContainerSize
            )

            combinedImage = imageMerger.merge(
                images:
                [
                    leftImage ?? options.placeholder1,
                    rightImage ?? options.placeholder2
                ],
                orientation: .horizontal
            )
        } else if avatarImages.count == 4 {
            let leftCollage = imageMerger.merge(
                images: [
                    avatarImages[0],
                    avatarImages[2]
                ],
                orientation: .vertical
            )

            let leftImage = imageProcessor.crop(
                image: imageProcessor
                    .scale(image: leftCollage ?? options.placeholder1, to: .avatarThumbnailSize),
                to: halfContainerSize
            )

            let rightCollage = imageMerger.merge(
                images: [
                    avatarImages[1],
                    avatarImages[3]
                ],
                orientation: .vertical
            )

            let rightImage = imageProcessor.crop(
                image: imageProcessor
                    .scale(image: rightCollage ?? options.placeholder2, to: .avatarThumbnailSize),
                to: halfContainerSize
            )

            combinedImage = imageMerger.merge(
                images: [
                    leftImage ?? options.placeholder1,
                    rightImage ?? options.placeholder2
                ],
                orientation: .horizontal
            )
        }

        return combinedImage
    }
}
