//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import Foundation

public let apiKeyString = "zcgvnykxsfm8"
public let applicationGroupIdentifier = "group.io.getstream.iOS.ChatDemoAppSwiftUI"
public let currentUserIdRegisteredForPush = "currentUserIdRegisteredForPush"

public struct UserCredentials: Codable {
    public let id: String
    public let name: String
    public let avatarURL: URL
    public let token: String
    public let birthLand: String
}

extension UserCredentials: Identifiable {

    static func builtInUsersByID(id: String) -> UserCredentials? {
        builtInUsers.filter { $0.id == id }.first
    }

    static let builtInUsers: [UserCredentials] = [
        (
            "luke_skywalker",
            "Luke Skywalker",
            "https://vignette.wikia.nocookie.net/starwars/images/2/20/LukeTLJ.jpg",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoibHVrZV9za3l3YWxrZXIifQ.b6EiC8dq2AHk0JPfI-6PN-AM9TVzt8JV-qB1N9kchlI",
            "Tatooine"
        ),
        (
            "leia_organa",
            "Leia Organa",
            "https://vignette.wikia.nocookie.net/starwars/images/f/fc/Leia_Organa_TLJ.png",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoibGVpYV9vcmdhbmEifQ.Z5jwZggIKuspn1Z76MJHF9AY_VdAFg_jnTS6CP5ZZN0",
            "Polis Massa"
        ),
        (
            "han_solo",
            "Han Solo",
            "https://vignette.wikia.nocookie.net/starwars/images/e/e2/TFAHanSolo.png",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiaGFuX3NvbG8ifQ.b5lfc4dHWbfxKFF_NdEGd9K25U6ywSp5ImBW_ncO3OA",
            "Corellia"
        ),
        (
            "lando_calrissian",
            "Lando Calrissian",
            "https://vignette.wikia.nocookie.net/starwars/images/8/8f/Lando_ROTJ.png",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoibGFuZG9fY2Fscmlzc2lhbiJ9.jtR-LRHNSLhPJLlrNOMWa4VF5ublU-vySD9efv-8o8g",
            "Socorro"
        ),
        (
            "chewbacca",
            "Chewbacca",
            "https://vignette.wikia.nocookie.net/starwars/images/4/48/Chewbacca_TLJ.png",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiY2hld2JhY2NhIn0.GVzFcua20gVefzmEMlEX-dJXX56Dyoza3Vfkqin1yTc",
            "Kashyyyk"
        ),
        (
            "c-3po",
            "C-3PO",
            "https://vignette.wikia.nocookie.net/starwars/images/3/3f/C-3PO_TLJ_Card_Trader_Award_Card.png",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiYy0zcG8ifQ._3IfTtUJTexVfCOt9mL22mLeAogaOXPR-5d3kq_h8cs",
            "Affa"
        ),
        (
            "r2-d2",
            "R2-D2",
            "https://vignette.wikia.nocookie.net/starwars/images/e/eb/ArtooTFA2-Fathead.png",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoicjItZDIifQ.zoi2pzALI8a2sQFLhOIxnZawHooj_PqJF0jToqOpNP4",
            "Naboo"
        ),
        (
            "anakin_skywalker",
            "Anakin Skywalker",
            "https://vignette.wikia.nocookie.net/starwars/images/6/6f/Anakin_Skywalker_RotS.png",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiYW5ha2luX3NreXdhbGtlciJ9.ZwCV1qPrSAsie7-0n61JQrSEDbp6fcMgVh4V2CB0kM8",
            "Tatooine"
        ),
        (
            "obi-wan_kenobi",
            "Obi-Wan Kenobi",
            "https://vignette.wikia.nocookie.net/starwars/images/4/4e/ObiWanHS-SWE.jpg",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoib2JpLXdhbl9rZW5vYmkifQ.PU1vMfuhVi7gpfk3TBwM9KmtVldEtsFER8OElLfzFig",
            "Stewjon"
        ),
        (
            "padme_amidala",
            "Padmé Amidala",
            "https://vignette.wikia.nocookie.net/starwars/images/b/b2/Padmegreenscrshot.jpg",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoicGFkbWVfYW1pZGFsYSJ9.qT6nK_5eys8GRK-G_rCD-u58UBq245umMTmE2nVtgm0",
            "Naboo"
        ),
        (
            "qui-gon_jinn",
            "Qui-Gon Jinn",
            "https://vignette.wikia.nocookie.net/starwars/images/f/f6/Qui-Gon_Jinn_Headshot_TPM.jpg",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoicXVpLWdvbl9qaW5uIn0.HvKHNYXUdlay07mUZvsSFdQYi_3SXPr_kxYaaiEr278",
            "Coruscant"
        ),
        (
            "mace_windu",
            "Mace Windu",
            "https://vignette.wikia.nocookie.net/starwars/images/5/58/Mace_ROTS.png",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoibWFjZV93aW5kdSJ9.K6dE1tos0X1bKoehbRQ6DedQcMJf5ZOGY_n9aEioU7A",
            "Haruun Kal"
        ),
        (
            "jar_jar_binks",
            "Jar Jar Binks",
            "https://vignette.wikia.nocookie.net/starwars/images/d/d2/Jar_Jar_aotc.jpg",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiamFyX2phcl9iaW5rcyJ9.wkaMfsuQPlmK1kSPM4f1CVtcVSkZCUL1EMOyp9DT8ns",
            "Naboo"
        ),
        (
            "darth_maul",
            "Darth Maul",
            "https://vignette.wikia.nocookie.net/starwars/images/5/50/Darth_Maul_profile.png",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiZGFydGhfbWF1bCJ9.eUlDsRbZb5SEd0d8WsjZTzg8SYWOinNf6FiGJHS2Qwg",
            "Dathomir"
        ),
        (
            "count_dooku",
            "Count Dooku",
            "https://vignette.wikia.nocookie.net/starwars/images/b/b8/Dooku_Headshot.jpg",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiY291bnRfZG9va3UifQ.2RPv-5vrHTAUGOmZUQFeHZ0hyLj-N-34l4s_9edgEfU",
            "Serenno"
        ),
        (
            "general_grievous",
            "General Grievous",
            "https://vignette.wikia.nocookie.net/starwars/images/d/de/Grievoushead.jpg",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiZ2VuZXJhbF9ncmlldm91cyJ9.g2UUZdENuacFIxhYCylBuDJZUZ2x59MTWaSpndWGCTU",
            "Qymaen jai Sheelal"
        )

    ].map {
        UserCredentials(id: $0.0, name: $0.1, avatarURL: URL(string: $0.2)!, token: $0.3, birthLand: $0.4)
    }
}
