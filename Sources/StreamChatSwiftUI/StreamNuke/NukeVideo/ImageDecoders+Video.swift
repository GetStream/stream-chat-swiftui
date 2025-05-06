// The MIT License (MIT)
//
// Copyright (c) 2015-2024 Alexander Grebenyuk (github.com/kean).

#if !os(watchOS) && !os(visionOS)

import Foundation
import AVKit
import AVFoundation


extension ImageDecoders {
    /// The video decoder.
    ///
    /// To enable the video decoder, register it with a shared registry:
    ///
    /// ```swift
    /// ImageDecoderRegistry.shared.register(ImageDecoders.Video.init)
    /// ```
    final class Video: ImageDecoding, @unchecked Sendable {
        private var didProducePreview = false
        private let type: NukeAssetType
        var isAsynchronous: Bool { true }

        private let lock = NSLock()

        init?(context: ImageDecodingContext) {
            guard let type = NukeAssetType(context.data), type.isVideo else { return nil }
            self.type = type
        }

        func decode(_ data: Data) throws -> ImageContainer {
            ImageContainer(image: PlatformImage(), type: type, data: data, userInfo: [
                .videoAssetKey: AVDataAsset(data: data, type: type)
            ])
        }

        func decodePartiallyDownloadedData(_ data: Data) -> ImageContainer? {
            lock.lock()
            defer { lock.unlock() }

            guard let type = NukeAssetType(data), type.isVideo else { return nil }
            guard !didProducePreview else {
                return nil // We only need one preview
            }
            guard let preview = makePreview(for: data, type: type) else {
                return nil
            }
            didProducePreview = true
            return ImageContainer(image: preview, type: type, isPreview: true, data: data, userInfo: [
                .videoAssetKey: AVDataAsset(data: data, type: type)
            ])
        }
    }
}

extension ImageContainer.UserInfoKey {
    /// A key for a video asset (`AVAsset`)
    static let videoAssetKey: ImageContainer.UserInfoKey = "com.github/kean/nuke/video-asset"
}

private func makePreview(for data: Data, type: NukeAssetType) -> PlatformImage? {
    let asset = AVDataAsset(data: data, type: type)
    let generator = AVAssetImageGenerator(asset: asset)
    guard let cgImage = try? generator.copyCGImage(at: CMTime(value: 0, timescale: 1), actualTime: nil) else {
        return nil
    }
    return PlatformImage(cgImage: cgImage)
}

#endif

#if os(macOS)
extension NSImage {
    convenience init(cgImage: CGImage) {
        self.init(cgImage: cgImage, size: .zero)
    }
}
#endif
