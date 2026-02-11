//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// View for an added image displayed in the composer input.
public struct AddedImageAttachmentsView: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    public var images: [AddedAsset]
    public var onDiscardAttachment: (String) -> Void
    
    private var imageSize: CGFloat = 72

    public init(
        images: [AddedAsset],
        onDiscardAttachment: @escaping (String) -> Void
    ) {
        self.images = images
        self.onDiscardAttachment = onDiscardAttachment
    }
    
    public var body: some View {
        ScrollViewReader { reader in
            ScrollView(.horizontal) {
                HStack(spacing: tokens.spacingXs) {
                    ForEach(images) { attachment in
                        Image(uiImage: attachment.image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: imageSize, height: imageSize)
                            .clipped()
                            .cornerRadius(tokens.messageBubbleRadiusAttachment)
                            .overlay(
                                RoundedRectangle(cornerRadius: tokens.messageBubbleRadiusAttachment)
                                    .strokeBorder(Color(colors.borderCoreOpacity10), lineWidth: 1)
                            )
                            .id(attachment.id)
                            .dismissButtonOverlayModifier {
                                onDiscardAttachment(attachment.id)
                            }
                            .padding(tokens.spacingXxs)
//                            .overlay(
//                                ZStack {
//                                    DiscardAttachmentButton(
//                                        attachmentIdentifier: attachment.id,
//                                        onDiscard: onDiscardAttachment
//                                    )
//
//                                    if attachment.type == .video {
//                                        VideoIndicatorView()
//
//                                        if let duration = attachment.extraData["duration"]?.stringValue {
//                                            VideoDurationIndicatorView(duration: duration)
//                                        }
//                                    }
//                                }
//                            )
                    }
                }
                .padding(.trailing, tokens.spacingXs)
            }
            .frame(height: imageSize)
            .padding(.top, tokens.spacingXs)
            .onChange(of: images) { [images] newValue in
                if #available(iOS 15, *), newValue.count > images.count {
                    let last = newValue.last
                    withAnimation {
                        reader.scrollTo(last?.id, anchor: .trailing)
                    }
                }
            }
        }
    }
}
