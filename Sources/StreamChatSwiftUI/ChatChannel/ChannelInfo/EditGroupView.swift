//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Sheet presented when the user taps "Edit" on a group channel info screen.
/// Allows changing the group avatar and name.
public struct EditGroupView<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    let factory: Factory
    @ObservedObject var viewModel: ChatChannelInfoViewModel

    @State private var name: String
    @State private var selectedImage: UIImage?
    @State private var avatarPickerSheetShown = false
    @State private var cameraPickerShown = false
    @State private var libraryPickerShown = false

    public init(factory: Factory = DefaultViewFactory.shared, viewModel: ChatChannelInfoViewModel) {
        self.factory = factory
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
                    factory: factory,
                    viewModel: viewModel,
                    name: name,
                    selectedImage: selectedImage
                )
            )
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $avatarPickerSheetShown) {
            GroupAvatarPickerSheetView(
                onCamera: {
                    avatarPickerSheetShown = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        cameraPickerShown = true
                    }
                },
                onLibrary: {
                    avatarPickerSheetShown = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        libraryPickerShown = true
                    }
                },
                onReset: {
                    selectedImage = nil
                    avatarPickerSheetShown = false
                },
                onDismiss: {
                    avatarPickerSheetShown = false
                }
            )
            .modifier(PresentationDetentsModifier(sheetSizes: [.custom(280), .medium]))
        }
        .sheet(isPresented: $cameraPickerShown) {
            GroupAvatarImagePickerView(source: .camera, selectedImage: $selectedImage)
        }
        .sheet(isPresented: $libraryPickerShown) {
            GroupAvatarImagePickerView(source: .photoLibrary, selectedImage: $selectedImage)
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
                    factory.makeChannelAvatarView(
                        options: ChannelAvatarViewOptions(
                            channel: viewModel.channel,
                            size: AvatarSize.extraExtraLarge,
                            showsIndicator: false,
                            showsBorder: false
                        )
                    )
                }
            }

            Button(L10n.ChatInfo.Edit.upload) {
                avatarPickerSheetShown = true
            }
            .font(fonts.bodyBold)
            .foregroundColor(Color(colors.accentPrimary))
            .padding()
        }
        .frame(maxWidth: .infinity)
    }

    private var nameField: some View {
        TextField(L10n.ChatInfo.Edit.groupName, text: $name)
            .font(fonts.body)
            .foregroundColor(Color(colors.textPrimary))
            .padding(tokens.spacingMd)
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

// MARK: - Avatar Picker Sheet

struct GroupAvatarPickerSheetView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens
    @Injected(\.images) private var images

    var onCamera: () -> Void
    var onLibrary: () -> Void
    var onReset: () -> Void
    var onDismiss: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                actionRow(
                    iconName: "camera",
                    title: L10n.ChatInfo.Edit.Picture.camera,
                    isDestructive: false,
                    action: onCamera
                )
                actionRow(
                    iconName: "photo",
                    title: L10n.ChatInfo.Edit.Picture.library,
                    isDestructive: false,
                    action: onLibrary
                )
                actionRow(
                    iconName: "trash",
                    title: L10n.ChatInfo.Edit.Picture.reset,
                    isDestructive: true,
                    action: onReset
                )
                Spacer()
            }
            .background(Color(colors.backgroundElevation1).edgesIgnoringSafeArea(.all))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(L10n.ChatInfo.Edit.Picture.title)
                        .font(fonts.bodyBold)
                        .foregroundColor(Color(colors.navigationBarTitle))
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        onDismiss()
                    } label: {
                        Image(uiImage: images.close)
                            .foregroundColor(Color(colors.textSecondary))
                    }
                }
            }
        }
    }

    private func actionRow(
        iconName: String,
        title: String,
        isDestructive: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: tokens.spacingMd) {
                Image(systemName: iconName)
                    .frame(width: tokens.spacingLg)
                    .foregroundColor(isDestructive ? Color(colors.alert) : Color(colors.textPrimary))
                Text(title)
                    .font(fonts.body)
                    .foregroundColor(isDestructive ? Color(colors.alert) : Color(colors.textPrimary))
                Spacer()
            }
            .padding(.horizontal, tokens.spacingMd)
            .padding(.vertical, tokens.spacingMd)
        }
    }
}

// MARK: - Toolbar

private struct EditGroupToolbarModifier<Factory: ViewFactory>: ViewModifier {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens

    let factory: Factory
    @ObservedObject var viewModel: ChatChannelInfoViewModel

    let name: String
    let selectedImage: UIImage?

    func body(content: Content) -> some View {
        content
            .toolbarThemed {
                toolbarContent()
            }
    }

    @ToolbarContentBuilder private func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                viewModel.editGroupShown = false
            } label: {
                Image(systemName: "xmark")
                    .renderingMode(.template)
                    .font(.system(size: 12))
                    .foregroundColor(Color(colors.buttonSecondaryText))
            }
        }

        ToolbarItem(placement: .principal) {
            Text(L10n.ChatInfo.edit)
                .font(fonts.bodyBold)
                .foregroundColor(Color(colors.navigationBarTitle))
        }

        ToolbarItem(placement: .topBarTrailing) {
            if viewModel.isUploadingGroupAvatar {
                ProgressView()
                    .frame(width: tokens.iconSizeLg, height: tokens.iconSizeLg)
            } else {
                confirmButton
            }
        }
    }

    private var confirmButton: some View {
        Button {
            viewModel.saveGroupEdit(name: name, image: selectedImage)
        } label: {
            Image(systemName: "checkmark")
                .renderingMode(.template)
                .font(.system(size: 16))
                .foregroundColor(Color(colors.buttonPrimaryTextOnAccent))
        }
        .modifier(factory.styles.makeToolbarConfirmActionModifier(options: .init()))
        .accessibilityLabel(Text(L10n.ChatInfo.Edit.save))
        .accessibilityIdentifier("EditGroupConfirmButton")
    }
}

// MARK: - Image Picker

struct GroupAvatarImagePickerView: UIViewControllerRepresentable {
    var source: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = source
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
