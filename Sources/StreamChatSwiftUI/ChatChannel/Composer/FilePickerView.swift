//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// SwiftUI wrapper for picking files from the device.
public struct FilePickerView: UIViewControllerRepresentable {
    @Binding var fileURLs: [URL]

    public func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.item])
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = true
        return picker
    }

    public func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // We don't need handling updates of the VC at the moment.
    }

    public func makeCoordinator() -> FilePickerView.Coordinator {
        FilePickerView.Coordinator(fileURLs: $fileURLs)
    }

    public class Coordinator: NSObject, UIDocumentPickerDelegate {
        var fileURLs: Binding<[URL]>

        init(fileURLs: Binding<[URL]>) {
            self.fileURLs = fileURLs
        }

        public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            withAnimation {
                fileURLs.wrappedValue.append(contentsOf: urls)
            }
        }
    }
}
