// The MIT License (MIT)
//
// Copyright (c) 2015-2022 Alexander Grebenyuk (github.com/kean).

import Foundation

/// A namespace with all available encoders.
enum ImageEncoders {}

extension ImageEncoding where Self == ImageEncoders.Default {
    static func `default`(compressionQuality: Float = 0.8) -> ImageEncoders.Default {
        ImageEncoders.Default(compressionQuality: compressionQuality)
    }
}

extension ImageEncoding where Self == ImageEncoders.ImageIO {
    static func imageIO(type: NukeAssetType, compressionRatio: Float = 0.8) -> ImageEncoders.ImageIO {
        ImageEncoders.ImageIO(type: type, compressionRatio: compressionRatio)
    }
}
