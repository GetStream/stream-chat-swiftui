//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the enhanced mention suggestions (users, broadcasts, roles and groups).
public struct MentionSuggestionsView<Factory: ViewFactory>: View {
    @Injected(\.tokens) private var tokens

    var factory: Factory
    private let itemHeight: CGFloat = 48

    var suggestions: [MentionSuggestion]
    var suggestionSelected: (MentionSuggestion) -> Void

    public init(
        factory: Factory = DefaultViewFactory.shared,
        suggestions: [MentionSuggestion],
        suggestionSelected: @escaping (MentionSuggestion) -> Void
    ) {
        self.factory = factory
        self.suggestions = suggestions
        self.suggestionSelected = suggestionSelected
    }

    public var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(suggestions.enumerated()), id: \.element.id) { index, suggestion in
                    MentionSuggestionView(
                        factory: factory,
                        suggestion: suggestion,
                        suggestionSelected: suggestionSelected
                    )
                    .accessibilityElement(children: .combine)
                    .accessibilityHint(
                        Text(
                            L10n.Composer.Suggestions.User.accessibilityLabel(
                                "",
                                index + 1,
                                suggestions.count
                            )
                        )
                    )
                }
            }
        }
        .frame(height: viewHeight)
        .animation(.easeInOut, value: suggestions.count)
        .onAppear {
            ComposerAccessibilityAnnouncer.announce(
                L10n.Composer.Suggestions.Mentions.accessibilityAnnouncement(suggestions.count)
            )
        }
    }

    private var viewHeight: CGFloat {
        let maxVisible: CGFloat = 4.5
        let contentHeight = CGFloat(suggestions.count) * itemHeight
        let maxHeight = maxVisible * itemHeight
        let minHeight = itemHeight
        return max(minHeight, min(contentHeight, maxHeight))
    }
}

/// A single row in the enhanced mention suggestions list.
public struct MentionSuggestionView<Factory: ViewFactory>: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens

    var factory: Factory
    var suggestion: MentionSuggestion
    var suggestionSelected: (MentionSuggestion) -> Void

    public init(
        factory: Factory = DefaultViewFactory.shared,
        suggestion: MentionSuggestion,
        suggestionSelected: @escaping (MentionSuggestion) -> Void
    ) {
        self.factory = factory
        self.suggestion = suggestion
        self.suggestionSelected = suggestionSelected
    }

    public var body: some View {
        Button {
            suggestionSelected(suggestion)
        } label: {
            HStack(spacing: tokens.spacingSm) {
                leadingView

                VStack(alignment: .leading, spacing: tokens.spacingXxxs) {
                    Text(title)
                        .lineLimit(1)
                        .font(fonts.body)
                        .foregroundColor(Color(colors.textPrimary))

                    if let subtitle {
                        Text(subtitle)
                            .lineLimit(1)
                            .font(fonts.footnote)
                            .foregroundColor(Color(colors.textTertiary))
                    }
                }

                Spacer()
            }
            .frame(minHeight: 48)
            .padding(.horizontal, tokens.spacingSm)
        }
    }

    @ViewBuilder
    private var leadingView: some View {
        switch suggestion {
        case let .user(user):
            factory.makeUserAvatarView(
                options: .init(
                    user: user,
                    size: AvatarSize.medium,
                    showsIndicator: false
                )
            )
        case .here, .channel, .role, .group:
            if let icon {
                MentionIconView(icon: icon, iconSize: tokens.iconSizeSm)
            }
        }
    }

    private var icon: UIImage? {
        switch suggestion {
        case .here:
            return images.mentionHere
        case .channel:
            return images.mentionChannel
        case .role:
            return images.mentionRole
        case .group:
            return images.mentionGroup
        case .user:
            return nil
        }
    }

    private var title: String {
        switch suggestion {
        case let .user(user):
            return user.name ?? user.id
        case .here:
            return "@here"
        case .channel:
            return "@channel"
        case let .role(role):
            return "@\(role.name)"
        case let .group(group):
            return "@\(group.name)"
        }
    }

    private var subtitle: String? {
        switch suggestion {
        case .user:
            return nil
        case .here:
            return L10n.Composer.Suggestions.Mentions.Here.description
        case .channel:
            return L10n.Composer.Suggestions.Mentions.Channel.description
        case let .role(role):
            return L10n.Composer.Suggestions.Mentions.Role.description(role.name)
        case let .group(group):
            return L10n.Composer.Suggestions.Mentions.Group.members(group.members.count)
        }
    }
}

/// The circular icon shown next to broadcast, role and group mention suggestions.
struct MentionIconView: View {
    @Injected(\.colors) private var colors

    var icon: UIImage
    var iconSize: CGFloat

    var body: some View {
        Image(uiImage: icon)
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(Color(colors.textPrimary))
            .frame(width: iconSize, height: iconSize)
            .frame(width: AvatarSize.medium, height: AvatarSize.medium)
            .background(Color(colors.backgroundCoreSurfaceSubtle))
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color(colors.borderCoreSubtle), lineWidth: 1)
            )
    }
}
