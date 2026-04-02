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
            VStack(alignment: .leading, spacing: tokens.spacingMd) {
                headerView

                VStack(spacing: 0) {
                    ForEach(instantCommands, id: \.id) { command in
                        if let displayInfo = command.displayInfo {
                            AttachmentCommandRow(displayInfo: displayInfo)
                                .contentShape(Rectangle())
                                .highPriorityGesture(
                                    TapGesture().onEnded {
                                        let composerCommand = ComposerCommand(
                                            id: command.id,
                                            typingSuggestion: TypingSuggestion.empty,
                                            displayInfo: displayInfo,
                                            replacesMessageSent: command.replacesMessageSent
                                        )
                                        onCommandSelected(composerCommand)
                                    }
                                )
                                .accessibilityElement(children: .contain)
                                .accessibilityIdentifier("AttachmentCommandView_\(command.id)")
                        }
                    }
                }
            }
            .padding(.vertical, tokens.spacingXs)
        }
        .background(Color(colors.backgroundCoreElevation1))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("AttachmentCommandsPickerView")
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

    let displayInfo: CommandDisplayInfo

    var body: some View {
        HStack(spacing: tokens.spacingSm) {
            Image(uiImage: displayInfo.icon)
                .resizable()
                .scaledToFit()
                .frame(width: tokens.iconSizeMd, height: tokens.iconSizeMd)
                .foregroundColor(Color(colors.textTertiary))

            Text(displayInfo.displayName)
                .font(fonts.bodyBold)
                .foregroundColor(Color(colors.textPrimary))
                .frame(width: 80, alignment: .leading)
                .lineLimit(1)

            Text(displayInfo.format)
                .font(fonts.body)
                .foregroundColor(Color(colors.textTertiary))
                .lineLimit(1)

            Spacer()
        }
        .padding(.horizontal, tokens.spacingSm)
        .padding(.vertical, tokens.spacingXs)
        .padding(.horizontal, tokens.spacingXxs)
    }
}
