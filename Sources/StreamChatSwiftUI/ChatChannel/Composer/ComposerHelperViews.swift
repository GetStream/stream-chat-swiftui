//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View used to indicate that an asset is a video.
struct VideoIndicatorView: View {
    
    @Injected(\.images) private var images
    
    var body: some View {
        BottomLeftView {
            Image(uiImage: images.videoIndicator)
                .makeCustomizable()
                .frame(width: 22)
                .padding(2)
                .applyDefaultIconOverlayStyle()
        }
    }
}

/// View displaying the duration of the video.
struct VideoDurationIndicatorView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    
    var duration: String
    
    var body: some View {
        BottomRightView {
            Text(duration)
                .foregroundColor(Color(colors.staticColorText))
                .font(fonts.footnoteBold)
                .padding(.all, 4)
        }
    }
}

/// Container that displays attachment types.
public struct AttachmentTypeContainer<Content: View>: View {
    @Injected(\.colors) private var colors
    
    var content: () -> Content
    
    public init(content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Color(colors.background)
                .frame(height: 20)
            
            content()
                .background(Color(colors.background))
        }
        .background(Color(colors.background1))
        .cornerRadius(16)
    }
}

/// View shown after the native file picker is closed.
struct FilePickerDisplayView: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    
    @Binding var filePickerShown: Bool
    @Binding var addedFileURLs: [URL]
    
    var body: some View {
        AttachmentTypeContainer {
            ZStack {
                Button {
                    filePickerShown = true
                } label: {
                    Text(L10n.Composer.Files.addMore)
                        .font(fonts.bodyBold)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundColor(Color(colors.highlightedAccentBackground))
            .sheet(isPresented: $filePickerShown) {
                FilePickerView(fileURLs: $addedFileURLs)
            }
        }
    }
}

/// View displayed when the camera picker is shown.
struct CameraPickerDisplayView: View {
    @Binding var selectedPickerState: AttachmentPickerState
    @Binding var cameraPickerShown: Bool
    
    var cameraImageAdded: (AddedAsset) -> Void
    
    var body: some View {
        Spacer()
            .sheet(isPresented: $cameraPickerShown, onDismiss: {
                selectedPickerState = .photos
            }) {
                ImagePickerView(sourceType: .camera) { addedImage in
                    cameraImageAdded(addedImage)
                }
            }
    }
}

/// View displayed when there's no access permission to the photo library.
struct AssetsAccessPermissionView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(L10n.Composer.Images.noAccessLibrary)
                .font(fonts.body)
            Button {
                openAppPrivacySettings()
            } label: {
                Text(L10n.Composer.Images.accessSettings)
                    .font(fonts.bodyBold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(colors.highlightedAccentBackground))
            }
            Spacer()
        }
        .padding(.all, 8)
    }
    
    func openAppPrivacySettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

/// View for the quoted message header.
struct QuotedMessageHeaderView: View {
    
    @Injected(\.fonts) var fonts
    
    @Binding var quotedMessage: ChatMessage?
    
    var body: some View {
        ZStack {
            Text(L10n.Composer.Title.reply)
                .font(fonts.bodyBold)
            
            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        quotedMessage = nil
                    }
                }, label: {
                    DiscardButtonView()
                })
            }
        }
        .frame(height: 32)
    }
}

/// View for the edit message header.
struct EditMessageHeaderView: View {
    
    @Injected(\.fonts) var fonts
    
    @Binding var editedMessage: ChatMessage?
    
    var body: some View {
        ZStack {
            Text(L10n.Composer.Title.edit)
                .font(fonts.bodyBold)
            
            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        editedMessage = nil
                    }
                }, label: {
                    DiscardButtonView()
                })
            }
        }
        .frame(height: 32)
    }
}
