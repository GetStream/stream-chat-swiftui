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
                HStack(spacing: 0) {
                    headAnchor
                    HStack(spacing: tokens.spacingXs) {
                        ForEach(displayedAssets) { asset in
                            assetView(for: asset)
                                .padding(tokens.spacingXxs)
                                .id(asset.id)
                        }
                    }
                    tailAnchor
                }
                .padding(.trailing, tokens.spacingXs)
            }
            .onChange(of: assets) { [assets] newValue in
                guard newValue.count > assets.count else { return }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    withAnimation {
                        proxy.scrollTo(scrollTargetAnchorId, anchor: .trailing)
                    }
                }
            }
        }
    }

    /// Reverses the asset order in RTL so the newest asset stays on the
    /// visual right (matching LTR). This is avoid bad scrolling animations in RTL.
    private var displayedAssets: [ComposerAsset] {
        layoutDirection == .rightToLeft ? assets.reversed() : assets
    }

    /// The id we scroll to after a new asset is appended.
    /// Always picks the anchor that ends up at the visual right of the
    /// row, so the call site can use `UnitPoint.trailing` unconditionally.
    private var scrollTargetAnchorId: String {
        layoutDirection == .rightToLeft ? headId : tailId
    }

    /// Invisible zero-sized scroll target at the row's leading edge.
    /// Becomes the rightmost view visually in RTL (where it's the
    /// scroll target).
    private var headAnchor: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .id(headId)
    }

    /// Invisible zero-sized scroll target at the row's trailing edge.
    /// Sits at the visual right in LTR (where it's the scroll target).
    private var tailAnchor: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .id(tailId)
    }

    private let headId = "head"
    private let tailId = "tail"

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
}
