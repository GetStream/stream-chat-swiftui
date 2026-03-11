//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import AVKit
import Foundation
import StreamChat

/// FileCDN provides a set of functions to improve handling of files & videos from CDN.
public protocol FileCDN: AnyObject {
    /// Prepare and return an adjusted or  signed `URL` for the given file `URL`
    /// This function can be used to intercept an unsigned URL and return a valid signed URL
    /// - Parameters:
    ///   - url: A file URL.
    ///   - completion: A completion that is called when an adjusted URL is ready to be provided.
    func adjustedURL(
        for url: URL,
        completion: @escaping ((Result<URL, Error>) -> Void)
    )

    /// Creates and returns an `AVPlayer` for the given video URL.
    ///
    /// The default implementation calls ``adjustedURL(for:completion:)`` and creates
    /// an `AVPlayer` from the resulting URL. Override this method to provide a custom
    /// player configuration, such as injecting authentication headers via a custom `AVURLAsset`.
    /// - Parameters:
    ///   - url: A video URL.
    ///   - completion: A completion that is called when the player is ready or an error occurred.
    func player(
        for url: URL,
        completion: @escaping ((Result<AVPlayer, Error>) -> Void)
    )
}

extension FileCDN {
    public func player(
        for url: URL,
        completion: @escaping ((Result<AVPlayer, Error>) -> Void)
    ) {
        adjustedURL(for: url) { result in
            switch result {
            case let .success(adjustedURL):
                completion(.success(AVPlayer(url: adjustedURL)))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

/// The `DefaultFileCDN` implemenation used by default.
public final class DefaultFileCDN: FileCDN {
    // Initializer required for subclasses
    public init() {
        // Public init.
    }

    public func adjustedURL(for url: URL, completion: @escaping ((Result<URL, any Error>) -> Void)) {
        completion(.success(url))
    }
}
