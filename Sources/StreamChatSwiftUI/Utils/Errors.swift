//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Combine
import Foundation

public struct StreamChatError: Error {
    
    /// The specific error code.
    let errorCode: StreamChatErrorCode
    
    /// The additional error message description.
    let description: String?
    
    /// The additional information dictionary.
    let additionalInfo: [String: Any]?
        
    static let unknown = StreamChatError(
        errorCode: StreamChatErrorCode.unknown,
        description: nil,
        additionalInfo: nil
    )
    
    static let missingData = StreamChatError(
        errorCode: StreamChatErrorCode.missingData,
        description: nil,
        additionalInfo: nil
    )
    
    static let wrongConfig = StreamChatError(
        errorCode: StreamChatErrorCode.wrongConfig,
        description: nil,
        additionalInfo: nil
    )
    
    static let noSuggestionsAvailable = StreamChatError(
        errorCode: StreamChatErrorCode.noSuggestions,
        description: nil,
        additionalInfo: nil
    )
}

extension StreamChatError: Equatable {
    
    public static func == (lhs: StreamChatError, rhs: StreamChatError) -> Bool {
        lhs.errorCode == rhs.errorCode
    }
}

extension StreamChatError {
    
    func asFailedPromise<T>() -> Future<T, Error> {
        Future { promise in
            promise(.failure(self))
        }
    }
}

/// Error codes for errors happening in the app.
public enum StreamChatErrorCode: Int {
    case unknown = 101_000
    case missingData = 101_001
    case wrongConfig = 101_002
    case noSuggestions = 101_003
}
