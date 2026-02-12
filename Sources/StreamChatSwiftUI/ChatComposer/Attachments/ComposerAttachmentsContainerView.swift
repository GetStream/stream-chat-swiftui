//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Represents either a media asset (image/video) or a file URL in the composer.
public enum ComposerAsset: Identifiable, Equatable {
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
        ScrollViewReader { reader in
            ScrollView(.horizontal) {
                HStack(spacing: tokens.spacingXxs) {
                    ForEach(assets) { asset in
                        assetView(for: asset)
                            .id(asset.id)
                            .padding(tokens.spacingXxs)
                    }
                }
                .padding(.trailing, tokens.spacingXs)
            }
            .padding(.top, tokens.spacingXs)
            .onChange(of: assets) { [assets] newValue in
                if #available(iOS 15, *), newValue.count > assets.count, let last = newValue.last {
                    withAnimation {
                        reader.scrollTo(last.id, anchor: .trailing)
                    }
                }
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
}
