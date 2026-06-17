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
        switch suggestion.suggestion {
        case let user as MentionSuggestion.UserSuggestion:
            factory.makeUserAvatarView(
                options: .init(
                    user: user.user,
                    size: AvatarSize.medium,
                    showsIndicator: false
                )
            )
        case is MentionSuggestion.HereSuggestion:
            MentionIconView(icon: images.mentionHere, iconSize: tokens.iconSizeSm)
        case is MentionSuggestion.ChannelSuggestion:
            MentionIconView(icon: images.mentionChannel, iconSize: tokens.iconSizeSm)
        case is MentionSuggestion.RoleSuggestion:
            MentionIconView(icon: images.mentionRole, iconSize: tokens.iconSizeSm)
        case is MentionSuggestion.GroupSuggestion:
            MentionIconView(icon: images.mentionGroup, iconSize: tokens.iconSizeSm)
        default:
            EmptyView()
        }
    }

    private var title: String {
        switch suggestion.suggestion {
        case let user as MentionSuggestion.UserSuggestion:
            return user.user.name ?? user.user.id
        case is MentionSuggestion.HereSuggestion:
            return "@here"
        case is MentionSuggestion.ChannelSuggestion:
            return "@channel"
        case let role as MentionSuggestion.RoleSuggestion:
            return "@\(role.role.name)"
        case let group as MentionSuggestion.GroupSuggestion:
            return "@\(group.group.name)"
        default:
            return "@\(suggestion.mentionText)"
        }
    }

    private var subtitle: String? {
        switch suggestion.suggestion {
        case is MentionSuggestion.HereSuggestion:
            return L10n.Composer.Suggestions.Mentions.Here.description
        case is MentionSuggestion.ChannelSuggestion:
            return L10n.Composer.Suggestions.Mentions.Channel.description
        case let role as MentionSuggestion.RoleSuggestion:
            return L10n.Composer.Suggestions.Mentions.Role.description(role.role.name)
        case let group as MentionSuggestion.GroupSuggestion:
            return L10n.Composer.Suggestions.Mentions.Group.members(group.group.members.count)
        default:
            return nil
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
