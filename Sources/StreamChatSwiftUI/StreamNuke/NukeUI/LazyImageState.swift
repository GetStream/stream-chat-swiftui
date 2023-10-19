// The MIT License (MIT)
//
// Copyright (c) 2015-2021 Alexander Grebenyuk (github.com/kean).

import Foundation

import SwiftUI
import Combine

/// Describes current image state.
struct LazyImageState {
    /// Returns the current fetch result.
    let result: Result<ImageResponse, Error>?

    /// Returns a current error.
    var error: Error? {
        if case .failure(let error) = result {
            return error
        }
        return nil
    }

    /// Returns an image view.
    @MainActor
    var image: NukeImage? {
#if os(macOS)
        return imageContainer.map { NukeImage($0) }
#elseif os(watchOS)
        return imageContainer.map { NukeImage(uiImage: $0.image) }
#else
        return imageContainer.map { NukeImage($0) }
#endif
    }

    /// Returns the fetched image.
    ///
    /// - note: In case pipeline has `isProgressiveDecodingEnabled` option enabled
    /// and the image being downloaded supports progressive decoding, the `image`
    /// might be updated multiple times during the download.
    let imageContainer: ImageContainer?

    /// Returns `true` if the image is being loaded.
    let isLoading: Bool

    /// The progress of the image download.
    let progress: ImageTask.Progress

    @MainActor
    init(_ fetchImage: FetchImage) {
        self.result = fetchImage.result
        self.imageContainer = fetchImage.imageContainer
        self.isLoading = fetchImage.isLoading
        self.progress = fetchImage.progress
    }
}
