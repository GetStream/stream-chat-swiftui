//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChatSwiftUI
import SwiftUI

public let apiKeyString = "zcgvnykxsfm8"
public let applicationGroupIdentifier = "group.io.getstream.iOS.ChatTestAppSwiftUI"
public let currentUserIdRegisteredForPush = "currentUserIdRegisteredForPush"

public struct UserCredentials {
    let id: String
    let name: String
    let avatarURL: URL
    let token: String
    let birthLand: String
}

extension UserCredentials {

    static func builtInUsersByID(id: String) -> UserCredentials? {
        mock
    }

    static let mock: UserCredentials = UserCredentials(id: "luke_skywalker",
                                                       name: "Luke Skywalker",
                                                       avatarURL: URL(string: "https://vignette.wikia.nocookie.net/starwars/images/2/20/LukeTLJ.jpg")!,
                                                       token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoibHVrZV9za3l3YWxrZXIifQ.b6EiC8dq2AHk0JPfI-6PN-AM9TVzt8JV-qB1N9kchlI",
                                                       birthLand: "Tatooine")

}
