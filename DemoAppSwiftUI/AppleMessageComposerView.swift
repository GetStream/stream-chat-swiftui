//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

@available(iOS 15.0, *)
struct AppleMessageComposerView<Factory: ViewFactory>: View, KeyboardReadable {
        
    @State var text = ""
    @State var shouldShow = false
    
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    // Initial popup size, before the keyboard is shown.
    @State private var popupSize: CGFloat = 350
    @State private var composerHeight: CGFloat = 0
    @State private var keyboardShown = false
    @State private var editedMessageWillShow = false

    private var factory: Factory
    private var channelConfig: ChannelConfig?
    @Binding var quotedMessage: ChatMessage?
    @Binding var editedMessage: ChatMessage?
    
    @State private var state: AnimationState = .initial
    @State private var listScale: CGFloat = 0

    public init(
        viewFactory: Factory,
        viewModel: MessageComposerViewModel? = nil,
        channelController: ChatChannelController,
        messageController: ChatMessageController? = nil,
        quotedMessage: Binding<ChatMessage?>,
        editedMessage: Binding<ChatMessage?>,
        onMessageSent: @escaping () -> Void
    ) {
        factory = viewFactory
        channelConfig = channelController.channel?.config
        let vm = viewModel ?? ViewModelsFactory.makeMessageComposerViewModel(
            with: channelController,
            messageController: messageController
        )
        _viewModel = StateObject(
            wrappedValue: vm
        )
        _quotedMessage = quotedMessage
        _editedMessage = editedMessage
        self.onMessageSent = onMessageSent
    }

    @StateObject var viewModel: MessageComposerViewModel

    var onMessageSent: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom) {
                Button {
                    withAnimation(.bouncy) {
                        switch state {
                        case .initial:
                            listScale = 1
                            state = .expanded
                        case .expanded:
                            listScale = 0
                            state = .initial
                        }
                    }
                } label: {
                    Image(systemName: "plus")
                        .padding(.all, 8)
                        .foregroundColor(Color.gray)
                        .background(Color(colors.background1))
                        .clipShape(Circle())
                }
                .padding(.bottom, 4)

                ComposerInputView(
                    factory: DefaultViewFactory.shared,
                    text: $viewModel.text,
                    selectedRangeLocation: $viewModel.selectedRangeLocation,
                    command: $viewModel.composerCommand,
                    addedAssets: viewModel.addedAssets,
                    addedFileURLs: viewModel.addedFileURLs,
                    addedCustomAttachments: viewModel.addedCustomAttachments,
                    quotedMessage: $quotedMessage,
                    maxMessageLength: channelConfig?.maxMessageLength,
                    cooldownDuration: viewModel.cooldownDuration,
                    onCustomAttachmentTap: viewModel.customAttachmentTapped(_:),
                    removeAttachmentWithId: viewModel.removeAttachment(with:)
                )
                .overlay(
                    viewModel.sendButtonEnabled ? sendButton : nil
                )
            }
            .padding(.all, 8)

            factory.makeAttachmentPickerView(
                attachmentPickerState: $viewModel.pickerState,
                filePickerShown: $viewModel.filePickerShown,
                cameraPickerShown: $viewModel.cameraPickerShown,
                addedFileURLs: $viewModel.addedFileURLs,
                onPickerStateChange: viewModel.change(pickerState:),
                photoLibraryAssets: viewModel.imageAssets,
                onAssetTap: viewModel.imageTapped(_:),
                onCustomAttachmentTap: viewModel.customAttachmentTapped(_:),
                isAssetSelected: viewModel.isImageSelected(with:),
                addedCustomAttachments: viewModel.addedCustomAttachments,
                cameraImageAdded: viewModel.cameraImageAdded(_:),
                askForAssetsAccessPermissions: viewModel.askForPhotosPermission,
                isDisplayed: viewModel.overlayShown,
                height: viewModel.overlayShown ? popupSize : 0,
                popupHeight: popupSize
            )
        }
        .background(
            GeometryReader { proxy in
                let frame = proxy.frame(in: .local)
                let height = frame.height
                Color.clear.preference(key: HeightPreferenceKey.self, value: height)
            }
        )
        .onPreferenceChange(HeightPreferenceKey.self) { value in
            if let value = value, value != composerHeight {
                self.composerHeight = value
            }
        }
        .onReceive(keyboardWillChangePublisher) { visible in
            if visible && !keyboardShown {
                if viewModel.composerCommand == nil && !editedMessageWillShow {
                    withAnimation(.easeInOut(duration: 0.02)) {
                        viewModel.pickerTypeState = .expanded(.none)
                    }
                }
            }
            keyboardShown = visible
            editedMessageWillShow = false
        }
        .onReceive(keyboardHeight) { height in
            if height > 0 && height != popupSize {
                self.popupSize = height - bottomSafeArea
            }
        }
        .overlay(
            viewModel.showCommandsOverlay ?
                factory.makeCommandsContainerView(
                    suggestions: viewModel.suggestions,
                    handleCommand: { commandInfo in
                        viewModel.handleCommand(
                            for: $viewModel.text,
                            selectedRangeLocation: $viewModel.selectedRangeLocation,
                            command: $viewModel.composerCommand,
                            extraData: commandInfo
                        )
                    }
                )
                .offset(y: -composerHeight)
                .animation(nil) : nil,
            alignment: .bottom
        )
        .modifier(factory.makeComposerViewModifier())
        .onChange(of: editedMessage) { _ in
            viewModel.text = editedMessage?.text ?? ""
            if editedMessage != nil {
                editedMessageWillShow = true
                viewModel.selectedRangeLocation = editedMessage?.text.count ?? 0
            }
        }
        .accessibilityElement(children: .contain)
        .overlay(
            ComposerActionsView(viewModel: viewModel, state: $state, listScale: $listScale)
                .offset(y: -(UIScreen.main.bounds.height - composerHeight) / 2 + 80)
                .allowsHitTesting(state == .expanded)
        )
    }
    
    private var sendButton: some View {
        BottomRightView {
            Button {
                viewModel.sendMessage(quotedMessage: nil, editedMessage: nil) {
                    onMessageSent()
                }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24)
                    .foregroundColor(.blue)
            }
            .padding(.trailing, 4)
            .padding(.bottom, !viewModel.addedAssets.isEmpty ? 16 : 8)
        }
    }
}

@available(iOS 15.0, *)
struct BlurredBackground: View {
    var body: some View {
        Color.clear
            .frame(
                width: UIScreen.main.bounds.width,
                height: UIScreen.main.bounds.height
            )
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 16.0)
            )
    }
}

struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat? = nil

    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        value = value ?? nextValue()
    }
}

enum AnimationState {
    case initial, expanded
}

struct ComposerAction: Equatable, Identifiable {
    static func == (lhs: ComposerAction, rhs: ComposerAction) -> Bool {
        lhs.id == rhs.id
    }
    
    var imageName: String
    var text: String
    var color: Color
    var action: () -> Void
    var id: String {
        "\(imageName)-\(text)"
    }
}

@available(iOS 15.0, *)
struct ComposerActionsView: View {
    
    @ObservedObject var viewModel: MessageComposerViewModel
    
    @State var composerActions: [ComposerAction] = []
    
    @Binding var state: AnimationState
    @Binding var listScale: CGFloat
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color.white.opacity(state == .initial ? 0.2 : 0.5)
            
            BlurredBackground()
                .opacity(state == .initial ? 0.0 : 1)
            
            VStack(alignment: .leading, spacing: 30) {
                ForEach(composerActions) { composerAction in
                    Button {
                        withAnimation {
                            state = .initial
                            composerAction.action()
                        }
                    } label: {
                        ComposerActionView(composerAction: composerAction)
                    }
                }
            }
            .padding(.leading, 40)
            .padding(.bottom, 84)
            .scaleEffect(
                CGSize(
                    width: state == .initial ? 0 : 1,
                    height: state == .initial ? 0 : 1
                )
            )
            .offset(
                x: state == .initial ? -75 : 0,
                y: state == .initial ? 90 : 0
            )
        }
        .onAppear {
            setupComposerActions()
        }
        .edgesIgnoringSafeArea(.all)
        .onTapGesture {
            withAnimation(.bouncy) {
                switch state {
                case .initial:
                    listScale = 1
                    state = .expanded
                case .expanded:
                    listScale = 0
                    state = .initial
                }
            }
        }
    }
    
    private func setupComposerActions() {
        let imageAction: () -> Void = {
            viewModel.pickerTypeState = .expanded(.media)
            viewModel.pickerState = .photos
        }
        let commandsAction: () -> Void = {
            viewModel.pickerTypeState = .expanded(.instantCommands)
        }
        let filesAction: () -> Void = {
            viewModel.pickerTypeState = .expanded(.media)
            viewModel.pickerState = .files
        }
        let cameraAction: () -> Void = {
            viewModel.pickerTypeState = .expanded(.media)
            viewModel.pickerState = .camera
        }

        composerActions = [
            ComposerAction(
                imageName: "photo.on.rectangle",
                text: "Photos",
                color: .purple,
                action: imageAction
            ),
            ComposerAction(
                imageName: "camera.circle.fill",
                text: "Camera",
                color: .gray,
                action: cameraAction
            ),
            ComposerAction(
                imageName: "folder.circle",
                text: "Files",
                color: .indigo,
                action: filesAction
            ),
            ComposerAction(
                imageName: "command.circle.fill",
                text: "Commands",
                color: .orange,
                action: commandsAction
            )
        ]
    }
}

struct ComposerActionView: View {
    
    private let imageSize: CGFloat = 34
    
    var composerAction: ComposerAction
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: composerAction.imageName)
                .resizable()
                .scaledToFit()
                .foregroundColor(composerAction.color)
                .frame(width: imageSize, height: imageSize)
            
            Text(composerAction.text)
                .foregroundColor(.primary)
                .font(.title2)
        }
    }
}
