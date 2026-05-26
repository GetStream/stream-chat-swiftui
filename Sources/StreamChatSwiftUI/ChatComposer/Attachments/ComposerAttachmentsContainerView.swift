//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Represents either a media asset (image/video) or a file URL in the composer.
public enum ComposerAsset: Identifiable, Equatable, Sendable {
    case addedAsset(AddedAsset)
    case addedFile(URL)

    public var id: String {
        switch self {
        case .addedAsset(let asset): return asset.id
        case .addedFile(let url): return url.absoluteString
        }
    }
}

/// The view responsible for displaying the attachments in the composer.
public struct ComposerAttachmentsContainerView: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    @Environment(\.layoutDirection) private var layoutDirection

    public var assets: [ComposerAsset]
    public var onDiscardAttachment: (String) -> Void

    /// Locally-ordered copy of `assets` used for rendering.
    ///
    /// In LTR this mirrors `assets` exactly. In RTL, newly appended assets are
    /// inserted at index 0 instead. The HStack lays its first child at the
    /// visible leading edge (right) and grows toward the trailing edge, but
    /// the horizontal ScrollView anchors its content to absolute `x = 0`
    /// regardless of layout direction — so appending at the end of the array
    /// places the new asset at `x = 0` and pushes every already-visible
    /// thumbnail rightward. Prepending instead keeps the existing thumbnails
    /// fixed in place when a new asset is added.
    @State private var orderedAssets: [ComposerAsset] = []

    public init(
        assets: [ComposerAsset],
        onDiscardAttachment: @escaping (String) -> Void
    ) {
        self.assets = assets
        self.onDiscardAttachment = onDiscardAttachment
    }

    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: tokens.spacingXs) {
                    ForEach(orderedAssets) { asset in
                        assetView(for: asset)
                            .padding(tokens.spacingXxs)
                            .id(asset.id)
                    }
                    tailAnchor
                }
                .padding(.trailing, tokens.spacingXs)
            }
            .onAppear { syncOrderedAssets(with: assets) }
            .onChange(of: assets) { newAssets in
                syncOrderedAssets(with: newAssets)
            }
            .onChange(of: assets.count) { [assets] newValue in
                guard newValue > assets.count else { return }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    withAnimation {
                        proxy.scrollTo(tailId, anchor: .trailing)
                    }
                }
            }
        }
    }

    /// Reconciles `orderedAssets` with the latest `assets` array.
    ///
    /// New entries (those not already present by id) are inserted at the end
    /// in LTR and at index 0 in RTL; missing entries are removed.
    private func syncOrderedAssets(with newAssets: [ComposerAsset]) {
        let existingIds = Set(orderedAssets.map(\.id))
        let incomingIds = Set(newAssets.map(\.id))

        orderedAssets.removeAll { !incomingIds.contains($0.id) }

        for asset in newAssets where !existingIds.contains(asset.id) {
            if layoutDirection == .rightToLeft {
                orderedAssets.insert(asset, at: 0)
            } else {
                orderedAssets.append(asset)
            }
        }
    }

    @ViewBuilder
    private func assetView(for asset: ComposerAsset) -> some View {
        switch asset {
        case .addedAsset(let attachment):
            attachmentView(for: attachment)
        case .addedFile(let url):
            ComposerFileAttachmentView(
                url: url,
                onDiscardAttachment: onDiscardAttachment
            )
        }
    }

    @ViewBuilder
    private func attachmentView(for attachment: AddedAsset) -> some View {
        switch attachment.type {
        case .video:
            ComposerVideoAttachmentView(
                attachment: attachment,
                onDiscardAttachment: onDiscardAttachment
            )
        case .image:
            ComposerImageAttachmentView(
                attachment: attachment,
                onDiscardAttachment: onDiscardAttachment
            )
        }
    }

    // Workaround to make scrolling to the end more precise.
    private var tailAnchor: some View {
        Color.clear
            .frame(height: 0)
            .id(tailId)
    }

    private let tailId = "tail"
}
