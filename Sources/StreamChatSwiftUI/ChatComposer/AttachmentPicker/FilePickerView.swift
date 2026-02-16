//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

/// SwiftUI wrapper for picking files from the device.
public struct FilePickerView: UIViewControllerRepresentable {
    @Injected(\.chatClient) var client
    var onFilesPicked: ([URL]) -> Void
    
    public init(onFilesPicked: @escaping ([URL]) -> Void) {
        self.onFilesPicked = onFilesPicked
    }

    public func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: openingContentTypes)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = true
        return picker
    }
    
    var openingContentTypes: [UTType] {
        guard let settings = client.appSettings else { return [.item] }
        let allowedUTITypes = settings.fileUploadConfig.allowedUTITypes.compactMap { UTType($0) }
        return allowedUTITypes.isEmpty ? [.item] : allowedUTITypes
    }

    public func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // We don't need handling updates of the VC at the moment.
    }

    public func makeCoordinator() -> FilePickerView.Coordinator {
        FilePickerView.Coordinator(onFilesPicked: onFilesPicked)
    }

    public class Coordinator: NSObject, UIDocumentPickerDelegate {
        var onFilesPicked: ([URL]) -> Void

        init(onFilesPicked: @escaping ([URL]) -> Void) {
            self.onFilesPicked = onFilesPicked
        }

        public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            withAnimation {
                onFilesPicked(urls)
            }
        }
    }
}
