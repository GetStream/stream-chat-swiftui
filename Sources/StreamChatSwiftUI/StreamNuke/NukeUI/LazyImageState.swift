// The MIT License (MIT)
//
// Copyright (c) 2015-2024 Alexander Grebenyuk (github.com/kean).

import Foundation

import SwiftUI
import Combine

/// Describes current image state.
@MainActor
protocol LazyImageState {
    /// Returns the current fetch result.
    var result: Result<ImageResponse, Error>? { get }

    /// Returns the fetched image.
    ///
    /// - note: In case pipeline has `isProgressiveDecodingEnabled` option enabled
    /// and the image being downloaded supports progressive decoding, the `image`
    /// might be updated multiple times during the download.
    var imageContainer: ImageContainer? { get }

    /// Returns `true` if the image is being loaded.
    var isLoading: Bool { get }

    /// The progress of the image download.
    var progress: FetchImage.Progress { get }
}

extension LazyImageState {
    /// Returns the current error.
    var error: Error? {
        if case .failure(let error) = result {
            return error
        }
        return nil
    }

    /// Returns an image view.
    var image: Image? {
#if os(macOS)
        imageContainer.map { Image(nsImage: $0.image) }
#else
        imageContainer.map { Image(uiImage: $0.image) }
#endif
    }
}

extension FetchImage: LazyImageState {}
