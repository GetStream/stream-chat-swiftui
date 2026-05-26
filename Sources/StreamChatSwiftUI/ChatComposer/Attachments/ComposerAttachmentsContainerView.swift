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
                    ForEach(displayedAssets) { asset in
                        assetView(for: asset)
                            .padding(tokens.spacingXxs)
                            .id(asset.id)
                    }
                    tailAnchor
                }
                .padding(.trailing, tokens.spacingXs)
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

    /// The order in which assets are rendered inside the horizontal HStack.
    ///
    /// In RTL, the HStack lays its first child at the visible leading edge
    /// (right) and grows toward the trailing edge (left), but the horizontal
    /// ScrollView anchors its content to absolute x=0 regardless. Appending a
    /// new asset to the end of the array therefore inserts it at absolute x=0,
    /// pushing every already-visible attachment toward the right and producing
    /// the visible shift. Reversing the order in RTL means newly appended
    /// assets land at the trailing (off-screen) side of the HStack instead, so
    /// the already-visible attachments keep their position when a new one is
    /// added.
    private var displayedAssets: [ComposerAsset] {
        layoutDirection == .rightToLeft ? assets.reversed() : assets
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
