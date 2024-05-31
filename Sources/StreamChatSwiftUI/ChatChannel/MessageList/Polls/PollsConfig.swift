//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Foundation

/// Config for various poll settings.
public struct PollsConfig {
    /// Configuration for allowing multiple answers in a poll.
    public var multipleAnswers: PollsEntryConfig
    /// Configuration for enabling anonymous polls.
    public var anonymousPoll: PollsEntryConfig
    /// Configuration for allowing users to suggest options in a poll.
    public var suggestAnOption: PollsEntryConfig
    /// Configuration for adding comments to a poll.
    public var addComments: PollsEntryConfig
    /// Configuration for setting the maximum number of votes per person.
    public var maxVotesPerPerson: PollsEntryConfig
    
    /// Initializes a new `PollsConfig` with the given configurations.
    ///
    /// - Parameters:
    ///   - multipleAnswers: Configuration for allowing multiple answers. Defaults to `.default`.
    ///   - anonymousPoll: Configuration for enabling anonymous polls. Defaults to `.default`.
    ///   - suggestAnOption: Configuration for allowing users to suggest options. Defaults to `.default`.
    ///   - addComments: Configuration for adding comments. Defaults to `.default`.
    ///   - maxVotesPerPerson: Configuration for setting the maximum number of votes per person. Defaults to `.default`.
    public init(
        multipleAnswers: PollsEntryConfig = .default,
        anonymousPoll: PollsEntryConfig = .default,
        suggestAnOption: PollsEntryConfig = .default,
        addComments: PollsEntryConfig = .default,
        maxVotesPerPerson: PollsEntryConfig = .default
    ) {
        self.multipleAnswers = multipleAnswers
        self.anonymousPoll = anonymousPoll
        self.suggestAnOption = suggestAnOption
        self.addComments = addComments
        self.maxVotesPerPerson = maxVotesPerPerson
    }
}

/// Config for individual poll entry.
public struct PollsEntryConfig {
    /// Indicates whether the poll entry is configurable.
    public var configurable: Bool
    /// Indicates the default value of the poll entry.
    public var defaultValue: Bool
    
    public init(configurable: Bool, defaultValue: Bool) {
        self.configurable = configurable
        self.defaultValue = defaultValue
    }
}

extension PollsEntryConfig {
    /// The default configuration for a poll entry.
    public static let `default` = PollsEntryConfig(configurable: true, defaultValue: false)
}
