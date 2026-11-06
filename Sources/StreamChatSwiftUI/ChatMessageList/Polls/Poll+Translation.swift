//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat

extension Poll {
    func name(in language: TranslationLanguage?) -> String {
        language.flatMap(translatedName(for:)) ?? name
    }
}

extension PollOption {
    func text(in language: TranslationLanguage?) -> String {
        language.flatMap(translatedText(for:)) ?? text
    }
}

extension PollVote {
    func answerText(in language: TranslationLanguage?) -> String? {
        language.flatMap(translatedAnswerText(for:)) ?? answerText
    }
}
