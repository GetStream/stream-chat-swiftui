//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChat
@testable import StreamChatTestTools

public extension ChatClient {
    /// Create a new instance of mock `ChatClient`
    static func mock(
        isLocalStorageEnabled: Bool = false,
        customCDNClient: CDNClient? = nil
    ) -> ChatClient_Mock {
        var config = ChatClientConfig(apiKey: .init("--== Mock ChatClient ==--"))
        config.customCDNClient = customCDNClient
        config.isLocalStorageEnabled = isLocalStorageEnabled
        config.isClientInActiveMode = false
        config.maxAttachmentCountPerMessage = 10

        return ChatClient_Mock(
            config: config,
            workerBuilders: [],
            environment: .init(
                apiClientBuilder: {
                    APIClient_Spy(
                        sessionConfiguration: $0,
                        requestEncoder: $1,
                        requestDecoder: $2,
                        attachmentDownloader: $3,
                        attachmentUploader: $4
                    )
                },
                webSocketClientBuilder: {
                    WebSocketClient_Mock(
                        sessionConfiguration: $0,
                        eventDecoder: $1,
                        eventNotificationCenter: $2
                    )
                },
                databaseContainerBuilder: {
                    DatabaseContainer_Spy(
                        kind: $0,
                        bundle: Bundle(for: StreamChatTestCase.self),
                        chatClientConfig: $1
                    )
                },
                authenticationRepositoryBuilder: {
                    AuthenticationRepository_Mock(
                        apiClient: $0,
                        databaseContainer: $1,
                        connectionRepository: $2,
                        tokenExpirationRetryStrategy: $3,
                        timerType: $4
                    )
                }
            )
        )
    }
}

extension ChatClient {
    convenience init(config: ChatClientConfig, environment: ChatClient.Environment) {
        self.init(
            config: config,
            environment: environment,
            factory: ChatClientFactory(config: config, environment: environment)
        )
    }
}
