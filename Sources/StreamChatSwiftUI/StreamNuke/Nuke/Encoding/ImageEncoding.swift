// The MIT License (MIT)
//
// Copyright (c) 2015-2022 Alexander Grebenyuk (github.com/kean).

#if !os(macOS)
import UIKit
#else
import Cocoa
#endif

import ImageIO

// MARK: - ImageEncoding

/// An image encoder.
protocol ImageEncoding: Sendable {
    /// Encodes the given image.
    func encode(_ image: PlatformImage) -> Data?

    /// An optional method which encodes the given image container.
    func encode(_ container: ImageContainer, context: ImageEncodingContext) -> Data?
}

extension ImageEncoding {
    func encode(_ container: ImageContainer, context: ImageEncodingContext) -> Data? {
        self.encode(container.image)
    }
}

/// Image encoding context used when selecting which encoder to use.
struct ImageEncodingContext: @unchecked Sendable {
    let request: ImageRequest
    let image: PlatformImage
    let urlResponse: URLResponse?
}
