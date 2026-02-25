//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatCommonUI
import SwiftUI

/// View for the instant commands suggestions.
struct InstantCommandsView: View {
    @Injected(\.tokens) private var tokens

    var instantCommands: [CommandHandler]
    var commandSelected: (ComposerCommand) -> Void

    private let itemHeight: CGFloat = 60

    var body: some View {
        VStack(spacing: 0) {
            InstantCommandsHeader()

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
                                InstantCommandView(displayInfo: displayInfo)
                            }
                            .accessibilityElement(children: .contain)
                            .accessibilityIdentifier("InstantCommandView_\(command.id)")
                        }
                    }
                }
            }
        }
        .frame(height: viewHeight)
        .animation(.easeInOut, value: instantCommands.count)
        .accessibilityElement(children: .contain)
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

/// View for the instant commands header.
struct InstantCommandsHeader: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    var body: some View {
        HStack {
            Text(L10n.Composer.Suggestions.Commands.header)
                .font(fonts.subheadline)
                .foregroundColor(Color(colors.textLowEmphasis))
                .accessibilityIdentifier("InstantCommandsHeader")
            Spacer()
        }
        .padding(.top, tokens.spacingMd)
        .padding(.bottom, tokens.spacingXs)
        .padding(.horizontal, tokens.spacingMd)
    }
}

/// View for an instant command entry.
struct InstantCommandView: View {
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
                .foregroundColor(Color(colors.textLowEmphasis))
                .accessibilityIdentifier("image\(displayInfo.displayName)")

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: tokens.spacingXxs) {
                    Text(displayInfo.displayName)
                        .font(fonts.body)
                        .foregroundColor(Color(colors.text))
                        .lineLimit(1)
                    Text(displayInfo.format)
                        .font(fonts.body)
                        .foregroundColor(Color(colors.textLowEmphasis))
                        .lineLimit(1)
                }

                if let description = displayInfo.description {
                    Text(description)
                        .font(fonts.caption1)
                        .foregroundColor(Color(colors.textLowEmphasis))
                }
            }

            Spacer()
        }
        .padding(tokens.spacingSm)
        .padding(.horizontal, tokens.spacingXxs)
    }
}

// TODO: Move to Common Module

extension Appearance.Images {
    var commandGiphyIcon: UIImage {
        UIImage(named: "GiphyIcon", in: .streamChatUI, compatibleWith: nil)!
            .withRenderingMode(.alwaysOriginal)
    }

    var commandMuteIcon: UIImage {
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        return UIImage(systemName: "speaker.slash", withConfiguration: config)!
    }

    var commandUnmuteIcon: UIImage {
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        return UIImage(systemName: "speaker.wave.2", withConfiguration: config)!
    }
}
