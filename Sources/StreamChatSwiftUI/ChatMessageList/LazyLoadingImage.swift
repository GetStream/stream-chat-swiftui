//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct LazyLoadingImage: View {
    @Injected(\.utils) private var utils

    @State private var image: UIImage?
    @State private var error: Error?

    let source: MediaAttachment
    let width: CGFloat
    let height: CGFloat
    var resize: Bool = true
    var shouldSetFrame: Bool = true
    var showVideoIcon: Bool = true
    var imageTapped: ((Int) -> Void)?
    var index: Int?
    var onImageLoaded: (UIImage) -> Void = { _ in /* Default implementation. */ }

    var body: some View {
        ZStack {
            if let image {
                imageView(for: image)
                if let imageTapped {
                    // NOTE: needed because of bug with SwiftUI.
                    // The click area expands outside the image view (although not visible).
                    Rectangle()
                        .fill(.clear)
                        .frame(width: width, height: height)
                        .contentShape(.rect)
                        .clipped()
                        .allowsHitTesting(true)
                        .highPriorityGesture(
                            TapGesture()
                                .onEnded { _ in
                                    imageTapped(index ?? 0)
                                }
                        )
                        .accessibilityLabel(L10n.Message.Attachment.accessibilityLabel((index ?? 0) + 1))
                        .accessibilityAddTraits(source.type == .video ? .startsMediaSession : .isImage)
                        .accessibilityAction {
                            imageTapped(index ?? 0)
                        }
                }
            } else if error != nil {
                Color(.secondarySystemBackground)
            } else {
                ZStack {
                    Color(.secondarySystemBackground)
                    ProgressView()
                }
            }

            if showVideoIcon && source.type == .video && width > 64 && source.uploadingState == nil {
                VideoPlayIcon()
                    .accessibilityHidden(true)
            }
        }
        .onAppear {
            if image != nil {
                return
            }
            loadThumbnail()
        }
        .onChange(of: source) { newSource in
            image = nil
            error = nil
            loadThumbnail(from: newSource)
        }
    }

    private func loadThumbnail(from attachment: MediaAttachment? = nil) {
        let attachment = attachment ?? source
        attachment.generateThumbnail(
            resize: resize,
            preferredSize: CGSize(width: width, height: height)
        ) { result in
            switch result {
            case let .success(image):
                self.image = image
                onImageLoaded(image)
            case let .failure(error):
                self.error = error
            }
        }
    }

    func imageView(for image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .aspectRatio(contentMode: .fill)
            .frame(width: shouldSetFrame ? width : nil, height: shouldSetFrame ? height : nil)
            .allowsHitTesting(false)
            .scaleEffect(1.0001) // Needed because of SwiftUI sometimes incorrectly displaying landscape images.
            .clipped()
            .accessibilityHidden(true)
    }
}

struct VideoPlayIcon: View {
    @Injected(\.images) var images

    var width: CGFloat = 24

    var body: some View {
        Image(uiImage: images.playFill)
            .customizable()
            .frame(width: width)
            .foregroundColor(.white)
            .modifier(ShadowModifier())
    }
}
