//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

@available(iOS 15.0, *)
struct AppleMessageComposerView<Factory: ViewFactory>: View, KeyboardReadable {
    @Injected(\.colors) private var colors

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

    @StateObject var viewModel: MessageComposerViewModel

    public init(
        viewFactory: Factory,
        viewModel: MessageComposerViewModel? = nil,
        channelController: ChatChannelController,
        messageController: ChatMessageController? = nil,
        quotedMessage: Binding<ChatMessage?>,
        editedMessage: Binding<ChatMessage?>,
        willSendMessage: @escaping () -> Void
    ) {
        factory = viewFactory
        channelConfig = channelController.channel?.config
        let vm = viewModel ?? ViewModelsFactory.makeMessageComposerViewModel(
            with: channelController,
            messageController: messageController,
            quotedMessage: quotedMessage,
            editedMessage: editedMessage,
            willSendMessage: willSendMessage
        )
        _viewModel = StateObject(wrappedValue: vm)
        _quotedMessage = quotedMessage
        _editedMessage = editedMessage
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom) {
                Button {
                    withAnimation(.interpolatingSpring(stiffness: 170, damping: 25)) {
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
                        .padding(.all, 12)
                        .foregroundColor(Color.gray)
                        .background(Color(colors.backgroundCoreSurfaceSubtle))
                        .clipShape(Circle())
                }
                .padding(.bottom, 4)

                factory.makeComposerInputView(
                    options: ComposerInputViewOptions(
                        channelController: viewModel.channelController,
                        text: $viewModel.text,
                        selectedRangeLocation: $viewModel.selectedRangeLocation,
                        command: $viewModel.composerCommand,
                        recordingState: $viewModel.recordingState,
                        recordingGestureLocation: $viewModel.recordingGestureLocation,
                        composerAssets: viewModel.composerAssets,
                        addedCustomAttachments: viewModel.addedCustomAttachments,
                        addedVoiceRecordings: viewModel.addedVoiceRecordings,
                        quotedMessage: $quotedMessage,
                        editedMessage: $editedMessage,
                        maxMessageLength: channelConfig?.maxMessageLength,
                        cooldownDuration: viewModel.cooldownDuration,
                        hasContent: viewModel.hasContent,
                        canSendMessage: viewModel.canSendMessage,
                        audioRecordingInfo: viewModel.audioRecordingInfo,
                        pendingAudioRecordingURL: viewModel.pendingAudioRecording?.url,
                        onCustomAttachmentTap: viewModel.customAttachmentTapped(_:),
                        removeAttachmentWithId: viewModel.removeAttachment(with:),
                        sendMessage: sendMessage,
                        onImagePasted: viewModel.imagePasted,
                        startRecording: viewModel.startRecording,
                        stopRecording: viewModel.stopRecording,
                        confirmRecording: viewModel.confirmRecording,
                        discardRecording: viewModel.discardRecording,
                        previewRecording: viewModel.previewRecording,
                        showRecordingTip: viewModel.showRecordingTip,
                        sendInChannelShown: viewModel.sendInChannelShown,
                        showReplyInChannel: $viewModel.showReplyInChannel,
                        composerInputState: viewModel.composerInputState
                    )
                )
            }
            .padding(.all, 8)

            factory.makeAttachmentPickerView(
                options: AttachmentPickerViewOptions(
                    attachmentPickerState: $viewModel.pickerState,
                    filePickerShown: $viewModel.filePickerShown,
                    cameraPickerShown: $viewModel.cameraPickerShown,
                    onFilesPicked: viewModel.addFileURLs,
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
                    popupHeight: popupSize,
                    selectedAssetIds: viewModel.composerAssets.compactMap {
                        if case .addedAsset(let asset) = $0 { return asset.id }
                        return nil
                    },
                    channelController: viewModel.channelController,
                    messageController: viewModel.messageController,
                    canSendPoll: viewModel.canSendPoll,
                    instantCommands: viewModel.instantCommands,
                    onCommandSelected: { command in
                        viewModel.pickerTypeState = .expanded(.none)
                        viewModel.composerCommand = command
                        viewModel.handleCommand(
                            for: $viewModel.text,
                            selectedRangeLocation: $viewModel.selectedRangeLocation,
                            command: $viewModel.composerCommand,
                            extraData: ["instantCommand": command]
                        )
                        becomeFirstResponder()
                    }
                )
            )
            .offset(y: viewModel.overlayShown ? 0 : popupSize)
            .opacity(viewModel.overlayShown ? 1 : 0)
            .animation(.easeInOut(duration: 0.25))
        }
        .background(
            GeometryReader { proxy in
                let height = proxy.frame(in: .local).height
                Color.clear.preference(key: HeightPreferenceKey.self, value: height)
            }
        )
        .onPreferenceChange(HeightPreferenceKey.self) { value in
            Task { @MainActor in
                if let value, value != composerHeight {
                    composerHeight = value
                }
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
                popupSize = height - bottomSafeArea
            }
        }
        .modifier(factory.styles.makeComposerViewModifier(options: ComposerViewModifierOptions()))
        .background(
            Group {
                if viewModel.showSuggestionsOverlay {
                    factory.makeSuggestionsContainerView(
                        options: SuggestionsContainerViewOptions(
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
                    )
                }
            }
            .offset(y: -composerHeight),
            alignment: .bottom
        )
        .onChange(of: editedMessage) { _ in
            viewModel.fillEditedMessage(editedMessage)
            if editedMessage != nil {
                becomeFirstResponder()
                editedMessageWillShow = true
            }
        }
        .accessibilityElement(children: .contain)
        .overlay(
            ComposerActionsView(viewModel: viewModel, state: $state, listScale: $listScale)
                .offset(y: -(UIScreen.main.bounds.height - composerHeight) / 2 + 80)
                .allowsHitTesting(state == .expanded)
        )
    }

    private func sendMessage() {
        viewModel.sendMessage()
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
    static var defaultValue: CGFloat? { nil }

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
            withAnimation(.interpolatingSpring(stiffness: 170, damping: 25)) {
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
