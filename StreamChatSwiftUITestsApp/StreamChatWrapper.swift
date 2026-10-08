//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import OHHTTPStubs
@testable import StreamChat
import StreamChatSwiftUI
import UIKit

@MainActor
final class StreamChatWrapper {
    @Injected(\.chatClient) var client

    static let shared = StreamChatWrapper()

    func mockConnection(isConnected: Bool) {
        if isConnected == false {
            // Stub all HTTP requests with No internet connection error
            HTTPStubs.stubRequests(passingTest: { [unowned self] (request) -> Bool in
                let baseURL = self.client.config.baseURL.restAPIBaseURL.absoluteString
                return request.url?.absoluteString.contains(baseURL) ?? false
            }, withStubResponse: { _ -> HTTPStubsResponse in
                let error = NSError(
                    domain: "NSURLErrorDomain",
                    code: -1009,
                    userInfo: nil
                )
                return HTTPStubsResponse(error: error)
            })

            // Swap monitor with the mocked one
            let monitor = InternetConnectionMonitor_Mock()
            var environment = ChatClient.Environment()
            environment.monitor = monitor
            client.setupConnectionRecoveryHandler(with: environment)

            // Update monitor with mocked status
            monitor.update(with: .unavailable)

            // Disconnect from websockets
            client.webSocketClient?.disconnect(source: .systemInitiated) {}

        } else {
            HTTPStubs.removeAllStubs()
            client.setupConnectionRecoveryHandler(with: ChatClient.Environment())
            client.webSocketClient?.connect()
        }
    }
}
