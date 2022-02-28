//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Foundation

/// An enum that represents the source of the emoji
public enum EmojiSource {
    /// A standard unicode emoji e.g. "😁"
    case character(String)
    /// A  URL to an image e.g. "https://example.com/party_parrot.gif"
    case imageUrl(String)
    /// An asset name of an image e.g. "homer_disappering.gif"
    case imageAsset(String)
    /// An alias to another emoji shortcode e.g. "party_parrot"
    case alias(String)
}

extension EmojiSource: Codable, Hashable {
    enum CodingKeys: CodingKey {
        case character, imageUrl, imageAsset, alias
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        switch container.allKeys.first {
        case .character:
            self = .character(try container.decode(String.self, forKey: .character))
        case .imageUrl:
            self = .imageUrl(try container.decode(String.self, forKey: .imageUrl))
        case .imageAsset:
            self = .imageAsset(try container.decode(String.self, forKey: .imageAsset))
        case .alias:
            self = .alias(try container.decode(String.self, forKey: .alias))
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unabled to decode enum."
                )
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case let .character(character):
            try container.encode(character, forKey: .character)
        case let .imageUrl(imageUrl):
            try container.encode(imageUrl, forKey: .imageUrl)
        case let .imageAsset(imageAsset):
            try container.encode(imageAsset, forKey: .imageAsset)
        case let .alias(alias):
            try container.encode(alias, forKey: .alias)
        }
    }
}
