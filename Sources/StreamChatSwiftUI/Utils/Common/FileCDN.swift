//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

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
