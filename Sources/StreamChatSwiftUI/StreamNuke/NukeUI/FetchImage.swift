// The MIT License (MIT)
//
// Copyright (c) 2015-2022 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import Combine


/// An observable object that simplifies image loading in SwiftUI.
@MainActor
final class FetchImage: ObservableObject, Identifiable {
    /// Returns the current fetch result.
    @Published private(set) var result: Result<ImageResponse, Error>?

    /// Returns the fetched image.
    ///
    /// - note: In case pipeline has `isProgressiveDecodingEnabled` option enabled
    /// and the image being downloaded supports progressive decoding, the `image`
    /// might be updated multiple times during the download.
    var image: PlatformImage? { imageContainer?.image }

    /// Returns the fetched image.
    ///
    /// - note: In case pipeline has `isProgressiveDecodingEnabled` option enabled
    /// and the image being downloaded supports progressive decoding, the `image`
    /// might be updated multiple times during the download.
    @Published private(set) var imageContainer: ImageContainer?

    /// Returns `true` if the image is being loaded.
    @Published private(set) var isLoading: Bool = false

    /// Animations to be used when displaying the loaded images. By default, `nil`.
    ///
    /// - note: Animation isn't used when image is available in memory cache.
    var animation: Animation?

    /// The progress of the image download.
    @Published private(set) var progress = ImageTask.Progress(completed: 0, total: 0)

    /// Updates the priority of the task, even if the task is already running.
    /// `nil` by default
    var priority: ImageRequest.Priority? {
        didSet { priority.map { imageTask?.priority = $0 } }
    }

    /// Gets called when the request is started.
    var onStart: ((ImageTask) -> Void)?

    /// Gets called when a progressive image preview is produced.
    var onPreview: ((ImageResponse) -> Void)?

    /// Gets called when the request progress is updated.
    var onProgress: ((ImageTask.Progress) -> Void)?

    /// Gets called when the requests finished successfully.
    var onSuccess: ((ImageResponse) -> Void)?

    /// Gets called when the requests fails.
    var onFailure: ((Error) -> Void)?

    /// Gets called when the request is completed.
    var onCompletion: ((Result<ImageResponse, Error>) -> Void)?

    /// A pipeline used for performing image requests.
    var pipeline: ImagePipeline = .shared

    /// Image processors to be applied unless the processors are provided in the
    /// request. `[]` by default.
    var processors: [any ImageProcessing] = []

    private var imageTask: ImageTask?

    // publisher support
    private var lastResponse: ImageResponse?
    private var cancellable: AnyCancellable?

    deinit {
        imageTask?.cancel()
    }

    /// Initialiazes the image. To load an image, use one of the `load()` methods.
    init() {}

    // MARK: Loading Images

    /// Loads an image with the given request.
    func load(_ url: URL?) {
        load(url.map { ImageRequest(url: $0) })
    }

    /// Loads an image with the given request.
    func load(_ request: ImageRequest?) {
        assert(Thread.isMainThread, "Must be called from the main thread")

        reset()

        guard var request = request else {
            handle(result: .failure(ImagePipeline.Error.imageRequestMissing))
            return
        }

        if !processors.isEmpty && request.processors.isEmpty {
            request.processors = processors
        }
        if let priority = self.priority {
            request.priority = priority
        }

        // Quick synchronous memory cache lookup
        if let image = pipeline.cache[request] {
            if image.isPreview {
                imageContainer = image // Display progressive image
            } else {
                let response = ImageResponse(container: image, request: request, cacheType: .memory)
                handle(result: .success(response))
                return
            }
        }

        isLoading = true
        progress = ImageTask.Progress(completed: 0, total: 0)

        let task = pipeline.loadImage(
            with: request,
            progress: { [weak self] response, completed, total in
                guard let self = self else { return }
                let progress = ImageTask.Progress(completed: completed, total: total)
                if let response = response {
                    self.onPreview?(response)
                    withAnimation(self.animation) {
                        self.handle(preview: response)
                    }
                } else {
                    self.progress = progress
                    self.onProgress?(progress)
                }
            },
            completion: { [weak self] result in
                guard let self = self else { return }
                withAnimation(self.animation) {
                    self.handle(result: result.mapError { $0 })
                }
            }
        )
        imageTask = task
        onStart?(task)
    }

    // Deprecated in Nuke 11.0
    @available(*, deprecated, message: "Please use load() methods that work either with URL or ImageRequest.")
    func load(_ request: (any ImageRequestConvertible)?) {
        load(request?.asImageRequest())
    }

    private func handle(preview: ImageResponse) {
        // Display progressively decoded image
        self.imageContainer = preview.container
    }

    private func handle(result: Result<ImageResponse, Error>) {
        isLoading = false

        if case .success(let response) = result {
            self.imageContainer = response.container
        }
        self.result = result

        imageTask = nil
        switch result {
        case .success(let response): onSuccess?(response)
        case .failure(let error): onFailure?(error)
        }
        onCompletion?(result)
    }

    // MARK: Load (Async/Await)

    /// Loads and displays an image using the given async function.
    ///
    /// - parameter action: Fetched the image.
    func load(_ action: @escaping () async throws -> ImageResponse) {
        reset()
        isLoading = true

        let task = Task {
            do {
                let response = try await action()
                withAnimation(animation) {
                    handle(result: .success(response))
                }
            } catch {
                handle(result: .failure(error))
            }
        }
        cancellable = AnyCancellable { task.cancel() }
    }

    // MARK: Load (Combine)

    /// Loads an image with the given publisher.
    ///
    /// - important: Some `FetchImage` features, such as progress reporting and
    /// dynamically changing the request priority, are not available when
    /// working with a publisher.
    func load<P: Publisher>(_ publisher: P) where P.Output == ImageResponse {
        reset()

        // Not using `first()` because it should support progressive decoding
        isLoading = true
        cancellable = publisher.sink(receiveCompletion: { [weak self] completion in
            guard let self = self else { return }
            self.isLoading = false
            switch completion {
            case .finished:
                if let response = self.lastResponse {
                    self.result = .success(response)
                } // else was cancelled, do nothing
            case .failure(let error):
                self.result = .failure(error)
            }
        }, receiveValue: { [weak self] response in
            guard let self = self else { return }
            self.lastResponse = response
            self.imageContainer = response.container
        })
    }

    // MARK: Cancel

    /// Marks the request as being cancelled. Continues to display a downloaded image.
    func cancel() {
        // pipeline-based
        imageTask?.cancel() // Guarantees that no more callbacks will be delivered
        imageTask = nil

        // publisher-based
        cancellable = nil
    }

    /// Resets the `FetchImage` instance by cancelling the request and removing
    /// all of the state including the loaded image.
    func reset() {
        cancel()

        // Avoid publishing unchanged values
        if isLoading { isLoading = false }
        if imageContainer != nil { imageContainer = nil }
        if result != nil { result = nil }
        lastResponse = nil // publisher-only
        if progress != ImageTask.Progress(completed: 0, total: 0) { progress = ImageTask.Progress(completed: 0, total: 0) }
    }

    // MARK: View

    /// Returns an image view displaying a fetched image.
    var view: SwiftUI.Image? {
#if os(macOS)
        image.map(SwiftUI.Image.init(nsImage:))
#else
        image.map(SwiftUI.Image.init(uiImage:))
#endif
    }
}
