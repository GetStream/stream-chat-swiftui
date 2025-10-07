//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Foundation

@available(iOS 15, *)
extension AttributedStringProtocol {
    func ranges(
        of stringToFind: some StringProtocol,
        options: String.CompareOptions = [],
        locale: Locale? = nil
    ) -> [Range<AttributedString.Index>] {
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
