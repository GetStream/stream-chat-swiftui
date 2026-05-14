//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI
import UniformTypeIdentifiers

/// View for the file attachment picker.
/// Shows a prompt to open the file picker, and presents the
/// document picker in a sheet.
struct AttachmentFilePickerView: View {
    @Binding var filePickerShown: Bool
    var onFilesPicked: @MainActor ([URL]) -> Void

    var body: some View {
        FileOpenPromptView(onTap: {
            filePickerShown = true
        })
        .sheet(isPresented: $filePickerShown) {
            DocumentPickerView(onFilesPicked: { urls in
                onFilesPicked(urls)
            })
        }
        .restoresAccessibilityFocusOnDismiss(of: $filePickerShown)
        .onLoad {
            filePickerShown = true
        }
    }
}

// MARK: - Prompt View

/// Prompt view displayed when the file tab is selected.
public struct FileOpenPromptView: View {
    @Injected(\.images) private var images

    var onTap: @MainActor () -> Void

    public init(onTap: @escaping @MainActor () -> Void) {
        self.onTap = onTap
    }

    public var body: some View {
        AttachmentPickerPromptView(
            image: Image(uiImage: images.attachmentDocumentIcon),
            description: L10n.Composer.Files.selectFiles,
            buttonText: L10n.Composer.Files.openFiles,
            onTap: onTap
        )
    }
}

// MARK: - Document Picker

/// SwiftUI wrapper for picking files from the device.
public struct DocumentPickerView: UIViewControllerRepresentable {
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

    public func makeCoordinator() -> DocumentPickerView.Coordinator {
        DocumentPickerView.Coordinator(onFilesPicked: onFilesPicked)
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
