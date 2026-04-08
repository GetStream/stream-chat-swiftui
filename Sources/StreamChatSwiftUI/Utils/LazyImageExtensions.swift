//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatCommonUI
import SwiftUI

enum LazyImageContentState {
    case loaded(UIImage)
    case placeholder
    case loading
    case error(Error)
}

extension LazyImage {
    init(
        imageURL: URL?,
        @ViewBuilder content: @escaping (LazyImageContentState) -> Content
    ) {
        let placeholderContent: (LazyImageState) -> Content = { state in
            if let image = state.imageContainer?.image {
                content(.loaded(image))
            } else if let error = state.error {
                content(.error(error))
            } else {
                content(.loading)
            }
        }
        self.init(imageURL: imageURL, content: placeholderContent)
    }

    /// Loads an image, applying CDN transformations (headers, signing, caching key).
    ///
    /// The CDN completion is captured synchronously. For CDNs like ``StreamCDN``
    /// that complete inline, the full request (URL, headers, caching key) is used.
    /// For async CDNs (e.g. pre-signed URL fetch), the image falls back to the
    /// raw URL since the completion has not fired yet at init time.
    init(imageURL: URL?, cdn: CDN, @ViewBuilder content: @escaping (LazyImageState) -> Content) {
        guard let imageURL else {
            self.init(url: nil, content: content)
            return
        }

        var resolvedRequest: ImageRequest?
        cdn.imageRequest(for: imageURL, resize: nil) { result in
            guard let cdnRequest = try? result.get() else { return }
            var urlRequest = URLRequest(url: cdnRequest.url)
            if let headers = cdnRequest.headers {
                for (key, value) in headers {
                    urlRequest.setValue(value, forHTTPHeaderField: key)
                }
            }
            resolvedRequest = ImageRequest(
                urlRequest: urlRequest,
                userInfo: cdnRequest.cachingKey.map { [.imageIdKey: $0] }
            )
        }

        self.init(
            request: resolvedRequest ?? ImageRequest(url: imageURL),
            transaction: Transaction(animation: nil),
            content: content
        )
    }

    init(imageURL: URL?, @ViewBuilder content: @escaping (LazyImageState) -> Content) {
        let cdn = (InjectedValues[\.utils].imageLoader as? StreamImageLoader)?.cdn ?? StreamCDN()
        self.init(imageURL: imageURL, cdn: cdn, content: content)
    }
}
