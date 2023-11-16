// The MIT License (MIT)
//
// Copyright (c) 2015-2021 Alexander Grebenyuk (github.com/kean).

import SwiftUI

#if os(macOS)
import AppKit
#else
import UIKit
#endif

#if os(macOS)
/// Displays images. Supports animated images and video playback.
@MainActor
struct NukeImage: NSViewRepresentable {
    let imageContainer: ImageContainer
    let onCreated: ((ImageView) -> Void)?
    var isAnimatedImageRenderingEnabled: Bool?
    var isVideoRenderingEnabled: Bool?
    var isVideoLooping: Bool?
    var resizingMode: ImageResizingMode?

    init(_ image: NSImage) {
        self.init(ImageContainer(image: image))
    }

    init(_ imageContainer: ImageContainer, onCreated: ((ImageView) -> Void)? = nil) {
        self.imageContainer = imageContainer
        self.onCreated = onCreated
    }

    func makeNSView(context: Context) -> ImageView {
        let view = ImageView()
        onCreated?(view)
        return view
    }

    func updateNSView(_ imageView: ImageView, context: Context) {
        updateImageView(imageView)
    }
}
#elseif os(iOS) || os(tvOS)
/// Displays images. Supports animated images and video playback.
@MainActor
struct NukeImage: UIViewRepresentable {
    let imageContainer: ImageContainer
    let onCreated: ((ImageView) -> Void)?
    var isAnimatedImageRenderingEnabled: Bool?
    var isVideoRenderingEnabled: Bool?
    var isVideoLooping: Bool?
    var resizingMode: ImageResizingMode?

    init(_ image: UIImage) {
        self.init(ImageContainer(image: image))
    }

    init(_ imageContainer: ImageContainer, onCreated: ((ImageView) -> Void)? = nil) {
        self.imageContainer = imageContainer
        self.onCreated = onCreated
    }

    func makeUIView(context: Context) -> ImageView {
        let imageView = ImageView()
        onCreated?(imageView)
        return imageView
    }

    func updateUIView(_ imageView: ImageView, context: Context) {
        updateImageView(imageView)
    }
}
#endif

#if os(macOS) || os(iOS) || os(tvOS)
extension NukeImage {
    func updateImageView(_ imageView: ImageView) {
        if imageView.imageContainer?.image !== imageContainer.image {
            imageView.imageContainer = imageContainer
        }
        if let value = resizingMode { imageView.resizingMode = value }
        if let value = isVideoRenderingEnabled { imageView.isVideoRenderingEnabled = value }
        if let value = isAnimatedImageRenderingEnabled { imageView.isAnimatedImageRenderingEnabled = value }
        if let value = isVideoLooping { imageView.isVideoLooping = value }
    }

    /// Sets the resizing mode for the image.
    func resizingMode(_ mode: ImageResizingMode) -> Self {
        var copy = self
        copy.resizingMode = mode
        return copy
    }

    func videoRenderingEnabled(_ isEnabled: Bool) -> Self {
        var copy = self
        copy.isVideoRenderingEnabled = isEnabled
        return copy
    }

    func videoLoopingEnabled(_ isEnabled: Bool) -> Self {
        var copy = self
        copy.isVideoLooping = isEnabled
        return copy
    }

    func animatedImageRenderingEnabled(_ isEnabled: Bool) -> Self {
        var copy = self
        copy.isAnimatedImageRenderingEnabled = isEnabled
        return copy
    }
}
#endif
