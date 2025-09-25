//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChat

final class CDNClient_Mock: CDNClient, @unchecked Sendable {
    static var maxAttachmentSize: Int64 = .max

    lazy var uploadAttachmentMockFunc = MockFunc.mock(for: uploadAttachment)
    func uploadAttachment(
        _ attachment: AnyChatMessageAttachment,
        progress: ((Double) -> Void)?,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        uploadAttachmentMockFunc.callAndReturn(
            (
                attachment,
                progress,
                completion
            )
        )
    }
    
    func uploadStandaloneAttachment(
        _ attachment: StreamAttachment<some Any>,
        progress: ((Double) -> Void)?,
        completion: @escaping (Result<StreamChat.UploadedFile, any Error>) -> Void
    ) {}
}
