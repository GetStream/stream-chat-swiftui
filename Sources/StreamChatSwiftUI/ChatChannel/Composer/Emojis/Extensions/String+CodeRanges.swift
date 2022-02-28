//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Foundation

extension String {
    func codeRanges() -> [NSRange] {
        let codeRegex = try? NSRegularExpression(pattern: "(```)(?:[a-zA-Z]+)?((?:.|\r|\n)*?)(```)", options: [.anchorsMatchLines])
        let codeMatches = codeRegex?.matches(in: self, options: [], range: NSRange(location: 0, length: utf16.count)) ?? []
        return codeMatches.map { $0.range(at: 0) }
    }

    func filterOutRangesInsideCode(ranges: [NSRange]) -> [NSRange] {
        let codeRanges = self.codeRanges()

        let filteredRanges = ranges.filter { range in
            !codeRanges.contains { codeRange in
                NSIntersectionRange(codeRange, range).length == range.length
            }
        }

        return filteredRanges
    }
}
