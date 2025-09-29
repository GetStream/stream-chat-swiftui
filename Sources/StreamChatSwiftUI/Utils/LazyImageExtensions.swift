//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

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

    init(imageURL: URL?, @ViewBuilder content: @escaping (LazyImageState) -> Content) {
        let imageCDN = InjectedValues[\.utils].imageCDN
        guard let imageURL else {
            self.init(url: imageURL, content: content)
            return
        }
        let urlRequest = imageCDN.urlRequest(forImage: imageURL)
        let imageRequest = ImageRequest(urlRequest: urlRequest)
        self.init(request: imageRequest, content: content)
    }
}
