//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Combine
import Foundation
import StreamChat
import SwiftUI
import UIKit

/// View model for the more channel actions.
@MainActor open class MoreChannelActionsViewModel: ObservableObject {
    /// Context provided values.
    @Injected(\.utils) private var utils
    @Injected(\.chatClient) private var chatClient
    @Injected(\.images) private var images

    /// Private vars.
    private lazy var channelNameFormatter = utils.channelNameFormatter
    private lazy var imageLoader = utils.imageLoader
    private lazy var imageCDN = utils.imageCDN
    private lazy var placeholder2 = images.userAvatarPlaceholder2

    /// Published vars.
    @Published var channelActions: [ChannelAction]
    @Published var alertShown = false
    @Published var alertAction: ChannelAction? {
        didSet {
            alertShown = alertAction != nil
        }
    }

    @Published var memberAvatars = [String: UIImage]()
    @Published var members = [ChatChannelMember]()

    /// Computed vars.
    public var chatName: String {
        name(for: channel)
    }

    public var subtitleText: String {
        guard let currentUserId = chatClient.currentUserId else {
            return ""
        }

        return channel.onlineInfoText(currentUserId: currentUserId)
    }

    private let channel: ChatChannel

    public init(
        channel: ChatChannel,
        channelActions: [ChannelAction]
    ) {
        self.channelActions = channelActions
        self.channel = channel
        members = channel.lastActiveMembers
    }

    /// Returns an image for a member.
    ///
    /// - Parameter member: the chat channel member.
    /// - Returns: downloaded image or a placeholder.
    public func image(for member: ChatChannelMember) -> UIImage {
        if let image = memberAvatars[member.id] {
            return image
        }

        imageLoader.loadImage(
            url: member.imageURL,
            imageCDN: imageCDN,
            resize: true,
            preferredSize: .avatarThumbnailSize
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(image):
                memberAvatars[member.id] = image
            case let .failure(error):
                log.error("error loading image: \(error.localizedDescription)")
            }
        }

        return placeholder2
    }

    // MARK: - private

    private func name(for channel: ChatChannel) -> String {
        utils.channelNameFormatter.format(
            channel: channel,
            forCurrentUserId: chatClient.currentUserId
        ) ?? ""
    }
}

/// Model describing a channel action.
public struct ChannelAction: Identifiable, @unchecked Sendable {
    public var id: String {
        "\(title)-\(iconName)"
    }

    public let title: String
    public let iconName: String
    public let action: @MainActor () -> Void
    public let confirmationPopup: ConfirmationPopup?
    public let isDestructive: Bool
    public var navigationDestination: AnyView?

    public init(
        title: String,
        iconName: String,
        action: @escaping @MainActor () -> Void,
        confirmationPopup: ConfirmationPopup?,
        isDestructive: Bool
    ) {
        self.title = title
        self.iconName = iconName
        self.action = action
        self.confirmationPopup = confirmationPopup
        self.isDestructive = isDestructive
    }
}

/// Model describing confirmation popup data.
public struct ConfirmationPopup: Sendable {
    public init(title: String, message: String?, buttonTitle: String) {
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
    }

    public let title: String
    public let message: String?
    public let buttonTitle: String
}
