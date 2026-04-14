//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChat

final class CDNStorage_Mock: CDNStorage, @unchecked Sendable {
    lazy var deleteAttachmentMockFunc = MockFunc.mock(for: deleteAttachment)
    func deleteAttachment(remoteUrl: URL, completion: @escaping @Sendable (Error?) -> Void) {
        deleteAttachmentMockFunc.callAndReturn(
            (
                remoteUrl,
                completion
            )
        )
    }

    lazy var uploadAttachmentMockFunc = MockFunc<
        (
            AnyChatMessageAttachment,
            (@Sendable (Double) -> Void)?,
            @Sendable (Result<UploadedFile, Error>) -> Void
        ),
        Void
    >()

    func uploadAttachment(
        _ attachment: AnyChatMessageAttachment,
        progress: (@Sendable (Double) -> Void)?,
        completion: @escaping @Sendable (Result<UploadedFile, Error>) -> Void
    ) {
        uploadAttachmentMockFunc.callAndReturn((attachment, progress, completion))
    }

    lazy var uploadAttachmentLocalUrlMockFunc = MockFunc<
        (
            URL,
            (@Sendable (Double) -> Void)?,
            @Sendable (Result<UploadedFile, Error>) -> Void
        ),
        Void
    >()

    func uploadAttachment(
        localUrl: URL,
        progress: (@Sendable (Double) -> Void)?,
        completion: @escaping @Sendable (Result<UploadedFile, Error>) -> Void
    ) {
        uploadAttachmentLocalUrlMockFunc.callAndReturn((localUrl, progress, completion))
    }
}
