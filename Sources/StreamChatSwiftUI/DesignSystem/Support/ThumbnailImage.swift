//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// A view that asynchronously loads and displays an image by scaling it down to the specified size.
struct ThumbnailImage<Content, Failure, Loading, Placeholder>: View where Content: View, Failure: View, Loading: View, Placeholder: View {
    let url: URL?
    let size: CGSize
    
    @State private var phase: Phase = .empty
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let failure: (Error) -> Failure
    @ViewBuilder let loading: () -> Loading
    @ViewBuilder let placeholder: () -> Placeholder
    
    init(
        url: URL?,
        size: CGSize,
        content: @escaping (Image) -> Content,
        failure: @escaping (Error) -> Failure,
        loading: @escaping () -> Loading = { ProgressView().padding(4) },
        placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.size = size
        self.content = content
        self.failure = failure
        self.loading = loading
        self.placeholder = placeholder
    }
    
    init(
        url: URL?,
        size: CGSize,
        content: @escaping (Image) -> Content,
        placeholder: @escaping () -> Placeholder
    ) where Failure == Placeholder, Loading == Placeholder {
        self.init(
            url: url,
            size: size,
            content: content,
            failure: { _ in placeholder() },
            loading: { placeholder() },
            placeholder: placeholder
        )
    }
    
    var body: some View {
        Group {
            switch phase {
            case .success(let image):
                content(image)
            case .failure(let error):
                failure(error)
            case .loading:
                loading()
            case .empty:
                placeholder()
            }
        }
        .frame(width: size.width, height: size.height)
        .compatibility.task(id: url?.absoluteString ?? "") { @MainActor in
            await loadThumbnail()
        }
    }
    
    @MainActor private func loadThumbnail() async {
        guard let url else {
            phase = .empty
            return
        }
        do {
            phase = .loading
            let thumbnail = try await withThrowingTaskGroup(of: Image.self, returning: Image.self) { [size] group in
                group.addTask {
                    let imageSource: CGImageSource? = try await {
                        if url.isFileURL {
                            return CGImageSourceCreateWithURL(url as CFURL, nil)
                        } else {
                            let (data, _) = try await URLSession.shared.data(from: url)
                            return CGImageSourceCreateWithData(data as CFData, nil)
                        }
                    }()
                    guard let imageSource else { throw ThumbnailImageError.thumbnailGeneration }
                    let scale = UITraitCollection.current.displayScale
                    let maxDimension = max(size.width, size.height) * scale
                    let options: [CFString: Any] = [
                        kCGImageSourceCreateThumbnailFromImageAlways: true,
                        kCGImageSourceCreateThumbnailWithTransform: true,
                        kCGImageSourceThumbnailMaxPixelSize: maxDimension
                    ]
                    guard let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else {
                        throw ThumbnailImageError.thumbnailGeneration
                    }
                    return Image(decorative: cgImage, scale: scale)
                }
                return try await group.next() ?? Image(systemName: "exclamationmark.triangle")
            }
            phase = .success(thumbnail)
        } catch {
            phase = .failure(error)
        }
    }
}

extension ThumbnailImage {
    enum Phase {
        case success(Image)
        case failure(Error)
        case loading
        case empty
    }
}

enum ThumbnailImageError: Error {
    case thumbnailGeneration
}
