//
// Copyright © 2022 Stream.io Inc. All rights reserved.
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
    
    var body: some View {
        VStack {
            InstantCommandsHeader()
                .standardPadding()
            
            ForEach(0..<instantCommands.count) { i in
                let command = instantCommands[i]
                if let displayInfo = command.displayInfo {
                    InstantCommandView(displayInfo: displayInfo)
                        .standardPadding()
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
                }
            }
        }
        .background(Color(colors.background))
        .modifier(ShadowViewModifier())
        .padding(.all, 8)
        .animation(.spring())
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
            Text(L10n.Composer.Suggestions.Commands.header)
                .font(fonts.body)
                .foregroundColor(Color(colors.textLowEmphasis))
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
