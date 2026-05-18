//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the command suggestions.
struct CommandSuggestionsView: View {
    @Injected(\.tokens) private var tokens

    var instantCommands: [CommandHandler]
    var commandSelected: (ComposerCommand) -> Void

    private let itemHeight: CGFloat = 60

    var body: some View {
        VStack(spacing: 0) {
            CommandSuggestionsHeader()

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(0..<instantCommands.count, id: \.self) { i in
                        let command = instantCommands[i]
                        if let displayInfo = command.displayInfo {
                            Button {
                                let instantCommand = ComposerCommand(
                                    id: command.id,
                                    typingSuggestion: TypingSuggestion.empty,
                                    displayInfo: command.displayInfo,
                                    replacesMessageSent: command.replacesMessageSent
                                )
                                commandSelected(instantCommand)
                            } label: {
                                CommandSuggestionView(displayInfo: displayInfo)
                            }
                            .accessibilityElement(children: .contain)
                            .accessibilityIdentifier("CommandSuggestionView_\(command.id)")
                        }
                    }
                }
            }
        }
        .frame(height: viewHeight)
        .animation(.easeInOut, value: instantCommands.count)
        .accessibilityElement(children: .contain)
        .onAppear {
            ComposerAccessibilityAnnouncer.announce(
                L10n.Composer.Suggestions.Commands.accessibilityAnnouncement(instantCommands.count)
            )
        }
    }

    private var viewHeight: CGFloat {
        if instantCommands.isEmpty {
            return 40
        }
        let headerHeight: CGFloat = 44
        let contentHeight = CGFloat(instantCommands.count) * itemHeight + headerHeight
        let maxHeight: CGFloat = 240
        return min(contentHeight, maxHeight)
    }
}

/// View for the command suggestions header.
struct CommandSuggestionsHeader: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    var body: some View {
        HStack {
            Text(L10n.Composer.Suggestions.Commands.header)
                .font(fonts.subheadline)
                .foregroundColor(Color(colors.textTertiary))
                .accessibilityIdentifier("CommandSuggestionsHeader")
            Spacer()
        }
        .padding(.top, tokens.spacingMd)
        .padding(.bottom, tokens.spacingXs)
        .padding(.horizontal, tokens.spacingMd)
    }
}

/// View for a single command suggestion row.
struct CommandSuggestionView: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    var displayInfo: CommandDisplayInfo

    var body: some View {
        HStack(spacing: tokens.spacingXs) {
            Image(uiImage: displayInfo.icon)
                .resizable()
                .scaledToFit()
                .frame(width: tokens.iconSizeMd, height: tokens.iconSizeMd)
                .foregroundColor(Color(colors.textTertiary))
                .accessibilityIdentifier("image\(displayInfo.displayName)")

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: tokens.spacingXxs) {
                    Text(displayInfo.displayName)
                        .font(fonts.body)
                        .foregroundColor(Color(colors.textPrimary))
                        .lineLimit(1)
                    Text(displayInfo.format)
                        .font(fonts.body)
                        .foregroundColor(Color(colors.textTertiary))
                        .lineLimit(1)
                }

                if let description = displayInfo.description {
                    Text(description)
                        .font(fonts.caption1)
                        .foregroundColor(Color(colors.textTertiary))
                }
            }

            Spacer()
        }
        .padding(tokens.spacingSm)
        .padding(.horizontal, tokens.spacingXxs)
    }
}
