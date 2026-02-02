//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// File attachment preview for quoted messages.
public struct QuotedMessageFilePreviewView: View {
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens

    let fileExtension: String

    /// Creates a file attachment preview with the given file extension.
    /// - Parameter fileExtension: The file extension (e.g., "pdf", "doc", "zip").
    public init(fileExtension: String) {
        self.fileExtension = fileExtension.lowercased()
    }

    /// Creates a file attachment preview from a file URL.
    /// - Parameter fileURL: The URL of the file to preview.
    public init(fileURL: URL) {
        self.fileExtension = fileURL.pathExtension.lowercased()
    }

    public var body: some View {
        Image(uiImage: fileIcon)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 40, height: 40)
    }

    private var fileIcon: UIImage {
        fileTypePreviews[fileExtension] ?? fileTypePreviewFallback
    }

    // MARK: - File Type Preview Icons

    private var fileTypePreviews: [String: UIImage] {
        [
            // PDF
            "pdf": filePdf,
            // Documents
            "doc": fileDoc,
            "docx": fileDoc,
            "txt": fileDoc,
            "rtf": fileDoc,
            "odt": fileDoc,
            "md": fileDoc,
            // Presentations
            "ppt": filePpt,
            "pptx": filePpt,
            // Spreadsheets
            "xls": fileXls,
            "xlsx": fileXls,
            "csv": fileXls,
            // Audio
            "mp3": fileMp3,
            "aac": fileMp3,
            "wav": fileMp3,
            "m4a": fileMp3,
            // Video
            "mp4": fileMp4,
            "mov": fileMp4,
            "avi": fileMp4,
            "mkv": fileMp4,
            "webm": fileMp4,
            // Code
            "html": fileHtml,
            "htm": fileHtml,
            "css": fileHtml,
            "js": fileHtml,
            "json": fileHtml,
            "xml": fileHtml,
            "swift": fileHtml,
            // Compression
            "zip": fileZip,
            "rar": fileZip,
            "7z": fileZip,
            "tar": fileZip,
            "gz": fileZip,
            "tar.gz": fileZip
        ]
    }

    // MARK: - v5 File Type Images (TODO: Move to Common Module)

    private var filePdf: UIImage { loadImage("file-pdf") ?? fileTypePreviewFallback }
    private var fileDoc: UIImage { loadImage("file-doc") ?? fileTypePreviewFallback }
    private var filePpt: UIImage { loadImage("file-ppt") ?? fileTypePreviewFallback }
    private var fileXls: UIImage { loadImage("file-xls") ?? fileTypePreviewFallback }
    private var fileMp3: UIImage { loadImage("file-mp3") ?? fileTypePreviewFallback }
    private var fileMp4: UIImage { loadImage("file-mp4") ?? fileTypePreviewFallback }
    private var fileHtml: UIImage { loadImage("file-html") ?? fileTypePreviewFallback }
    private var fileZip: UIImage { loadImage("file-zip") ?? fileTypePreviewFallback }

    private var fileTypePreviewFallback: UIImage {
        loadImage("file-other") ?? images.fileFallback
    }

    private func loadImage(_ name: String) -> UIImage? {
        UIImage(named: name, in: .streamChatUI, compatibleWith: nil)
    }
}
