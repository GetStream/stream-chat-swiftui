//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChat

struct AnyEndpoint: Equatable {
    let path: EndpointPath
    let method: EndpointMethod
    let queryItems: AnyEncodable?
    let requiresConnectionId: Bool
    let body: AnyEncodable?
    let payloadType: Decodable.Type

    init<T: Decodable>(_ endpoint: Endpoint<T>) {
        path = endpoint.path
        method = endpoint.method
        queryItems = endpoint.queryItems?.asAnyEncodable
        requiresConnectionId = endpoint.requiresConnectionId
        body = endpoint.body?.asAnyEncodable
        payloadType = T.self
    }

    static func == (lhs: AnyEndpoint, rhs: AnyEndpoint) -> Bool {
        lhs.path.value == rhs.path.value
            && lhs.method == rhs.method
            && lhs.queryItems == rhs.queryItems
            && lhs.requiresConnectionId == rhs.requiresConnectionId
            && lhs.body == rhs.body
            && lhs.payloadType == rhs.payloadType
    }
}
