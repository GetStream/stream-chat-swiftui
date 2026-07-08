//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import AVFoundation
import Foundation
import StreamChat
import UniformTypeIdentifiers

final class StreamVideoAsset: AVURLAsset, @unchecked Sendable {
    static let scheme = "streamvideocache"

    private let loaderDelegate: StreamVideoResourceLoaderDelegate

    init(originalURL: URL, origin: URLRequest, fileExtension: String?, cache: StreamVideoCache) {
        let loaderDelegate = StreamVideoResourceLoaderDelegate(
            originalURL: originalURL,
            origin: origin,
            fileExtension: fileExtension,
            cache: cache
        )
        self.loaderDelegate = loaderDelegate
        super.init(url: Self.customSchemeURL(from: originalURL), options: nil)
        resourceLoader.setDelegate(loaderDelegate, queue: loaderDelegate.queue)
    }

    deinit {
        cancelLoading()
    }

    override func cancelLoading() {
        super.cancelLoading()
        resourceLoader.setDelegate(nil, queue: nil)
        loaderDelegate.invalidate()
    }

    private static func customSchemeURL(from url: URL) -> URL {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return url }
        components.scheme = scheme
        return components.url ?? url
    }
}

private final class StreamVideoResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate, URLSessionDataDelegate, @unchecked Sendable {
    let queue = DispatchQueue(label: "io.getstream.StreamChatSwiftUI.StreamVideoResourceLoaderDelegate")

    private let originalURL: URL
    private let origin: URLRequest
    private let fileExtension: String?
    private let cache: StreamVideoCache

    private var loadingRequests: [AVAssetResourceLoadingRequest] = []
    private var task: URLSessionDataTask?
    private var tempURL: URL?
    private var readURL: URL?
    private var writeHandle: FileHandle?
    private var contentLength: Int64?
    private var contentType: String?
    private var writtenLength: Int64 = 0
    private var finished = false
    private var finishError: Error?
    private var isInvalidated = false
    private var isSessionInvalidated = false
    private var redirectsToOrigin = false
    private var session: URLSession?

    private func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        let delegateQueue = OperationQueue()
        delegateQueue.maxConcurrentOperationCount = 1
        return URLSession(configuration: configuration, delegate: self, delegateQueue: delegateQueue)
    }

    init(originalURL: URL, origin: URLRequest, fileExtension: String?, cache: StreamVideoCache) {
        self.originalURL = originalURL
        self.origin = origin
        self.fileExtension = fileExtension
        self.cache = cache
    }

    deinit {
        task?.cancel()
        try? writeHandle?.close()
        if let tempURL {
            try? FileManager.default.removeItem(at: tempURL)
        }
        session?.invalidateAndCancel()
    }

    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest
    ) -> Bool {
        guard !isInvalidated else {
            loadingRequest.finishLoading(with: URLError(.cancelled))
            return true
        }
        loadingRequests.append(loadingRequest)
        if !redirectsToOrigin {
            startIfNeeded()
        }
        processRequests()
        return true
    }

    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        didCancel loadingRequest: AVAssetResourceLoadingRequest
    ) {
        loadingRequests.removeAll { $0 === loadingRequest }
    }

    func invalidate() {
        queue.async {
            self.invalidateOnQueue()
        }
    }

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            queue.async {
                self.finishError = StreamVideoResourceLoaderError.invalidResponse
                self.processRequests()
            }
            completionHandler(.cancel)
            return
        }
        guard let contentLength = Self.contentLength(from: http) else {
            queue.async {
                self.redirectToOrigin()
            }
            completionHandler(.cancel)
            return
        }
        let contentType = Self.contentType(from: http) ?? fallbackContentType()
        queue.async {
            self.contentLength = contentLength
            self.contentType = contentType
            self.processRequests()
        }
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        queue.async {
            guard !data.isEmpty, let writeHandle = self.writeHandle else { return }
            do {
                try writeHandle.seekToEnd()
                try writeHandle.write(contentsOf: data)
                self.writtenLength += Int64(data.count)
                self.processRequests()
            } catch {
                self.finishError = error
                self.task?.cancel()
                self.processRequests()
            }
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        queue.async {
            guard !self.isInvalidated else { return }
            self.finished = true
            self.finishError = error ?? self.finishError
            try? self.writeHandle?.close()
            self.writeHandle = nil

            guard self.finishError == nil, let tempURL = self.tempURL else {
                self.removeTempFile()
                self.processRequests()
                self.finishSession()
                return
            }

            self.cache.storeCompletedFile(at: tempURL, forKey: self.originalURL.path, fileExtension: self.fileExtension) { [weak self] storedURL in
                guard let loader = self else { return }
                loader.queue.async {
                    loader.finishStoringCompletedFile(storedURL)
                }
            }
        }
    }

    private func startIfNeeded() {
        guard task == nil else { return }
        do {
            let tempURL = try cache.temporaryFileURL()
            FileManager.default.createFile(atPath: tempURL.path, contents: nil)
            self.tempURL = tempURL
            readURL = tempURL
            writeHandle = try FileHandle(forWritingTo: tempURL)
            let session = makeSession()
            self.session = session
            task = session.dataTask(with: origin)
            task?.resume()
        } catch {
            finishError = error
        }
    }

    private func processRequests() {
        if redirectsToOrigin {
            redirectRequestsToOrigin()
            return
        }
        var completed: [AVAssetResourceLoadingRequest] = []
        for request in loadingRequests {
            fillContentInformation(for: request)
            if respond(to: request) {
                request.finishLoading()
                completed.append(request)
            } else if let finishError, finished || task == nil {
                request.finishLoading(with: finishError)
                completed.append(request)
            }
        }
        loadingRequests.removeAll { request in completed.contains { $0 === request } }
    }

    private func finishStoringCompletedFile(_ storedURL: URL?) {
        _ = storedURL
        processRequests()
        finishSession()
    }

    private func fillContentInformation(for request: AVAssetResourceLoadingRequest) {
        guard let infoRequest = request.contentInformationRequest, let contentLength else { return }
        infoRequest.contentLength = contentLength
        infoRequest.contentType = contentType
        infoRequest.isByteRangeAccessSupported = false
    }

    private func respond(to request: AVAssetResourceLoadingRequest) -> Bool {
        guard let dataRequest = request.dataRequest else {
            return request.contentInformationRequest != nil && contentLength != nil
        }
        guard let readURL else { return false }

        let requestedOffset = dataRequest.requestedOffset
        let currentOffset = dataRequest.currentOffset == 0 ? requestedOffset : dataRequest.currentOffset
        let requestedEnd = dataRequest.requestsAllDataToEndOfResource
            ? (contentLength ?? Int64(dataRequest.requestedLength) + requestedOffset)
            : requestedOffset + Int64(dataRequest.requestedLength)

        guard currentOffset < requestedEnd else { return true }
        guard writtenLength > currentOffset else {
            return finished && finishError == nil
        }

        let length = min(writtenLength, requestedEnd) - currentOffset
        guard length > 0, let data = readBytes(from: readURL, offset: currentOffset, length: length) else {
            return false
        }
        dataRequest.respond(with: data)
        return dataRequest.currentOffset >= requestedEnd
    }

    private func readBytes(from url: URL, offset: Int64, length: Int64) -> Data? {
        guard let handle = try? FileHandle(forReadingFrom: url) else { return nil }
        defer { try? handle.close() }
        do {
            try handle.seek(toOffset: UInt64(offset))
            return try handle.read(upToCount: Int(length))
        } catch {
            return nil
        }
    }

    private func removeTempFile() {
        if let tempURL {
            try? FileManager.default.removeItem(at: tempURL)
        }
        tempURL = nil
    }

    private func invalidateOnQueue() {
        guard !isInvalidated else { return }
        isInvalidated = true
        task?.cancel()
        task = nil
        try? writeHandle?.close()
        writeHandle = nil
        removeTempFile()
        let requests = loadingRequests
        loadingRequests = []
        requests.forEach { $0.finishLoading(with: URLError(.cancelled)) }
        invalidateSession()
    }

    private func finishSession() {
        guard !isSessionInvalidated else { return }
        isSessionInvalidated = true
        session?.finishTasksAndInvalidate()
        session = nil
    }

    private func invalidateSession() {
        guard !isSessionInvalidated else { return }
        isSessionInvalidated = true
        session?.invalidateAndCancel()
        session = nil
    }

    private func redirectToOrigin() {
        redirectsToOrigin = true
        task?.cancel()
        task = nil
        try? writeHandle?.close()
        writeHandle = nil
        removeTempFile()
        redirectRequestsToOrigin()
        invalidateSession()
    }

    private func redirectRequestsToOrigin() {
        let requests = loadingRequests
        loadingRequests = []
        requests.forEach {
            $0.redirect = origin
            $0.response = HTTPURLResponse(
                url: originalURL,
                statusCode: 302,
                httpVersion: nil,
                headerFields: nil
            )
            $0.finishLoading()
        }
    }

    private func fallbackContentType() -> String {
        if let fileExtension, let type = UTType(filenameExtension: fileExtension) {
            return type.identifier
        }
        return UTType.mpeg4Movie.identifier
    }

    private static func contentLength(from response: HTTPURLResponse) -> Int64? {
        if response.statusCode == 206,
           let contentRange = response.value(forHTTPHeaderField: "Content-Range"),
           let total = contentRange.split(separator: "/").last,
           let length = Int64(total) {
            return length
        }
        if let header = response.value(forHTTPHeaderField: "Content-Length"), let length = Int64(header) {
            return length
        }
        return response.expectedContentLength >= 0 ? response.expectedContentLength : nil
    }

    private static func contentType(from response: HTTPURLResponse) -> String? {
        guard let header = response.value(forHTTPHeaderField: "Content-Type") else { return nil }
        let mimeType = header.components(separatedBy: ";").first?.trimmingCharacters(in: .whitespaces) ?? header
        return UTType(mimeType: mimeType)?.identifier
    }
}

private enum StreamVideoResourceLoaderError: Error {
    case invalidResponse
    case cacheWriteFailed
}
