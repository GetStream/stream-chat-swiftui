//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import AVFoundation
import StreamChat
import SwiftUI

/// View for the camera attachment picker.
/// Displays either the "open camera" prompt or the "access denied"
/// prompt depending on the current authorization status.
struct AttachmentCameraPickerView: View {
    @Binding var cameraPickerShown: Bool
    var cameraImageAdded: @MainActor (AddedAsset) -> Void

    @State private var cameraStatus: AVAuthorizationStatus

    init(
        cameraPickerShown: Binding<Bool>,
        cameraImageAdded: @escaping @MainActor (AddedAsset) -> Void,
        initialCameraStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    ) {
        _cameraPickerShown = cameraPickerShown
        self.cameraImageAdded = cameraImageAdded
        _cameraStatus = State(initialValue: initialCameraStatus)
    }

    var body: some View {
        Group {
            if cameraStatus == .denied || cameraStatus == .restricted {
                CameraAccessDeniedPromptView()
            } else {
                CameraOpenPromptView(onTap: {
                    openCamera()
                })
                .fullScreenCover(isPresented: $cameraPickerShown) {
                    CameraImagePickerView(cameraImageAdded: cameraImageAdded)
                }
                .restoresAccessibilityFocusOnDismiss(of: $cameraPickerShown)
                .onLoad {
                    openCamera()
                }
            }
        }
    }

    // MARK: - Private

    private func openCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            cameraPickerShown = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        cameraPickerShown = true
                    } else {
                        cameraStatus = .denied
                    }
                }
            }
        default:
            break
        }
    }
}

// MARK: - Prompt Views

/// Prompt view displayed when the camera tab is selected and access is granted.
public struct CameraOpenPromptView: View {
    @Injected(\.images) private var images

    var onTap: @MainActor () -> Void

    public init(onTap: @escaping @MainActor () -> Void) {
        self.onTap = onTap
    }

    public var body: some View {
        AttachmentPickerPromptView(
            image: Image(uiImage: images.attachmentCameraIcon),
            description: L10n.Composer.Camera.takePhoto,
            buttonText: L10n.Composer.Camera.openCamera,
            onTap: onTap
        )
    }
}

/// Prompt view displayed when camera access has been denied or restricted.
public struct CameraAccessDeniedPromptView: View {
    @Injected(\.images) private var images

    public init() {}

    public var body: some View {
        AttachmentPickerPromptView(
            image: Image(uiImage: images.attachmentCameraIcon),
            description: L10n.Composer.Camera.noAccess,
            buttonText: L10n.Composer.Camera.accessSettings,
            onTap: {
                openSettings()
            }
        )
    }
}

// MARK: - Camera Image Picker

/// View presented in a full-screen cover to capture photos/videos.
struct CameraImagePickerView: View {
    var cameraImageAdded: (AddedAsset) -> Void

    var body: some View {
        AttachmentImagePickerView(sourceType: .camera) { addedImage in
            cameraImageAdded(addedImage)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

/// Image picker for loading images.
struct AttachmentImagePickerView: UIViewControllerRepresentable {
    @Injected(\.utils) var utils

    let sourceType: UIImagePickerController.SourceType

    var onAssetPicked: (AddedAsset) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let pickerController = StreamCameraImagePickerController()
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

    typealias Coordinator = ImagePickerCoordinator
}

/// `UIImagePickerController` subclass that clears the accessibility label
/// inherited from the SDK module so VoiceOver stops announcing "StreamChat"
/// in between Apple's native camera elements (e.g. "Viewfinder, StreamChat,
/// flash auto focus").
private final class StreamCameraImagePickerController: UIImagePickerController {
    override func viewDidLoad() {
        super.viewDidLoad()
        accessibilityLabel = ""
        view.accessibilityLabel = ""
    }
}

final class ImagePickerCoordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var parent: AttachmentImagePickerView

    init(_ control: AttachmentImagePickerView) {
        parent = control
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let uiImage = info[.originalImage] as? UIImage,
           let imageURL = try? uiImage.saveAsJpgToTemporaryUrl() {
            let addedImage = AddedAsset(
                image: uiImage,
                id: UUID().uuidString,
                url: imageURL,
                type: .image,
                originalWidth: Double(uiImage.size.width * uiImage.scale),
                originalHeight: Double(uiImage.size.height * uiImage.scale)
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
                let duration = CMTimeGetSeconds(asset.duration)
                let videoTrack = asset.tracks(withMediaType: .video).first
                let naturalSize = videoTrack?.naturalSize ?? .zero
                let addedVideo = AddedAsset(
                    image: thumbnail,
                    id: UUID().uuidString,
                    url: videoURL,
                    type: .video,
                    originalWidth: Double(naturalSize.width),
                    originalHeight: Double(naturalSize.height),
                    duration: duration.isFinite ? duration : nil
                )
                parent.onAssetPicked(addedVideo)
            } catch {
                log.debug("Error generating thumbnail: \(error.localizedDescription)")
            }
        }

        dismiss(picker)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(picker)
    }

    private func dismiss(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
