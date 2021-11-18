//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Foundation

public let apiKeyString = "8br4watad788"
public let applicationGroupIdentifier = "group.io.getstream.iOS.ChatDemoAppSwiftUI"
public let currentUserIdRegisteredForPush = "currentUserIdRegisteredForPush"

public struct UserCredentials {
    let id: String
    let name: String
    let avatarURL: URL
    let token: String
    let birthLand: String
}

extension UserCredentials {
    
    static let mock: UserCredentials = UserCredentials(id: "luke_skywalker",
                                                       name: "Luke Skywalker",
                                                       avatarURL: URL(string: "https://vignette.wikia.nocookie.net/starwars/images/2/20/LukeTLJ.jpg")!,
                                                       token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoibHVrZV9za3l3YWxrZXIifQ.kFSLHRB5X62t0Zlc7nwczWUfsQMwfkpylC6jCUZ6Mc0",
                                                       birthLand: "Tatooine")
    
}
