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
        switch suggestion.kind {
        case let userSuggestion as MentionSuggestion.User:
            factory.makeUserAvatarView(
                options: .init(
                    user: userSuggestion.user,
                    size: AvatarSize.medium,
                    showsIndicator: false
                )
            )
        case is MentionSuggestion.Here:
            MentionIconView(icon: images.mentionHere, iconSize: tokens.iconSizeSm)
        case is MentionSuggestion.Channel:
            MentionIconView(icon: images.mentionChannel, iconSize: tokens.iconSizeSm)
        case is MentionSuggestion.Role:
            MentionIconView(icon: images.mentionRole, iconSize: tokens.iconSizeSm)
        case is MentionSuggestion.Group:
            MentionIconView(icon: images.mentionGroup, iconSize: tokens.iconSizeSm)
        default:
            EmptyView()
        }
    }

    private var title: String {
        switch suggestion.kind {
        case let userSuggestion as MentionSuggestion.User:
            return userSuggestion.user.name ?? userSuggestion.user.id
        case is MentionSuggestion.Here:
            return "@here"
        case is MentionSuggestion.Channel:
            return "@channel"
        case let roleSuggestion as MentionSuggestion.Role:
            return "@\(roleSuggestion.role.name)"
        case let groupSuggestion as MentionSuggestion.Group:
            return "@\(groupSuggestion.group.name)"
        default:
            return "@\(suggestion.mentionText)"
        }
    }

    private var subtitle: String? {
        switch suggestion.kind {
        case is MentionSuggestion.Here:
            return L10n.Composer.Suggestions.Mentions.Here.description
        case is MentionSuggestion.Channel:
            return L10n.Composer.Suggestions.Mentions.Channel.description
        case let roleSuggestion as MentionSuggestion.Role:
            return L10n.Composer.Suggestions.Mentions.Role.description(roleSuggestion.role.name)
        case let groupSuggestion as MentionSuggestion.Group:
            return L10n.Composer.Suggestions.Mentions.Group.members(groupSuggestion.group.members.count)
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
