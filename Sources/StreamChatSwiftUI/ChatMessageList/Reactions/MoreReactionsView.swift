//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct MoreReactionsView: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens

    private let columns: [GridItem] = Array(
        repeating: GridItem(.fixed(52), spacing: 12, alignment: .center),
        count: 6
    )

    private let emojiSize: CGFloat = 52

    var onEmojiTap: @MainActor (String) -> Void

    init(onEmojiTap: @escaping @MainActor (String) -> Void) {
        self.onEmojiTap = onEmojiTap
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(availableEmojis, id: \.key) { entry in
                        Button {
                            onEmojiTap(entry.key)
                        } label: {
                            Text(entry.value)
                                .font(.system(size: 30))
                                .frame(width: emojiSize, height: emojiSize)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(entry.value)
                    }
                }
                .padding(.all, tokens.spacingXs)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .accessibilityIdentifier("MoreReactionsView")
        .background(Color(colors.backgroundElevationElevation1).edgesIgnoringSafeArea(.bottom))
        .edgesIgnoringSafeArea(.bottom)
    }
}

extension MoreReactionsView {
    private var availableEmojis: [AvailableEmoji] {
        images.availableEmojis.compactMap { dictionary in
            guard let key = dictionary["key"], let value = dictionary["value"] else { return nil }
            return AvailableEmoji(key: key, value: value)
        }
    }
}

struct AvailableEmoji: Sendable {
    let key: String
    let value: String
}
