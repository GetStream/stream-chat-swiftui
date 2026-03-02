//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Sheet presented when the user taps "Edit" on a group channel info screen.
/// Allows changing the group avatar and name.
public struct EditGroupView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    @ObservedObject var viewModel: ChatChannelInfoViewModel

    @State private var name: String
    @State private var selectedImage: UIImage?
    @State private var imagePickerShown = false

    public init(viewModel: ChatChannelInfoViewModel) {
        self.viewModel = viewModel
        _name = State(initialValue: viewModel.channelName)
    }

    public var body: some View {
        NavigationView {
            VStack(spacing: tokens.spacingXl) {
                avatarSection
                nameField
                Spacer()
            }
            .padding(.top, tokens.spacingXl)
            .background(Color(colors.backgroundCoreApp).edgesIgnoringSafeArea(.all))
            .modifier(
                EditGroupToolbarModifier(
                    viewModel: viewModel,
                    name: name,
                    selectedImage: selectedImage
                )
            )
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $imagePickerShown) {
            GroupAvatarImagePickerView(selectedImage: $selectedImage)
        }
    }

    private var avatarSection: some View {
        VStack(spacing: tokens.spacingXs) {
            Group {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: AvatarSize.extraExtraLarge, height: AvatarSize.extraExtraLarge)
                        .clipShape(Circle())
                } else {
                    ChannelAvatar(
                        channel: viewModel.channel,
                        size: AvatarSize.extraExtraLarge,
                        showsIndicator: false,
                        showsBorder: false
                    )
                }
            }

            Button(L10n.ChatInfo.Edit.upload) {
                imagePickerShown = true
            }
            .font(fonts.bodyBold)
            .foregroundColor(Color(colors.accentPrimary))
            .padding()
        }
        .frame(maxWidth: .infinity)
    }

    private var nameField: some View {
        Group {
            if viewModel.channel.isDirectMessageChannel {
                Text(name)
                    .font(fonts.body)
                    .foregroundColor(Color(colors.textPrimary))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(tokens.spacingMd)
            } else {
                TextField(L10n.ChatInfo.Edit.groupName, text: $name)
                    .font(fonts.body)
                    .foregroundColor(Color(colors.textPrimary))
                    .padding(tokens.spacingMd)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: tokens.radiusLg)
                .fill(Color(colors.backgroundCoreApp))
                .overlay(
                    RoundedRectangle(cornerRadius: tokens.radiusLg)
                        .stroke(Color(colors.borderCoreSubtle), lineWidth: 1)
                )
        )
        .padding(.horizontal, tokens.spacingMd)
    }
}

private struct EditGroupToolbarModifier: ViewModifier {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens
    
    @ObservedObject var viewModel: ChatChannelInfoViewModel
    
    let name: String
    let selectedImage: UIImage?

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .toolbarThemed {
                    toolbarContent()
                    #if compiler(>=6.2)
                        .sharedBackgroundVisibility(.hidden)
                    #endif
                }
        } else {
            content
                .toolbarThemed {
                    toolbarContent()
                }
        }
    }

    @ToolbarContentBuilder private func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(L10n.ChatInfo.edit)
                .font(fonts.bodyBold)
                .foregroundColor(Color(colors.navigationBarTitle))
        }
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                viewModel.editGroupShown = false
            } label: {
                Image(uiImage: images.close)
                    .foregroundColor(Color(colors.textSecondary))
            }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                viewModel.saveGroupEdit(name: name, image: selectedImage)
            } label: {
                if viewModel.isUploadingGroupAvatar {
                    ProgressView()
                        .frame(width: tokens.iconSizeLg, height: tokens.iconSizeLg)
                } else {
                    Image(uiImage: images.bigConfirmCheckmark)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: tokens.iconSizeLg)
                        .foregroundColor(Color(colors.accentPrimary))
                }
            }
            .disabled(viewModel.isUploadingGroupAvatar)
        }
    }
}

// MARK: - Image Picker

struct GroupAvatarImagePickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.image"]
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: GroupAvatarImagePickerView

        init(_ parent: GroupAvatarImagePickerView) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
