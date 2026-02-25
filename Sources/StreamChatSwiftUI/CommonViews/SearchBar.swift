//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Search bar used in the message search.
struct SearchBar: View, KeyboardReadable {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens

    @Binding var text: String
    @State private var isEditing = false

    var body: some View {
        HStack {
            HStack(spacing: tokens.spacingXs) {
                Image(uiImage: images.emptySearch)
                    .customizable()
                    .foregroundColor(Color(colors.inputTextIcon))
                    .frame(width: tokens.iconSizeMd, height: tokens.iconSizeMd)
                    .padding(.leading, tokens.spacingXs)
                
                if #available(iOS 15.0, *) {
                    TextField(
                        "",
                        text: $text,
                        prompt: Text(L10n.Message.Search.title)
                            .foregroundColor(Color(colors.inputTextPlaceholder))
                    )
                    .foregroundColor(Color(colors.textPrimary))
                } else {
                    TextField(L10n.Message.Search.title, text: $text)
                        .font(fonts.body)
                        .foregroundColor(Color(colors.textPrimary))
                }

                if !text.isEmpty {
                    Button(action: {
                        text = ""
                    }) {
                        Image(uiImage: images.searchClose)
                            .customizable()
                            .frame(width: tokens.iconSizeMd, height: tokens.iconSizeMd)
                            .foregroundColor(Color(colors.inputTextIcon))
                    }
                }
            }
            .padding(.horizontal, tokens.spacingSm)
            .padding(.vertical, tokens.spacingSm)
            .background(Color(colors.backgroundElevationElevation1))
            .clipShape(RoundedRectangle(cornerRadius: tokens.radiusMax, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: tokens.radiusMax, style: .continuous)
                    .stroke(Color(colors.inputBorderDefault), lineWidth: 1)
            )
            .padding(.horizontal, tokens.spacingXs)
            .transition(.identity)
            .animation(.easeInOut, value: isEditing)

            if isEditing {
                Button(action: {
                    isEditing = false
                    text = ""
                    resignFirstResponder()
                }) {
                    Text(L10n.Message.Search.cancel)
                        .font(fonts.body)
                        .foregroundColor(Color(colors.accentPrimary))
                }
                .frame(height: tokens.iconSizeLg)
                .padding(.trailing, tokens.spacingXs)
                .transition(.move(edge: .trailing))
                .animation(.easeInOut)
            }
        }
        .padding(.all, tokens.spacingXs)
        .onReceive(keyboardWillChangePublisher) { shown in
            if shown {
                isEditing = true
            }
            if !shown && isEditing {
                isEditing = false
            }
        }
        .accessibilityIdentifier("SearchBar")
    }
}
