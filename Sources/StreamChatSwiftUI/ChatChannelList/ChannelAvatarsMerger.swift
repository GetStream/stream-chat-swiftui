//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import UIKit

public protocol ChannelAvatarsMerging {
    /// Creates a merged avatar from the provided user images.
    /// - Parameter avatars: the avatars to be merged.
    /// - Returns: optional image, if the creation succeeded.
    func createMergedAvatar(from avatars: [UIImage]) -> UIImage?
}

/// Default implementation of `ChannelAvatarsMerging`.
public class ChannelAvatarsMerger: ChannelAvatarsMerging {
    public init() {
        // Public init.
    }

    @Injected(\.utils) private var utils
    @Injected(\.images) private var images

    /// Context provided utils.
    private lazy var imageProcessor = utils.imageProcessor
    private lazy var imageMerger = utils.imageMerger

    /// Placeholder images.
    private lazy var placeholder1 = images.userAvatarPlaceholder1
    private lazy var placeholder2 = images.userAvatarPlaceholder2
    private lazy var placeholder3 = images.userAvatarPlaceholder3
    private lazy var placeholder4 = images.userAvatarPlaceholder4

    /// Creates a merged avatar from the given images
    /// - Parameter avatars: The individual avatars
    /// - Returns: The merged avatar
    public func createMergedAvatar(from avatars: [UIImage]) -> UIImage? {
        guard !avatars.isEmpty else {
            return nil
        }

        var combinedImage: UIImage?

        let avatarImages = avatars.compactMap { [weak self] in
            self?.imageProcessor.scale(image: $0, to: .avatarThumbnailSize)
        }

        // The half of the width of the avatar
        let halfContainerSize = CGSize(width: CGSize.avatarThumbnailSize.width / 2, height: CGSize.avatarThumbnailSize.height)

        if avatarImages.count == 1 {
            combinedImage = avatarImages[0]
        } else if avatarImages.count == 2 {
            let leftImage = imageProcessor.crop(image: avatarImages[0], to: halfContainerSize)
                ?? placeholder1
            let rightImage = imageProcessor.crop(image: avatarImages[1], to: halfContainerSize)
                ?? placeholder1
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
                    .scale(image: rightCollage ?? placeholder3, to: .avatarThumbnailSize),
                to: halfContainerSize
            )

            combinedImage = imageMerger.merge(
                images:
                [
                    leftImage ?? placeholder1,
                    rightImage ?? placeholder2
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
                    .scale(image: leftCollage ?? placeholder1, to: .avatarThumbnailSize),
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
                    .scale(image: rightCollage ?? placeholder2, to: .avatarThumbnailSize),
                to: halfContainerSize
            )

            combinedImage = imageMerger.merge(
                images: [
                    leftImage ?? placeholder1,
                    rightImage ?? placeholder2
                ],
                orientation: .horizontal
            )
        }

        return combinedImage
    }
}
