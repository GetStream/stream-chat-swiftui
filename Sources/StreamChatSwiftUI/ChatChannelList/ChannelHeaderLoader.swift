//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import UIKit

@Observable open class ChannelHeaderLoader {
    /// The maximum number of images that combine to form a single avatar
    private let maxNumberOfImagesInCombinedAvatar = 4

    /// Prevents image requests to be executed if they failed previously.
    private var failedImageLoads = Set<String>()

    /// Batches loaded images for update, to improve performance.
    private var scheduledUpdate = false

    /// Context provided utils.
//    internal var imageLoader = InjectedValues[\.utils].imageLoader
//    internal var imageCDN = InjectedValues[\.utils].imageCDN
//    internal var channelAvatarsMerger = InjectedValues[\.utils].channelAvatarsMerger
//    internal var channelNamer = InjectedValues[\.utils].channelNamer
//
//    /// Placeholder images.
//    internal var placeholder1 = InjectedValues[\.images].userAvatarPlaceholder1
//    internal var placeholder2 = InjectedValues[\.images].userAvatarPlaceholder2
//    internal var placeholder3 = InjectedValues[\.images].userAvatarPlaceholder3
//    internal var placeholder4 = InjectedValues[\.images].userAvatarPlaceholder4

    var loadedImages = [String: UIImage]()

    public init() {
        // Public init.
    }

    /// Loads an image for the provided channel.
    /// If the image is not downloaded, placeholder is returned.
    /// - Parameter channel: the provided channel.
    /// - Returns: the available image.
    public func image(for channel: ChatChannel) -> UIImage {
        if let image = loadedImages[channel.cid.rawValue] {
            return image
        }

        if let url = channel.imageURL {
            loadChannelThumbnail(for: channel, from: url)
            return InjectedValues[\.images].userAvatarPlaceholder4
        }

        if channel.isDirectMessageChannel {
            let lastActiveMembers = self.lastActiveMembers(for: channel)
            if let otherMember = lastActiveMembers.first, let url = otherMember.imageURL {
                loadChannelThumbnail(for: channel, from: url)
                return InjectedValues[\.images].userAvatarPlaceholder3
            } else {
                return InjectedValues[\.images].userAvatarPlaceholder4
            }
        } else {
            let activeMembers = lastActiveMembers(for: channel)

            if activeMembers.isEmpty {
                return InjectedValues[\.images].userAvatarPlaceholder4
            }

            let urls = activeMembers
                .compactMap(\.imageURL)
                .prefix(maxNumberOfImagesInCombinedAvatar)

            if urls.isEmpty {
                return InjectedValues[\.images].userAvatarPlaceholder3
            } else {
                loadMergedAvatar(from: channel, urls: Array(urls))
                return InjectedValues[\.images].userAvatarPlaceholder4
            }
        }
    }

    // MARK: - private

    private func loadMergedAvatar(from channel: ChatChannel, urls: [URL]) {
        if failedImageLoads.contains(channel.cid.rawValue) {
            return
        }

        InjectedValues[\.utils].imageLoader.loadImages(
            from: urls,
            placeholders: [],
            loadThumbnails: true,
            thumbnailSize: .avatarThumbnailSize,
            imageCDN: InjectedValues[\.utils].imageCDN
        ) { [weak self] images in
            guard let self = self else { return }
            DispatchQueue.global(qos: .userInteractive).async {
                let image = InjectedValues[\.utils].channelAvatarsMerger.createMergedAvatar(from: images)
                DispatchQueue.main.async {
                    if let image = image {
                        self.loadedImages[channel.cid.rawValue] = image
                    } else {
                        self.failedImageLoads.insert(channel.cid.rawValue)
                    }
                }
            }
        }
    }

    private func loadChannelThumbnail(
        for channel: ChatChannel,
        from url: URL
    ) {
        if failedImageLoads.contains(channel.cid.rawValue) {
            return
        }

        InjectedValues[\.utils].imageLoader.loadImage(
            url: url,
            imageCDN: InjectedValues[\.utils].imageCDN,
            resize: true,
            preferredSize: .avatarThumbnailSize
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(image):
                DispatchQueue.main.async {
                    self.loadedImages[channel.cid.rawValue] = image
                }
            case let .failure(error):
                self.failedImageLoads.insert(channel.cid.rawValue)
                log.error("error loading image: \(error.localizedDescription)")
            }
        }
    }

    private func lastActiveMembers(for channel: ChatChannel) -> [ChatChannelMember] {
        channel.lastActiveMembers
            .sorted { $0.memberCreatedAt < $1.memberCreatedAt }
            .filter { $0.id != InjectedValues[\.chatClient].currentUserId }
    }
}
