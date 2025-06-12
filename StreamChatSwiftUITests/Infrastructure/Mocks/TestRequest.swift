//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChat

class TestRequestEncoder: RequestEncoder, @unchecked Sendable {
    let init_baseURL: URL
    let init_apiKey: APIKey

    weak var connectionDetailsProviderDelegate: ConnectionDetailsProviderDelegate?

    @Atomic var encodeRequest: Result<URLRequest, Error>? = .success(URLRequest(url: .unique()))
    @Atomic var encodeRequest_endpoint: AnyEndpoint?
    @Atomic var encodeRequest_completion: ((Result<URLRequest, Error>) -> Void)?

    func encodeRequest<ResponsePayload>(
        for endpoint: Endpoint<ResponsePayload>,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) where ResponsePayload: Decodable {
        encodeRequest_endpoint = AnyEndpoint(endpoint)
        encodeRequest_completion = completion

        if let result = encodeRequest {
            completion(result)
        }
    }

    required init(baseURL: URL, apiKey: APIKey) {
        init_baseURL = baseURL
        init_apiKey = apiKey
    }
}

class TestRequestDecoder: RequestDecoder, @unchecked Sendable {
    @Atomic var decodeRequestResponse: Result<Any, Error>?

    @Atomic var decodeRequestResponse_data: Data?
    @Atomic var decodeRequestResponse_response: HTTPURLResponse?
    @Atomic var decodeRequestResponse_error: Error?

    func decodeRequestResponse<ResponseType>(data: Data?, response: URLResponse?, error: Error?) throws -> ResponseType
        where ResponseType: Decodable {
        decodeRequestResponse_data = data
        decodeRequestResponse_response = response as? HTTPURLResponse
        decodeRequestResponse_error = error

        guard let simulatedResponse = decodeRequestResponse else {
            log.warning("TestRequestDecoder simulated response not set. Throwing a TestError.")
            throw TestError()
        }

        switch simulatedResponse {
        case let .success(response):
            return response as! ResponseType
        case let .failure(error):
            throw error
        }
    }
}
