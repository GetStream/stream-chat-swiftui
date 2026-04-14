//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChat

final class CDNStorage_Mock: CDNStorage, @unchecked Sendable {
    lazy var deleteAttachmentMockFunc = MockFunc.mock(for: deleteAttachment)
    func deleteAttachment(remoteUrl: URL, options: AttachmentDeleteOptions, completion: @escaping @Sendable (Error?) -> Void) {
        deleteAttachmentMockFunc.callAndReturn(
            (
                remoteUrl,
                options,
                completion
            )
        )
    }

    lazy var uploadAttachmentMockFunc = MockFunc<
        (
            AnyChatMessageAttachment,
            AttachmentUploadOptions,
            @Sendable (Result<UploadedFile, Error>) -> Void
        ),
        Void
    >()

    func uploadAttachment(
        _ attachment: AnyChatMessageAttachment,
        options: AttachmentUploadOptions,
        completion: @escaping @Sendable (Result<UploadedFile, Error>) -> Void
    ) {
        uploadAttachmentMockFunc.callAndReturn((attachment, options, completion))
    }

    lazy var uploadAttachmentLocalUrlMockFunc = MockFunc<
        (
            URL,
            AttachmentUploadOptions,
            @Sendable (Result<UploadedFile, Error>) -> Void
        ),
        Void
    >()

    func uploadAttachment(
        localUrl: URL,
        options: AttachmentUploadOptions,
        completion: @escaping @Sendable (Result<UploadedFile, Error>) -> Void
    ) {
        uploadAttachmentLocalUrlMockFunc.callAndReturn((localUrl, options, completion))
    }
}
