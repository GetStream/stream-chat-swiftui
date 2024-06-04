//
// Copyright © 2024 Stream.io Inc. All rights reserved.
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
                apiClientBuilder: APIClient_Spy.init,
                webSocketClientBuilder: {
                    WebSocketClient_Mock(
                        sessionConfiguration: $0,
                        requestEncoder: $1,
                        eventDecoder: $2,
                        eventNotificationCenter: $3
                    )
                },
                databaseContainerBuilder: {
                    DatabaseContainer_Spy(
                        kind: $0,
                        shouldFlushOnStart: $1,
                        shouldResetEphemeralValuesOnStart: $2,
                        bundle: Bundle(for: StreamChatTestCase.self),
                        localCachingSettings: $3,
                        deletedMessagesVisibility: $4,
                        shouldShowShadowedMessages: $5
                    )
                },
                authenticationRepositoryBuilder: AuthenticationRepository_Mock.init
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
