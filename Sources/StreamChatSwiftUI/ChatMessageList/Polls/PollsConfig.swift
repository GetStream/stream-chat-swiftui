//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation

/// Config for various poll settings.
public final class PollsConfig {
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
    /// The maximum number of characters allowed in the poll question.
    ///
    /// When set, the question text field in the poll creation view stops accepting
    /// further input once the limit is reached. Defaults to `nil`, meaning no limit.
    public var maxQuestionLength: Int?
    /// The maximum number of characters allowed in each poll option.
    ///
    /// When set, an option's text field in the poll creation view stops accepting
    /// further input once the limit is reached. Defaults to `nil`, meaning no limit.
    public var maxOptionLength: Int?

    /// Initializes a new `PollsConfig` with the given configurations.
    ///
    /// - Parameters:
    ///   - multipleAnswers: Configuration for allowing multiple answers. Defaults to `.default`.
    ///   - anonymousPoll: Configuration for enabling anonymous polls. Defaults to `.default`.
    ///   - suggestAnOption: Configuration for allowing users to suggest options. Defaults to `.default`.
    ///   - addComments: Configuration for adding comments. Defaults to `.default`.
    ///   - maxVotesPerPerson: Configuration for setting the maximum number of votes per person. Defaults to `.default`.
    ///   - maxQuestionLength: The maximum number of characters allowed in the poll question. Defaults to `nil` (no limit).
    ///   - maxOptionLength: The maximum number of characters allowed in each poll option. Defaults to `nil` (no limit).
    public init(
        multipleAnswers: PollsEntryConfig = .default,
        anonymousPoll: PollsEntryConfig = .default,
        suggestAnOption: PollsEntryConfig = .default,
        addComments: PollsEntryConfig = .default,
        maxVotesPerPerson: PollsEntryConfig = .default,
        maxQuestionLength: Int? = nil,
        maxOptionLength: Int? = nil
    ) {
        self.multipleAnswers = multipleAnswers
        self.anonymousPoll = anonymousPoll
        self.suggestAnOption = suggestAnOption
        self.addComments = addComments
        self.maxVotesPerPerson = maxVotesPerPerson
        self.maxQuestionLength = maxQuestionLength
        self.maxOptionLength = maxOptionLength
    }
}

/// Config for individual poll entry.
public final class PollsEntryConfig {
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
    public static var `default`: PollsEntryConfig { PollsEntryConfig(configurable: true, defaultValue: false) }
}
