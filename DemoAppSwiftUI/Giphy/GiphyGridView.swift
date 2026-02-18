//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

/// Horizontally scrollable grid of Giphy GIFs. Query is driven by composer text; selecting a GIF adds it as a giphy attachment and triggers send.
struct GiphyGridView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    @Binding var searchQuery: String
    var isSelectionDisabled: Bool = false
    var onSelect: (GiphyService.GiphyItem) -> Void
    var onBack: () -> Void

    @State private var items: [GiphyService.GiphyItem] = []
    @State private var loading = false
    @State private var task: Task<Void, Never>?

    private let rowCount = 1
    private let cellSize: CGFloat = 120
    private let spacing: CGFloat = 8
    private var gridHeight: CGFloat {
        cellSize * CGFloat(rowCount) + spacing * CGFloat(rowCount + 1) + 16
    }

    var body: some View {
        VStack(spacing: 0) {
            if loading && items.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if items.isEmpty {
                VStack(spacing: 8) {
                    Text("No GIFs loaded")
                        .font(fonts.body)
                        .foregroundColor(Color(colors.textLowEmphasis))
                    Text("Add a Giphy API key in GiphyService.swift")
                        .font(fonts.footnote)
                        .foregroundColor(Color(colors.textLowEmphasis))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 40)
            } else {
                ScrollView(.horizontal, showsIndicators: true) {
                    LazyHGrid(
                        rows: [GridItem(.fixed(cellSize), spacing: spacing)],
                        alignment: .top,
                        spacing: spacing
                    ) {
                        ForEach(items, id: \.id) { item in
                            GiphyCell(item: item, size: cellSize)
                                .contentShape(Rectangle())
                                .opacity(isSelectionDisabled ? 0.6 : 1)
                                .allowsHitTesting(!isSelectionDisabled)
                                .highPriorityGesture(
                                    TapGesture().onEnded { _ in
                                        if !isSelectionDisabled { onSelect(item) }
                                    }
                                )
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                .frame(height: gridHeight)
            }
        }
        .frame(height: gridHeight)
        .background(Color(colors.background))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(colors.innerBorder), lineWidth: 0.5)
        )
        .padding(.all, 8)
        .onChange(of: searchQuery) { newValue in
            debouncedSearch(query: normalizedQuery(newValue))
        }
        .onAppear {
            // Load immediately on appear (no debounce) so grid isn't empty
            task = Task { await performSearch(query: normalizedQuery(searchQuery)) }
        }
        .onDisappear {
            task?.cancel()
        }
    }

    /// Strip /giphy prefix so we search the topic, not the command; empty -> "trending".
    private func normalizedQuery(_ raw: String) -> String {
        let trimmed = raw
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "/giphy", with: "", options: .caseInsensitive)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "trending" : trimmed
    }

    private func debouncedSearch(query: String) {
        task?.cancel()
        task = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await performSearch(query: query)
        }
    }

    @MainActor
    private func performSearch(query: String) async {
        loading = true
        defer { loading = false }
        do {
            let result = try await GiphyService.search(query: query, limit: 24)
            items = result
        } catch {
            items = []
        }
    }
}

private struct GiphyCell: View {
    let item: GiphyService.GiphyItem
    let size: CGFloat

    var body: some View {
        Group {
            if let url = item.previewURL {
                AnimatedGifView(gifURL: url)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .overlay(Image(systemName: "photo").foregroundColor(.gray))
            }
        }
        .frame(width: size, height: size)
        .clipped()
        .cornerRadius(8)
    }
}
