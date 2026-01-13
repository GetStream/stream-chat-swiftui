//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct MoreReactionsView: View {
    @Injected(\.colors) private var colors

    private let rows: [GridItem] = Array(
        repeating: GridItem(.fixed(56), spacing: 12, alignment: .center),
        count: 4
    )

    private let emojiSize: CGFloat = 52

    var onEmojiTap: @MainActor (String) -> Void

    init(onEmojiTap: @escaping @MainActor (String) -> Void) {
        self.onEmojiTap = onEmojiTap
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: rows, spacing: 12) {
                    ForEach(Self.orderedEmojiKeys, id: \.self) { key in
                        if let emoji = Self.emojiMap[key] {
                            Button {
                                onEmojiTap(key)
                            } label: {
                                Text(emoji)
                                    .font(.system(size: 30))
                                    .frame(width: emojiSize, height: emojiSize)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(emoji)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .accessibilityIdentifier("MoreReactionsView")
    }
}

extension MoreReactionsView {
    static var emojiValues: [String] {
        InjectedValues[\.images].availableEmojis
    }
    
    private static let emojiMap: [String: String] = {
        var map: [String: String] = [:]
        for emoji in emojiValues {
            map[apiIdentifier(for: emoji)] = emoji
        }
        return map
    }()

    private static let orderedEmojiKeys: [String] = emojiValues.map { apiIdentifier(for: $0) }

    private static func apiIdentifier(for emoji: String) -> String {
        emoji.unicodeScalars
            .map { scalar in
                String(format: "u%04X", scalar.value)
            }
            .joined(separator: "-")
    }
}
