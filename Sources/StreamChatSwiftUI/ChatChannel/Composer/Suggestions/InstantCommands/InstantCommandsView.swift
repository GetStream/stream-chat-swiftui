//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct InstantCommandsView: View {
    
    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    
    var instantCommands: [CommandHandler]
    var commandSelected: (ComposerCommand) -> Void
    
    var body: some View {
        VStack {
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
            .standardPadding()
            
            ForEach(0..<instantCommands.count) { i in
                let command = instantCommands[i]
                if let displayInfo = command.displayInfo {
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
