//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the commands picker.
public struct AttachmentCommandsPickerView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    var instantCommands: [CommandHandler]
    var onCommandSelected: @MainActor (ComposerCommand) -> Void

    public init(
        instantCommands: [CommandHandler] = [],
        onCommandSelected: @escaping @MainActor (ComposerCommand) -> Void
    ) {
        self.instantCommands = instantCommands
        self.onCommandSelected = onCommandSelected
    }

    public var body: some View {
        scrollView
            .background(Color(colors.backgroundCoreElevation1))
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("AttachmentCommandsPickerView")
    }

    @ViewBuilder private var scrollView: some View {
        let scrollView = ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: tokens.spacingMd) {
                headerView

                VStack(alignment: .leading, spacing: 0) {
                    ForEach(instantCommands, id: \.id) { command in
                        if let displayInfo = command.displayInfo {
                            Button {
                                let composerCommand = ComposerCommand(
                                    id: command.id,
                                    typingSuggestion: TypingSuggestion.empty,
                                    displayInfo: displayInfo,
                                    replacesMessageSent: command.replacesMessageSent
                                )
                                onCommandSelected(composerCommand)
                            } label: {
                                AttachmentCommandRow(displayInfo: displayInfo)
                            }
                            .buttonStyle(.plain)
                            .accessibilityElement(children: .combine)
                            .accessibilityIdentifier("AttachmentCommandView_\(command.id)")
                        }
                    }
                }
            }
            .padding(.vertical, tokens.spacingXs)
        }

        // Only allow scrolling/bounce once the content actually overflows
        // the available height, instead of always being interactively
        // scrollable even when everything already fits on screen.
        if #available(iOS 16.4, *) {
            scrollView.scrollBounceBehavior(.basedOnSize)
        } else {
            scrollView
        }
    }

    private var headerView: some View {
        Text(L10n.Composer.Suggestions.Commands.header)
            .font(fonts.bodyBold)
            .foregroundColor(Color(colors.textPrimary))
            .padding(.horizontal, tokens.spacingSm)
            .accessibilityIdentifier("AttachmentCommandsHeader")
    }
}

private struct AttachmentCommandRow: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens
    @Environment(\.sizeCategory) private var sizeCategory

    let displayInfo: CommandDisplayInfo

    var body: some View {
        Group {
            // The name+format columns need more horizontal room than is
            // available at accessibility sizes, so the format hint moves
            // below the name instead of being squeezed onto the same line.
            if sizeCategory.isAccessibilityCategory {
                VStack(alignment: .leading, spacing: tokens.spacingXxs) {
                    HStack(spacing: tokens.spacingSm) {
                        icon
                        nameText
                    }
                    // The format hint has the full row width to itself here,
                    // so it can wrap instead of needing to truncate.
                    formatText(lineLimit: 2)
                }
                // Without this, the row's width shrinks to its own content
                // (which varies per command), and the parent VStack centers
                // rows of differing widths instead of aligning them all left.
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                HStack(spacing: tokens.spacingSm) {
                    icon
                    nameText
                        .frame(minWidth: 80, alignment: .leading)
                    formatText(lineLimit: 1)
                    Spacer()
                }
            }
        }
        .padding(.horizontal, tokens.spacingSm)
        .padding(.vertical, tokens.spacingXs)
        .padding(.horizontal, tokens.spacingXxs)
    }

    private var icon: some View {
        Image(uiImage: displayInfo.icon)
            .resizable()
            .scaledToFit()
            .frame(width: tokens.iconSizeMd, height: tokens.iconSizeMd)
            .foregroundColor(Color(colors.textTertiary))
    }

    private var nameText: some View {
        Text(displayInfo.displayName)
            .font(fonts.bodyBold)
            .foregroundColor(Color(colors.textPrimary))
            .lineLimit(1)
    }

    private func formatText(lineLimit: Int) -> some View {
        Text(displayInfo.format)
            .font(fonts.body)
            .foregroundColor(Color(colors.textTertiary))
            .lineLimit(lineLimit)
    }
}
