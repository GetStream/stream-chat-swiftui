//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

extension JSONEncoder {
    func encodedString<T: Encodable>(_ encodable: T) -> String {
        let encodedData = try! encode(encodable)
        return String(data: encodedData, encoding: .utf8)!.trimmingCharacters(in: .init(charactersIn: "\""))
    }
}
