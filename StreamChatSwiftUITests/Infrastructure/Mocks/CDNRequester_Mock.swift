//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChat

final class CDNRequester_Mock: CDNRequester, @unchecked Sendable {
    var fileRequestCallCount = 0
    var fileRequestCalledWithURLs: [URL] = []
    var fileRequestResult: Result<CDNRequest, Error> = .success(
        CDNRequest(url: URL(string: "https://cdn.example.com/signed-file")!)
    )

    var imageRequestCallCount = 0
    var imageRequestCalledWithURLs: [URL] = []
    var imageRequestResult: Result<CDNRequest, Error> = .success(
        CDNRequest(url: URL(string: "https://cdn.example.com/signed-image")!)
    )

    func fileRequest(
        for url: URL,
        options: FileRequestOptions,
        completion: @escaping (Result<CDNRequest, Error>) -> Void
    ) {
        fileRequestCallCount += 1
        fileRequestCalledWithURLs.append(url)
        completion(fileRequestResult)
    }

    func imageRequest(
        for url: URL,
        options: ImageRequestOptions,
        completion: @escaping (Result<CDNRequest, Error>) -> Void
    ) {
        imageRequestCallCount += 1
        imageRequestCalledWithURLs.append(url)
        completion(imageRequestResult)
    }
}
