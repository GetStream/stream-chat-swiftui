//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Combine
import StreamChatSwiftUI
import SwiftUI

struct AppConfigurationView: View {
    @State private var channelPinningEnabled = AppConfiguration.default.isChannelPinningFeatureEnabled
    @State private var reactionsStyle = AppConfiguration.default.reactionsStyle
    @State private var reactionsPlacement = AppConfiguration.default.reactionsPlacement
    @State private var appStyle = AppConfiguration.default.appStyle
    @State private var voiceRecordingAutoSend = AppConfiguration.default.isVoiceRecordingAutoSendEnabled
    @State private var messagesStartAtTheTop = AppConfiguration.default.shouldMessagesStartAtTheTop
    @State private var attachmentDownloadsDirectory = AppConfiguration.default.attachmentDownloadsDirectory

    var body: some View {
        NavigationView {
            List {
                Section("Connect User Configuration") {
                    NavigationLink("Translation") {
                        AppConfigurationTranslationView()
                    }
                    Toggle("Channel Pinning", isOn: $channelPinningEnabled)
                }
                Section("Reactions") {
                    Picker("Style", selection: $reactionsStyle) {
                        Text("Segmented").tag(ReactionsStyle.segmented)
                        Text("Clustered").tag(ReactionsStyle.clustered)
                    }
                    Picker("Placement", selection: $reactionsPlacement) {
                        Text("Top").tag(ReactionsPlacement.top)
                        Text("Bottom").tag(ReactionsPlacement.bottom)
                    }
                }
                Section("App Style") {
                    Picker("Style", selection: $appStyle) {
                        Text("Regular").tag(AppConfiguration.AppStyle.regular)
                        Text("Liquid Glass").tag(AppConfiguration.AppStyle.liquidGlass)
                    }
                }
                Section("Voice Recording") {
                    Toggle("Auto-send on release", isOn: $voiceRecordingAutoSend)
                }
                Section("Message List") {
                    Toggle("Messages Start at the Top", isOn: $messagesStartAtTheTop)
                Section {
                    Picker("Directory", selection: $attachmentDownloadsDirectory) {
                        ForEach(AppConfiguration.AttachmentDownloadsDirectory.allCases) { directory in
                            Text(directory.title).tag(directory)
                        }
                    }
                    Text(attachmentDownloadsDirectory.subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Attachment Downloads")
                } footer: {
                    Text("Takes effect on the next app launch. Downloaded files are stored in a StreamAttachmentDownloads subfolder.")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("App Configuration")
        }
        .onChange(of: channelPinningEnabled, perform: { AppConfiguration.default.isChannelPinningFeatureEnabled = $0 })
        .onChange(of: reactionsStyle) { newStyle in
            AppConfiguration.default.reactionsStyle = newStyle
            InjectedValues[\.utils].messageListConfig = AppConfiguration.makeMessageListConfig()
        }
        .onChange(of: reactionsPlacement) { newPlacement in
            AppConfiguration.default.reactionsPlacement = newPlacement
            InjectedValues[\.utils].messageListConfig = AppConfiguration.makeMessageListConfig()
        }
        .onChange(of: appStyle) { newStyle in
            AppConfiguration.default.appStyle = newStyle
        }
        .onChange(of: voiceRecordingAutoSend) { newValue in
            AppConfiguration.default.isVoiceRecordingAutoSendEnabled = newValue
            InjectedValues[\.utils].composerConfig = AppConfiguration.makeComposerConfig()
        }
        .onChange(of: messagesStartAtTheTop) { newValue in
            AppConfiguration.default.shouldMessagesStartAtTheTop = newValue
            InjectedValues[\.utils].messageListConfig = AppConfiguration.makeMessageListConfig()
        .onChange(of: attachmentDownloadsDirectory) { newValue in
            AppConfiguration.default.attachmentDownloadsDirectory = newValue
        }
    }
}

#Preview {
    AppConfigurationView()
}
