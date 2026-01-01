//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the instant commands suggestions.
struct InstantCommandsView: View {
    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors

    var instantCommands: [CommandHandler]
    var commandSelected: (ComposerCommand) -> Void

    @State private var itemHeight: CGFloat = 40

    var body: some View {
        VStack {
            InstantCommandsHeader()
                .standardPadding()
                .accessibilityElement(children: .contain)

            ScrollView {
                VStack {
                    ForEach(0..<instantCommands.count, id: \.self) { i in
                        let command = instantCommands[i]
                        if let displayInfo = command.displayInfo {
                            InstantCommandView(displayInfo: displayInfo)
                                .standardPadding()
                                .overlay(
                                    GeometryReader { geo in
                                        Color.clear.preference(key: HeightPreferenceKey.self, value: geo.size.height)
                                    }
                                )
                                .onPreferenceChange(HeightPreferenceKey.self) { value in
                                    if let value = value, value != itemHeight {
                                        itemHeight = value
                                    }
                                }
                                .highPriorityGesture(
                                    TapGesture()
                                        .onEnded { _ in
                                            let instantCommand = ComposerCommand(
                                                id: command.id,
                                                typingSuggestion: TypingSuggestion.empty,
                                                displayInfo: command.displayInfo,
                                                replacesMessageSent: command.replacesMessageSent
                                            )
                                            commandSelected(instantCommand)
                                        }
                                )
                                .accessibilityElement(children: .contain)
                                .accessibilityIdentifier("InstantCommandView")
                        }
                    }
                }
            }
        }
        .background(Color(colors.background))
        .frame(height: viewHeight)
        .modifier(ShadowViewModifier())
        .padding(.all, 8)
        .animation(.spring())
        .accessibilityElement(children: .contain)
    }

    private var viewHeight: CGFloat {
        if instantCommands.isEmpty {
            return 40
        }
        let height = CGFloat(instantCommands.count) * itemHeight + 70
        let maxHeight: CGFloat = 320
        return height > maxHeight ? maxHeight : height
    }
}

/// View for the instant commands header.
struct InstantCommandsHeader: View {
    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors

    var body: some View {
        HStack {
            Image(uiImage: images.smallBolt)
                .renderingMode(.template)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(colors.tintColor)
                .accessibilityIdentifier("InstantCommandsImage")
            Text(L10n.Composer.Suggestions.Commands.header)
                .font(fonts.body)
                .foregroundColor(Color(colors.textLowEmphasis))
                .accessibilityIdentifier("InstantCommandsHeader")
            Spacer()
        }
    }
}

/// View for an instant command entry.
struct InstantCommandView: View {
    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors

    var displayInfo: CommandDisplayInfo

    var body: some View {
        HStack {
            Image(uiImage: displayInfo.icon)
                .accessibilityIdentifier("image\(displayInfo.displayName)")
            Text(displayInfo.displayName)
                .font(fonts.title3)
                .bold()
                .foregroundColor(Color(colors.text))
            Text(displayInfo.format)
                .font(fonts.body)
                .foregroundColor(Color(colors.textLowEmphasis))
            Spacer()
        }
    }
}
