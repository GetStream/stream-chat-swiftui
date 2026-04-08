//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatCommonUI
import SwiftUI

/// A wrapper around Nuke's `LazyImage` that applies CDN transformations
/// (headers, signing, caching key) before loading.
///
/// Uses `@Injected` to obtain the CDN from the image loader, and resolves
/// the CDN request asynchronously so it works with both synchronous and
/// async CDN implementations (e.g. pre-signed URLs).
struct StreamLazyImage: View {
    @Injected(\.utils) private var utils

    private let url: URL?
    @State private var imageRequest: ImageRequest?

    init(url: URL?) {
        self.url = url
    }

    var body: some View {
        LazyImage(request: imageRequest)
            .onDisappear(.cancel)
            .priority(.high)
            .compatibility.task(id: url?.absoluteString ?? "") { @MainActor in
                await resolveRequest()
            }
    }

    @MainActor
    private func resolveRequest() async {
        guard let url else { return }
        let cdn = (utils.imageLoader as? StreamImageLoader)?.cdn ?? StreamCDN()
        do {
            let cdnRequest = try await cdn.imageRequest(for: url)
            imageRequest = makeImageRequest(from: cdnRequest, fallbackURL: url)
        } catch {
            imageRequest = ImageRequest(url: url)
        }
    }
}

/// A wrapper around Nuke's `LazyImage` with custom content that applies
/// CDN transformations before loading.
struct StreamLazyContentImage<Content: View>: View {
    @Injected(\.utils) private var utils

    private let url: URL?
    private let processors: [ImageProcessing]
    private let priority: ImageRequest.Priority
    private let content: (LazyImageState) -> Content
    @State private var imageRequest: ImageRequest?

    init(
        url: URL?,
        processors: [ImageProcessing] = [],
        priority: ImageRequest.Priority = .high,
        @ViewBuilder content: @escaping (LazyImageState) -> Content
    ) {
        self.url = url
        self.processors = processors
        self.priority = priority
        self.content = content
    }

    var body: some View {
        LazyImage(request: imageRequest, content: content)
            .onDisappear(.cancel)
            .processors(processors)
            .priority(priority)
            .compatibility.task(id: url?.absoluteString ?? "") { @MainActor in
                await resolveRequest()
            }
    }

    @MainActor
    private func resolveRequest() async {
        guard let url else { return }
        let cdn = (utils.imageLoader as? StreamImageLoader)?.cdn ?? StreamCDN()
        do {
            let cdnRequest = try await cdn.imageRequest(for: url)
            imageRequest = makeImageRequest(from: cdnRequest, fallbackURL: url)
        } catch {
            imageRequest = ImageRequest(url: url)
        }
    }
}

// MARK: - Shared Helper

private func makeImageRequest(from cdnRequest: CDNRequest, fallbackURL: URL) -> ImageRequest {
    var urlRequest = URLRequest(url: cdnRequest.url)
    if let headers = cdnRequest.headers {
        for (key, value) in headers {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
    }
    return ImageRequest(
        urlRequest: urlRequest,
        userInfo: cdnRequest.cachingKey.map { [.imageIdKey: $0] }
    )
}
