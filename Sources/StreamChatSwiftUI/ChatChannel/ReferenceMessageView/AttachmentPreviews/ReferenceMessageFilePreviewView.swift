//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// File attachment preview for message references.
public struct ReferenceMessageFilePreviewView: View {
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
            .frame(width: previewSize, height: previewSize)
    }

    private var fileIcon: UIImage {
        fileTypePreviews[fileExtension] ?? fileTypePreviewFallback
    }

    private var previewSize: CGFloat {
        tokens.spacing3xl // 40pt
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

    private var fileTypePreviewFallback: UIImage {
        loadV5Image("file-other") ?? images.fileFallback
    }

    // MARK: - v5 File Type Images

    private var filePdf: UIImage { loadV5Image("file-pdf") ?? images.fileFallback }
    private var fileDoc: UIImage { loadV5Image("file-doc") ?? images.fileFallback }
    private var filePpt: UIImage { loadV5Image("file-ppt") ?? images.fileFallback }
    private var fileXls: UIImage { loadV5Image("file-xls") ?? images.fileFallback }
    private var fileMp3: UIImage { loadV5Image("file-mp3") ?? images.fileFallback }
    private var fileMp4: UIImage { loadV5Image("file-mp4") ?? images.fileFallback }
    private var fileHtml: UIImage { loadV5Image("file-html") ?? images.fileFallback }
    private var fileZip: UIImage { loadV5Image("file-zip") ?? images.fileFallback }

    private func loadV5Image(_ name: String) -> UIImage? {
        UIImage(named: name, in: .streamChatUI, compatibleWith: nil)
    }
}
