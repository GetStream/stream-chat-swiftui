//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

extension JSONEncoder {
    func encodedString(_ encodable: some Encodable) -> String {
        let encodedData = try! encode(encodable)
        return String(data: encodedData, encoding: .utf8)!.trimmingCharacters(in: .init(charactersIn: "\""))
    }
}
