//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import AVFoundation
import StreamChat
import SwiftUI

/// Image picker for loading images.
struct ImagePickerView: UIViewControllerRepresentable {
    @Injected(\.utils) var utils
    
    let sourceType: UIImagePickerController.SourceType

    var onAssetPicked: (AddedAsset) -> Void
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let pickerController = UIImagePickerController()
        pickerController.delegate = context.coordinator
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            pickerController.sourceType = sourceType
        }
        let gallerySupportedTypes = utils.composerConfig.gallerySupportedTypes
        if gallerySupportedTypes == .images {
            pickerController.mediaTypes = ["public.image"]
        } else if gallerySupportedTypes == .videos {
            pickerController.mediaTypes = ["public.movie"]
        } else {
            pickerController.mediaTypes = ["public.image", "public.movie"]
        }
        
        return pickerController
    }

    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: Context
    ) { /* Not needed. */ }

    func makeCoordinator() -> ImagePickerCoordinator {
        Coordinator(self)
    }
}

final class ImagePickerCoordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var parent: ImagePickerView

    init(_ control: ImagePickerView) {
        parent = control
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let uiImage = info[.originalImage] as? UIImage,
           let imageURL = try? uiImage.temporaryLocalFileUrl() {
            let addedImage = AddedAsset(
                image: uiImage,
                id: UUID().uuidString,
                url: imageURL,
                type: .image
            )
            parent.onAssetPicked(addedImage)
        } else if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            do {
                let asset = AVURLAsset(url: videoURL, options: nil)
                let imageGenerator = AVAssetImageGenerator(asset: asset)
                imageGenerator.appliesPreferredTrackTransform = true
                let cgImage = try imageGenerator.copyCGImage(
                    at: CMTimeMake(value: 0, timescale: 1),
                    actualTime: nil
                )
                let thumbnail = UIImage(cgImage: cgImage)
                let addedVideo = AddedAsset(
                    image: thumbnail,
                    id: UUID().uuidString,
                    url: videoURL,
                    type: .video
                )
                parent.onAssetPicked(addedVideo)
            } catch {
                log.debug("Error generating thumbnail: \(error.localizedDescription)")
            }
        }

        dismiss()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss()
    }

    private func dismiss() {
        parent.presentationMode.wrappedValue.dismiss()
    }
}
