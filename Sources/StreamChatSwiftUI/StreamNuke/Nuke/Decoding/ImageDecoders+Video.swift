// The MIT License (MIT)
//
// Copyright (c) 2015-2022 Alexander Grebenyuk (github.com/kean).

#if !os(watchOS)

import Foundation
import AVKit

extension ImageDecoders {
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
            ImageContainer(image: PlatformImage(), type: type, data: data)
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
            return ImageContainer(image: preview, type: type, isPreview: true, data: data)
        }
    }
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
