// The MIT License (MIT)
//
// Copyright (c) 2015-2022 Alexander Grebenyuk (github.com/kean).

#if !os(watchOS)
import AVKit
#endif

import Foundation

#if !os(macOS)
import UIKit.UIImage
/// Alias for `UIImage`.
typealias PlatformImage = UIImage
#else
import AppKit.NSImage
/// Alias for `NSImage`.
typealias PlatformImage = NSImage
#endif

/// An image container with an image and associated metadata.
struct ImageContainer: @unchecked Sendable {
    #if os(macOS)
    /// A fetched image.
    var image: NSImage
    #else
    /// A fetched image.
    var image: UIImage
    #endif

    /// An image type.
    var type: NukeAssetType?

    /// Returns `true` if the image in the container is a preview of the image.
    var isPreview: Bool

    /// Contains the original image `data`, but only if the decoder decides to
    /// attach it to the image.
    ///
    /// The default decoder (``ImageDecoders/Default``) attaches data to GIFs to
    /// allow to display them using a rendering engine of your choice.
    ///
    /// - note: The `data`, along with the image container itself gets stored
    /// in the memory cache.
    var data: Data?

    #if !os(watchOS)
    /// Represents in-memory video asset.
    var asset: AVAsset?
    #endif

    /// An metadata provided by the user.
    var userInfo: [UserInfoKey: Any]

    /// Initializes the container with the given image.
    init(image: PlatformImage, type: NukeAssetType? = nil, isPreview: Bool = false, data: Data? = nil, userInfo: [UserInfoKey: Any] = [:]) {
        self.image = image
        self.type = type
        self.isPreview = isPreview
        self.data = data
        self.userInfo = userInfo

        #if !os(watchOS)
        if type?.isVideo == true {
            self.asset = data.flatMap { AVDataAsset(data: $0, type: type) }
        }
        #endif
    }

    func map(_ closure: (PlatformImage) throws -> PlatformImage) rethrows -> ImageContainer {
        var copy = self
        copy.image = try closure(image)
        return copy
    }

    /// A key use in ``userInfo``.
    struct UserInfoKey: Hashable, ExpressibleByStringLiteral, Sendable {
        let rawValue: String

        init(_ rawValue: String) {
            self.rawValue = rawValue
        }

        init(stringLiteral value: String) {
            self.rawValue = value
        }

        // For internal purposes.
        static let isThumbnailKey: UserInfoKey = "com.github/kean/nuke/skip-decompression"

        /// A user info key to get the scan number (Int).
        static let scanNumberKey: UserInfoKey = "com.github/kean/nuke/scan-number"
    }
}
