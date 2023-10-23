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
    @State private var buttonScale: CGFloat = 1
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
                            buttonScale = 1
                            listScale = 1
                            state = .expanded
                        case .expanded:
                            buttonScale = 1
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
                .scaleEffect(CGSize(width: buttonScale, height: buttonScale))

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
                editedMessageWillShow = true
                viewModel.selectedRangeLocation = editedMessage?.text.count ?? 0
            }
        }
        .accessibilityElement(children: .contain)
        .overlay(
            AnimatingElement(viewModel: viewModel, state: $state, buttonScale: $buttonScale, listScale: $listScale)
                .offset(y: viewModel.overlayShown ? -popupSize / 2 : -popupSize + 83)
                .allowsHitTesting(state == .expanded)
        )
    }
    
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

enum AnimationState {
    case initial, expanded
}

struct ListElement: Equatable, Identifiable {
    static func == (lhs: ListElement, rhs: ListElement) -> Bool {
        lhs.id == rhs.id
    }
    
    var imageName: String
    var text: String
    var color: Color
    var action: () -> ()
    var id: String {
        "\(imageName)-\(text)"
    }
}

@available(iOS 15.0, *)
struct AnimatingElement: View {
    
    @ObservedObject var viewModel: MessageComposerViewModel
    
    @State var contentElements: [ListElement] = []
    
    @Binding var state: AnimationState
    @Binding var buttonScale: CGFloat
    @Binding var listScale: CGFloat
    
    let imageSize: CGFloat = 34
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color.white.opacity(state == .initial ? 0.2 : 0.5)
            
            BlurredBackground()
                .opacity(state == .initial ? 0.0 : 1)
            
            VStack(alignment: .leading, spacing: 30) {
                ForEach(contentElements) { contentElement in
                    Button {
                        withAnimation {
                            state = .initial
                            contentElement.action()
                        }
                    } label: {
                        HStack(spacing: 20) {
                            Image(systemName: contentElement.imageName)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(contentElement.color)
                                .frame(width: imageSize, height: imageSize)
                            
                            Text(contentElement.text)
                                .foregroundColor(.primary)
                                .font(.title2)
                        }
                    }
                }
            }
            .padding(.leading, 40)
            .padding(.bottom, 80)
            .scaleEffect(
                CGSize(
                    width: state == .initial ? 0 : 1,
                    height: state == .initial ? 0 : 1
                )
            )
            .offset(
                x: state == .initial ? -75 : 0,
                y: state == .initial ? -10 : -100
            )
        }
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

            self.contentElements = [
                ListElement(imageName: "photo.on.rectangle", text: "Photos", color: .purple, action: imageAction),
                ListElement(imageName: "camera.circle.fill", text: "Camera", color: .gray, action: cameraAction),
                ListElement(imageName: "folder.circle", text: "Files", color: .indigo, action: filesAction),
                ListElement(imageName: "command.circle.fill", text: "Commands", color: .orange, action: commandsAction)
            ]
        }
        .edgesIgnoringSafeArea(.all)
        .onTapGesture {
            withAnimation(.bouncy) {
                switch state {
                case .initial:
                    buttonScale = 10
                    listScale = 1
                    state = .expanded
                case .expanded:
                    buttonScale = 1
                    listScale = 0
                    state = .initial
                }
            }
        }
    }
}
