//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

// MARK: - User Avatar

@available(iOS 26, *)
#Preview("User Avatar", traits: .fixedLayout(width: 680, height: 380)) {
    @Previewable let avatarURL = URL(string: "https://vignette.wikia.nocookie.net/starwars/images/b/b2/Padmegreenscrshot.jpg")!
    @Previewable let streamChat = StreamChat(chatClient: .init(config: .init(apiKeyString: "Preview")))

    let sizes: [(label: String, size: CGFloat)] = [
        ("2xl", AvatarSize.extraExtraLarge),
        ("xl", AvatarSize.extraLarge),
        ("lg", AvatarSize.large),
        ("md", AvatarSize.medium),
        ("sm", AvatarSize.small),
        ("xs", AvatarSize.extraSmall)
    ]

    VStack(alignment: .leading, spacing: 16) {
        // Column headers
        AvatarPreviewRow(label: "") {
            ForEach(sizes, id: \.size) { item in
                Text(item.label)
                    .font(.caption)
                    .frame(width: AvatarPreviewConstants.columnWidth)
            }
        }

        // Photo
        AvatarPreviewRow(label: "Photo") {
            ForEach(sizes, id: \.size) { item in
                UserAvatar(url: avatarURL, initials: "EC", size: item.size, indicator: .online)
                    .frame(width: AvatarPreviewConstants.columnWidth, height: AvatarPreviewConstants.rowHeight)
            }
        }

        // Initials
        AvatarPreviewRow(label: "Initials") {
            ForEach(sizes, id: \.size) { item in
                UserAvatar(url: nil, initials: "EC", size: item.size, indicator: .online)
                    .frame(width: AvatarPreviewConstants.columnWidth, height: AvatarPreviewConstants.rowHeight)
            }
        }

        // Icon
        AvatarPreviewRow(label: "Icon") {
            ForEach(sizes, id: \.size) { item in
                UserAvatar(url: nil, initials: "", size: item.size, indicator: .online)
                    .frame(width: AvatarPreviewConstants.columnWidth, height: AvatarPreviewConstants.rowHeight)
            }
        }
    }
    .padding()
}

// MARK: - Channel Avatar

@available(iOS 26, *)
#Preview("Channel Avatar", traits: .fixedLayout(width: 1500, height: 350)) {
    @Previewable let channelURL = URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/Aerial_view_of_the_Amazon_Rainforest.jpg/960px-Aerial_view_of_the_Amazon_Rainforest.jpg")!
    @Previewable let avatarURL = URL(string: "https://vignette.wikia.nocookie.net/starwars/images/b/b2/Padmegreenscrshot.jpg")!
    @Previewable let streamChat = StreamChat(chatClient: .init(config: .init(apiKeyString: "Preview")))

    let counts = ["Single", "2", "3", "4", "4+"]

    let sizeGroups: [(label: String, size: CGFloat)] = [
        ("2xl", AvatarSize.extraExtraLarge),
        ("xl", AvatarSize.extraLarge),
        ("lg", AvatarSize.large)
    ]

    let members: (URL?) -> [[(url: URL?, initials: String)]] = { url in
        [
            [(url, "EC")],
            [(url, "EC"), (url, "EC")],
            [(url, "EC"), (url, "EC"), (nil, "EC")],
            [(url, "EC"), (url, "EC"), (nil, "EC"), (url, "EC")],
            [(url, "EC"), (url, "EC"), (nil, "EC"), (url, "EC"), (url, "EC")]
        ]
    }

    HStack(alignment: .top, spacing: 32) {
        ForEach(sizeGroups, id: \.size) { group in
            VStack(alignment: .leading, spacing: 8) {
                // Size label
                Text(group.label)
                    .font(.caption.bold())

                // Count column headers
                AvatarPreviewRow(label: "") {
                    ForEach(Array(counts.enumerated()), id: \.offset) { _, count in
                        Text(count)
                            .font(.caption2)
                            .frame(width: AvatarPreviewConstants.columnWidth)
                    }
                }

                // Custom row
                AvatarPreviewRow(label: "Custom") {
                    ForEach(0..<5, id: \.self) { _ in
                        ChannelAvatar(
                            url: channelURL,
                            size: group.size,
                            stackedPlaceholders: [],
                            memberCount: 0,
                            indicator: .online
                        )
                        .frame(width: AvatarPreviewConstants.columnWidth, height: AvatarPreviewConstants.rowHeight)
                    }
                }

                // Members row
                AvatarPreviewRow(label: "Members") {
                    ForEach(Array(members(avatarURL).enumerated()), id: \.offset) { index, placeholders in
                        ChannelAvatar(
                            url: nil,
                            size: group.size,
                            stackedPlaceholders: placeholders,
                            memberCount: index < 4 ? placeholders.count + 1 : placeholders.count + 2,
                            indicator: .online
                        )
                        .frame(width: AvatarPreviewConstants.columnWidth, height: AvatarPreviewConstants.rowHeight)
                    }
                }
            }
        }
    }
    .padding()
}

// MARK: - Preview Helpers

private enum AvatarPreviewConstants {
    static let labelWidth: CGFloat = 70
    static let columnWidth: CGFloat = 80
    static let rowHeight: CGFloat = 80
}

private struct AvatarPreviewRow<Content: View>: View {
    let label: String
    @ViewBuilder let content: Content

    var body: some View {
        HStack(spacing: 0) {
            Text(label)
                .font(.caption2)
                .frame(width: AvatarPreviewConstants.labelWidth, alignment: .leading)
            content
        }
    }
}
