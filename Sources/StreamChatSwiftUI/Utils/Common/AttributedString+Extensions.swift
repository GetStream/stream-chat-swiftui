//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation

@available(iOS 15, *)
extension AttributedStringProtocol {
    func ranges<T>(
        of stringToFind: T,
        options: String.CompareOptions = [],
        locale: Locale? = nil
    ) -> [Range<AttributedString.Index>] where T: StringProtocol {
        guard !characters.isEmpty else { return [] }
        var ranges = [Range<AttributedString.Index>]()
        var source: AttributedSubstring = self[startIndex...]
        while let range = source.range(of: stringToFind, options: options, locale: locale) {
            ranges.append(range)
            if range.upperBound < endIndex {
                source = self[range.upperBound...]
            } else {
                break
            }
        }
        return ranges
    }
}
