//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Nuke
import NukeUI
import StreamChat
import SwiftUI

public struct ImageAttachmentContainer: View {
    @Injected(\.colors) private var colors
    
    let message: ChatMessage
    let width: CGFloat
    let isFirst: Bool
    @Binding var scrolledId: String?
    
    @State private var galleryShown = false
    @State private var selectedIndex = 0
                
    public var body: some View {
        VStack(
            alignment: message.alignmentInBubble,
            spacing: 0
        ) {
            if let quotedMessage = message.quotedMessage {
                QuotedMessageViewContainer(
                    quotedMessage: quotedMessage,
                    fillAvailableSpace: !message.attachmentCounts.isEmpty,
                    scrolledId: $scrolledId
                )
            }
            
            VStack(
                alignment: message.alignmentInBubble,
                spacing: 0
            ) {
                ImageAttachmentView(
                    message: message,
                    width: width
                ) { index in
                    selectedIndex = index
                    galleryShown = true
                }
                
                if !message.text.isEmpty {
                    HStack {
                        Text(message.text)
                            .standardPadding()
                        Spacer()
                    }
                    .background(Color(backgroundColor))
                }
            }
            .clipped()
        }
        .messageBubble(for: message, isFirst: isFirst)
        .fullScreenCover(isPresented: $galleryShown, onDismiss: {
            self.selectedIndex = 0
        }) {
            GalleryView(
                message: message,
                isShown: $galleryShown,
                selected: selectedIndex
            )
        }
    }
    
    private var backgroundColor: UIColor {
        if message.isSentByCurrentUser {
            if message.type == .ephemeral {
                return colors.background8
            } else {
                return colors.background6
            }
        } else {
            return colors.background8
        }
    }
}

struct ImageAttachmentView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.utils) private var utils
    
    let message: ChatMessage
    let width: CGFloat
    var imageTapped: ((Int) -> Void)? = nil
    
    private let spacing: CGFloat = 2
    private let maxDisplayedImages = 4
    
    private var imageCDN: ImageCDN {
        utils.imageCDN
    }
    
    private var sources: [URL] {
        message.imageAttachments.map { attachment in
            if let state = attachment.uploadingState {
                return state.localFileURL
            } else {
                return attachment.imagePreviewURL
            }
        }
    }
    
    var body: some View {
        Group {
            if sources.count == 1 {
                SingleImageView(
                    source: sources[0],
                    width: width,
                    imageTapped: imageTapped,
                    index: 0
                )
                .withUploadingStateIndicator(for: uploadState(for: 0), url: sources[0])
            } else if sources.count == 2 {
                HStack(spacing: spacing) {
                    MultiImageView(
                        source: sources[0],
                        width: width / 2,
                        height: width,
                        imageTapped: imageTapped,
                        index: 0
                    )
                    .withUploadingStateIndicator(for: uploadState(for: 0), url: sources[0])
                    
                    MultiImageView(
                        source: sources[1],
                        width: width / 2,
                        height: width,
                        imageTapped: imageTapped,
                        index: 1
                    )
                    .withUploadingStateIndicator(for: uploadState(for: 1), url: sources[1])
                }
                .aspectRatio(1, contentMode: .fill)
            } else if sources.count == 3 {
                HStack(spacing: spacing) {
                    MultiImageView(
                        source: sources[0],
                        width: width / 2,
                        height: width,
                        imageTapped: imageTapped,
                        index: 0
                    )
                    .withUploadingStateIndicator(for: uploadState(for: 0), url: sources[0])
                    
                    VStack(spacing: spacing) {
                        MultiImageView(
                            source: sources[1],
                            width: width / 2,
                            height: width / 2,
                            imageTapped: imageTapped,
                            index: 1
                        )
                        .withUploadingStateIndicator(for: uploadState(for: 1), url: sources[1])
                        
                        MultiImageView(
                            source: sources[2],
                            width: width / 2,
                            height: width / 2,
                            imageTapped: imageTapped,
                            index: 2
                        )
                        .withUploadingStateIndicator(for: uploadState(for: 2), url: sources[2])
                    }
                }
                .aspectRatio(1, contentMode: .fill)
            } else if sources.count > 3 {
                HStack(spacing: spacing) {
                    VStack(spacing: spacing) {
                        MultiImageView(
                            source: sources[0],
                            width: width / 2,
                            height: width / 2,
                            imageTapped: imageTapped,
                            index: 0
                        )
                        .withUploadingStateIndicator(for: uploadState(for: 0), url: sources[0])
                        
                        MultiImageView(
                            source: sources[1],
                            width: width / 2,
                            height: width / 2,
                            imageTapped: imageTapped,
                            index: 2
                        )
                        .withUploadingStateIndicator(for: uploadState(for: 1), url: sources[1])
                    }
                    
                    VStack(spacing: spacing) {
                        MultiImageView(
                            source: sources[2],
                            width: width / 2,
                            height: width / 2,
                            imageTapped: imageTapped,
                            index: 1
                        )
                        .withUploadingStateIndicator(for: uploadState(for: 2), url: sources[2])
                        
                        ZStack {
                            MultiImageView(
                                source: sources[3],
                                width: width / 2,
                                height: width / 2,
                                imageTapped: imageTapped,
                                index: 3
                            )
                            .withUploadingStateIndicator(for: uploadState(for: 3), url: sources[3])
                            
                            if notDisplayedImages > 0 {
                                Color.black.opacity(0.4)
                                
                                Text("+\(notDisplayedImages)")
                                    .foregroundColor(Color(colors.staticColorText))
                                    .font(fonts.title)
                            }
                        }
                        .frame(width: width / 2, height: width / 2)
                    }
                }
                .aspectRatio(1, contentMode: .fill)
            }
        }
        .frame(maxWidth: width)
    }
    
    private var notDisplayedImages: Int {
        sources.count > maxDisplayedImages ? sources.count - maxDisplayedImages : 0
    }
    
    private func uploadState(for index: Int) -> AttachmentUploadingState? {
        message.imageAttachments[index].uploadingState
    }
}

struct SingleImageView: View {
    let source: URL
    let width: CGFloat
    var imageTapped: ((Int) -> Void)? = nil
    var index: Int?
    
    var body: some View {
        LazyLoadingImage(
            source: source,
            width: width,
            height: 3 * width / 4,
            imageTapped: imageTapped,
            index: index
        )
        .frame(width: width, height: 3 * width / 4)
    }
}

struct MultiImageView: View {
    let source: URL
    let width: CGFloat
    let height: CGFloat
    var imageTapped: ((Int) -> Void)? = nil
    var index: Int?
    
    var body: some View {
        LazyLoadingImage(
            source: source,
            width: width,
            height: height,
            imageTapped: imageTapped,
            index: index
        )
        .frame(width: width, height: height)
        .clipped()
    }
}

struct LazyLoadingImage: View {
    @Injected(\.utils) private var utils
    
    @State private var image: UIImage?
    @State private var error: Error?
    
    let source: URL
    let width: CGFloat
    let height: CGFloat
    var resize: Bool = true
    var imageTapped: ((Int) -> Void)? = nil
    var index: Int?
    var onImageLoaded: (UIImage) -> Void = { _ in }
    
    var body: some View {
        ZStack {
            if let image = image {
                imageView(for: image)
                if let imageTapped = imageTapped {
                    // NOTE: needed because of bug with SwiftUI.
                    // The click area expands outside the image view (although not visible).
                    Rectangle()
                        .opacity(0.000001)
                        .frame(width: width, height: height)
                        .clipped()
                        .allowsHitTesting(true)
                        .highPriorityGesture(
                            TapGesture()
                                .onEnded { _ in
                                    imageTapped(index ?? 0)
                                }
                        )
                }
            } else if error != nil {
                Color(.secondarySystemBackground)
            } else {
                ZStack {
                    Color(.secondarySystemBackground)
                    ProgressView()
                }
            }
        }
        .onAppear {
            if image != nil {
                return
            }
            
            utils.imageLoader.loadImage(
                url: source,
                imageCDN: utils.imageCDN,
                resize: resize,
                preferredSize: CGSize(width: width, height: 3 * width / 4),
                completion: { result in
                    switch result {
                    case let .success(image):
                        self.image = image
                        onImageLoaded(image)
                    case let .failure(error):
                        self.error = error
                    }
                }
            )
        }
        .clipped()
    }
    
    func imageView(for image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .aspectRatio(contentMode: .fill)
            .clipped()
            .allowsHitTesting(false)
    }
}

extension ChatMessage {
    
    var alignmentInBubble: HorizontalAlignment {
        .leading
    }
}
