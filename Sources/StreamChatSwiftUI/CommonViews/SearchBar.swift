//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Search bar used in the message search.
struct SearchBar: View, KeyboardReadable {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.images) private var images

    @Binding var text: String
    @State private var isEditing = false

    var body: some View {
        HStack {
            TextField(L10n.Message.Search.title, text: $text)
                .padding(8)
                .padding(.leading, 8)
                .padding(.horizontal, 24)
                .background(Color(colors.background1))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    HStack {
                        Image(uiImage: images.emptySearch)
                            .customizable()
                            .foregroundColor(Color(colors.textLowEmphasis))
                            .frame(maxHeight: 18)
                            .padding(.leading, 12)

                        Spacer()

                        if !text.isEmpty {
                            Button(action: {
                                text = ""
                            }) {
                                Image(uiImage: images.searchClose)
                                    .customizable()
                                    .frame(width: 18, height: 18)
                                    .foregroundColor(Color(colors.textLowEmphasis))
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .padding(.horizontal, 8)
                .transition(.identity)
                .animation(.easeInOut, value: isEditing)

            if isEditing {
                Button(action: {
                    isEditing = false
                    text = ""
                    // Dismiss the keyboard
                    resignFirstResponder()
                }) {
                    Text(L10n.Message.Search.cancel)
                        .foregroundColor(Color(colors.accentPrimary))
                }
                .frame(height: 20)
                .padding(.trailing, 8)
                .transition(.move(edge: .trailing))
                .animation(.easeInOut)
            }
        }
        .padding(.vertical, 8)
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
