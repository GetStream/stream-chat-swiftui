//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import UIKit

open class ChannelHeaderLoader: ObservableObject {
    @Injected(\.images) private var images
    @Injected(\.utils) private var utils
    @Injected(\.chatClient) private var chatClient

    /// The maximum number of images that combine to form a single avatar
    private let maxNumberOfImagesInCombinedAvatar = 4

    /// Prevents image requests to be executed if they failed previously.
    private var failedImageLoads = Set<String>()

    /// Batches loaded images for update, to improve performance.
    private var scheduledUpdate = false

    /// Context provided utils.
    internal lazy var imageLoader = utils.imageLoader
    internal lazy var imageCDN = utils.imageCDN
    internal lazy var channelAvatarsMerger = utils.channelAvatarsMerger
    internal lazy var channelNamer = utils.channelNamer

    /// Placeholder images.
    internal lazy var placeholder1 = images.userAvatarPlaceholder1
    internal lazy var placeholder2 = images.userAvatarPlaceholder2
    internal lazy var placeholder3 = images.userAvatarPlaceholder3
    internal lazy var placeholder4 = images.userAvatarPlaceholder4

    var loadedImages = [String: UIImage]() {
        willSet {
            if !scheduledUpdate {
                scheduledUpdate = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.objectWillChange.send()
                    self?.scheduledUpdate = false
                }
            }
        }
    }

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
            return placeholder4
        }

        if channel.isDirectMessageChannel {
            let lastActiveMembers = self.lastActiveMembers(for: channel)
            if let otherMember = lastActiveMembers.first, let url = otherMember.imageURL {
                loadChannelThumbnail(for: channel, from: url)
                return placeholder3
            } else {
                return placeholder4
            }
        } else {
            let activeMembers = lastActiveMembers(for: channel)

            if activeMembers.isEmpty {
                return placeholder4
            }

            let urls = activeMembers
                .compactMap(\.imageURL)
                .prefix(maxNumberOfImagesInCombinedAvatar)

            if urls.isEmpty {
                return placeholder3
            } else {
                loadMergedAvatar(from: channel, urls: Array(urls))
                return placeholder4
            }
        }
    }

    // MARK: - private

    private func loadMergedAvatar(from channel: ChatChannel, urls: [URL]) {
        if failedImageLoads.contains(channel.cid.rawValue) {
            return
        }

        imageLoader.loadImages(
            from: urls,
            placeholders: [],
            loadThumbnails: true,
            thumbnailSize: .avatarThumbnailSize,
            imageCDN: imageCDN
        ) { [weak self] images in
            guard let self = self else { return }
            DispatchQueue.global(qos: .userInteractive).async {
                let image = self.channelAvatarsMerger.createMergedAvatar(from: images)
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

        imageLoader.loadImage(
            url: url,
            imageCDN: imageCDN,
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
            .filter { $0.id != chatClient.currentUserId }
    }
}
