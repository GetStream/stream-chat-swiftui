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
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: tokens.spacingXs) {
                headerView

                VStack(spacing: tokens.spacingXs) {
                    ForEach(commandItems) { item in
                        AttachmentCommandRow(item: item)
                            .contentShape(Rectangle())
                            .highPriorityGesture(
                                TapGesture().onEnded {
                                    handleSelection(item)
                                }
                            )
                            .accessibilityElement(children: .contain)
                            .accessibilityIdentifier("AttachmentCommandView_\(item.id)")
                    }
                }
            }
            .padding(.horizontal, tokens.spacingSm)
            .padding(.vertical, tokens.spacingXs)
        }
        .background(Color(colors.background))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("AttachmentCommandsPickerView")
    }

    private var headerView: some View {
        Text(L10n.Composer.Suggestions.Commands.header)
            .font(fonts.bodyBold)
            .foregroundColor(Color(colors.text))
            .padding(.top, tokens.spacingXs)
            .padding(.bottom, tokens.spacingXxs)
            .accessibilityIdentifier("AttachmentCommandsHeader")
    }

    private var commandItems: [CommandItem] {
        instantCommands.compactMap { handler in
            guard let displayInfo = handler.displayInfo else {
                return nil
            }
            return CommandItem(
                id: handler.id,
                displayInfo: displayInfo,
                replacesMessageSent: handler.replacesMessageSent,
                usesTintedIcon: shouldUseTintedIcon(displayInfo.icon)
            )
        }
    }

    private func shouldUseTintedIcon(_ image: UIImage) -> Bool {
        image.renderingMode == .alwaysTemplate || image.isSymbolImage
    }

    private func handleSelection(_ item: CommandItem) {
        let command = ComposerCommand(
            id: item.id,
            typingSuggestion: TypingSuggestion.empty,
            displayInfo: item.displayInfo,
            replacesMessageSent: item.replacesMessageSent
        )
        onCommandSelected(command)
    }
}

private struct AttachmentCommandRow: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    let item: CommandItem

    var body: some View {
        HStack(spacing: tokens.spacingSm) {
            iconView
                .frame(width: tokens.iconSizeMd, height: tokens.iconSizeMd)
                .accessibilityIdentifier("AttachmentCommandIcon_\(item.id)")

            Text(item.displayInfo.displayName)
                .font(fonts.bodyBold)
                .foregroundColor(Color(colors.textPrimary))

            Text(item.displayInfo.format)
                .font(fonts.body)
                .foregroundColor(Color(colors.textTertiary))

            Spacer()
        }
        .padding(.vertical, tokens.spacingSm)
    }

    @ViewBuilder
    private var iconView: some View {
        let image = Image(uiImage: item.displayInfo.icon)
        if item.usesTintedIcon {
            image
                .customizable()
                .foregroundColor(Color(colors.textSecondary))
        } else {
            image
                .resizable()
                .scaledToFit()
        }
    }
}

struct CommandItem: Identifiable {
    let id: String
    let displayInfo: CommandDisplayInfo
    let replacesMessageSent: Bool
    let usesTintedIcon: Bool
}
