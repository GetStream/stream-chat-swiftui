//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

struct iMessagePocView: View {

    @Injected(\.colors) var colors

    @StateObject var viewModel: iMessageChatChannelListViewModel
    @StateObject private var channelHeaderLoader = ChannelHeaderLoader()

    private var factory = iMessageViewFactory.shared

    init() {
        _viewModel = StateObject(
            wrappedValue:
            iMessageChatChannelListViewModel(
                channelListController: nil,
                selectedChannelId: nil
            )
        )
    }

    var body: some View {
        NavigationView {
            VStack {
                if !viewModel.pinnedChannels.isEmpty {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(viewModel.pinnedChannels) { channel in
                                ChannelAvatarView(
                                    avatar: channelHeaderLoader.image(for: channel),
                                    showOnlineIndicator: false
                                )
                                .padding()
                            }
                        }
                    }
                    .frame(height: 60)
                }
                ChannelList(
                    factory: factory,
                    channels: viewModel.channels,
                    selectedChannel: $viewModel.selectedChannel,
                    swipedChannelId: $viewModel.swipedChannelId,
                    onlineIndicatorShown: viewModel.onlineIndicatorShown(for:),
                    imageLoader: channelHeaderLoader.image(for:),
                    onItemTap: { channel in
                        viewModel.selectedChannel = ChannelSelectionInfo(channel: channel, message: nil)
                    },
                    onItemAppear: viewModel.checkForChannels(index:),
                    channelNaming: viewModel.name(forChannel:),
                    channelDestination: factory.makeChannelDestination(),
                    trailingSwipeRightButtonTapped: viewModel.onDeleteTapped(channel:),
                    trailingSwipeLeftButtonTapped: viewModel.onMoreTapped(channel:),
                    leadingSwipeButtonTapped: viewModel.pinChannelTapped(_:)
                )
                .alert(isPresented: $viewModel.alertShown) {
                    switch viewModel.channelAlertType {
                    case let .deleteChannel(channel):
                        return Alert(
                            title: Text("Delete"),
                            message: Text("Are you sure you want to delete this channel?"),
                            primaryButton: .destructive(Text("Delete")) {
                                viewModel.delete(channel: channel)
                            },
                            secondaryButton: .cancel()
                        )
                    default:
                        return Alert.defaultErrorAlert
                    }
                }

                Spacer()
            }
            .blur(radius: (viewModel.customAlertShown || viewModel.alertShown) ? 6 : 0)
            .overlay(viewModel.customAlertShown ? customViewOverlay() : nil)
            .accentColor(colors.tintColor)
            .navigationTitle("Messages")
        }
    }

    @ViewBuilder
    private func customViewOverlay() -> some View {
        switch viewModel.customChannelPopupType {
        case let .moreActions(channel):
            factory.makeMoreChannelActionsView(
                for: channel,
                swipedChannelId: $viewModel.swipedChannelId
            ) {
                withAnimation {
                    viewModel.customChannelPopupType = nil
                }
            } onError: { error in
                viewModel.showErrorPopup(error)
            }
            .edgesIgnoringSafeArea(.all)
        default:
            EmptyView()
        }
    }
}

class iMessageChatChannelListViewModel: ChatChannelListViewModel {

    @Published var pinnedChannels = [ChatChannel]()

    func pinChannelTapped(_ channel: ChatChannel) {
        if !pinnedChannels.contains(channel) {
            pinnedChannels.append(channel)
        }
    }
}

class iMessageViewFactory: ViewFactory {

    @Injected(\.chatClient) var chatClient
    @Injected(\.colors) var colors

    static let shared = iMessageViewFactory()

    private init() {}

    func makeLeadingSwipeActionsView(
        channel: ChatChannel,
        offsetX: CGFloat,
        buttonWidth: CGFloat,
        buttonTapped: @escaping (ChatChannel) -> Void
    ) -> some View {
        HStack {
            ActionItemButton(imageName: "pin.fill") {
                buttonTapped(channel)
            }
            .frame(width: buttonWidth)
            .foregroundColor(Color.white)
            .background(Color.yellow)

            Spacer()
        }
    }
}

@available(iOS 15.0, *)
struct AppleMessageComposerView<Factory: ViewFactory>: View, KeyboardReadable {
    
    @State var options = [ComposerOption]()
    
    @State var text = ""
    @State var composerPopupShown = false
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
                    composerPopupShown = true
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
                    viewModel.sendButtonEnabled ?
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
                        .padding(.bottom, viewModel.addedAssets.count > 0 ? 16 : 8)
                    }
                    : nil
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
//                becomeFirstResponder()
                editedMessageWillShow = true
                viewModel.selectedRangeLocation = editedMessage?.text.count ?? 0
            }
        }
        .accessibilityElement(children: .contain)
        .onAppear {
            let imageAction: () -> () = {
                viewModel.pickerTypeState = .expanded(.media)
                viewModel.pickerState = .photos
            }
            let commandsAction: () -> () = {
                viewModel.pickerTypeState = .expanded(.instantCommands)
            }
            let filesAction: () -> () = {
                viewModel.pickerTypeState = .expanded(.media)
                viewModel.pickerState = .files
            }
            let cameraAction: () -> () = {
                viewModel.pickerTypeState = .expanded(.media)
                viewModel.pickerState = .camera
            }
            self.options = [
                ComposerOption(id: "images", title: "Images", imageName: "photo.circle.fill", action: imageAction),
                ComposerOption(id: "commands", title: "Instant Commands", imageName: "command.circle.fill", action: commandsAction),
                ComposerOption(id: "files", title: "Files", imageName: "folder.circle", action: filesAction),
                ComposerOption(id: "camera", title: "Camera", imageName: "camera.circle.fill", action: cameraAction)
            ]
        }
        .overlay(
            composerPopupShown ?
            ZStack {
                BlurredBackground()
                    .offset(y: viewModel.overlayShown ? -popupSize / 2 : -popupSize - 36)
                    .onTapGesture {
                        withAnimation {
                            shouldShow = false
                            composerPopupShown = false
                        }
                    }
                    .onAppear {
                        withAnimation {
                            shouldShow = true
                        }
                    }
                
                if shouldShow {
                    VStack {
                        ForEach(options) { option in
                            HStack(spacing: 16) {
                                Button {
                                    option.action()
                                    shouldShow = false
                                    composerPopupShown = false
                                } label: {
                                    HStack {
                                        Image(systemName: option.imageName)
                                        Text(option.title)
                                            .foregroundColor(.black)
                                    }
                                    .padding()
                                }
                                Spacer()
                            }

                        }
                    }
                    .offset(y: viewModel.overlayShown ? 0 : -120)
                    .transition(
                        AnyTransition.scale
                            .combined(with: AnyTransition.offset(x: -UIScreen.main.bounds.width / 2.0,
                                                                 y: 0))
                    )
                    .animation(.spring(response: 0.2, dampingFraction: 0.7, blendDuration: 0.2))
                }
            }
            : nil
        )
    }
    
}

struct ComposerOption: Identifiable {
    let id: String
    let title: String
    let imageName: String
    var action: () -> ()
}

@available(iOS 15.0, *)
struct BlurredBackground: View {
    var body: some View {
        Color.clear
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .background (.ultraThinMaterial, in:
                RoundedRectangle (cornerRadius: 16.0)
            )
    }
}

struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat? = nil

    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        value = value ?? nextValue()
    }
}
