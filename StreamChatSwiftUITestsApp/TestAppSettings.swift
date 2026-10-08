//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

@MainActor
final class TestAppSettings: ObservableObject {
    static let shared = TestAppSettings()

    // Connectivity
    @Published var showsConnectivity = false
    @Published var setConnectivity = false
    @Published var isConnected = true

    // Config (defaults match `ChatClientConfig` defaults)
    @Published var isLocalStorageEnabled = true
    @Published var staysConnectedInBackground = true

    private init() {}

    func binding(for keyPath: ReferenceWritableKeyPath<TestAppSettings, Bool>) -> Binding<Bool> {
        Binding(
            get: { self[keyPath: keyPath] },
            set: { self[keyPath: keyPath] = $0 }
        )
    }
}

/// The switches the UI tests use to configure the app before logging in.
struct SettingsView: View {
    @ObservedObject var settings = TestAppSettings.shared

    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            SettingSwitch(name: "isLocalStorageEnabled", isOn: settings.binding(for: \.isLocalStorageEnabled))
            SettingSwitch(name: "staysConnectedInBackground", isOn: settings.binding(for: \.staysConnectedInBackground))
            SettingSwitch(name: "showsConnectivity", isOn: settings.binding(for: \.showsConnectivity))
            SettingSwitch(name: "setConnectivity", isOn: settings.binding(for: \.setConnectivity))
            SettingSwitch(name: "isConnected", isOn: settings.binding(for: \.isConnected))
        }
    }
}

private struct SettingSwitch: View {
    let name: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Text(name)
            Toggle(name, isOn: $isOn)
                .labelsHidden()
                .accessibilityIdentifier(name)
        }
    }
}

/// The switch that mocks the device connectivity, shown in the navigation bar when `showsConnectivity` is on.
struct ConnectivitySwitch: View {
    @ObservedObject var settings = TestAppSettings.shared

    var body: some View {
        if settings.showsConnectivity {
            Toggle(
                "isConnected",
                isOn: Binding(
                    get: { settings.isConnected },
                    set: { isConnected in
                        settings.isConnected = isConnected
                        StreamChatWrapper.shared.mockConnection(isConnected: isConnected)
                    }
                )
            )
            .labelsHidden()
            .accessibilityIdentifier("isConnected")
        }
    }
}

/// Exposes the connection status so UI tests can assert it.
@MainActor
final class ConnectionStatusObserver: ObservableObject, ChatConnectionControllerDelegate {
    @Published var status: ConnectionStatus
    private let controller: ChatConnectionController

    init(client: ChatClient) {
        controller = client.connectionController()
        status = controller.connectionStatus
        controller.delegate = self
    }

    func connectionController(_ controller: ChatConnectionController, didUpdateConnectionStatus status: ConnectionStatus) {
        self.status = status
    }
}

extension ConnectionStatus {
    var testIdentifier: String {
        switch self {
        case .initialized:
            return "initialized"
        case .connecting:
            return "connecting"
        case .connected:
            return "connected"
        case .disconnecting:
            return "disconnecting"
        case .disconnected:
            return "disconnected"
        }
    }
}

struct ConnectivityChannelHeaderModifier: ChatChannelHeaderViewModifier {
    let factory: DemoAppFactory
    let channel: ChatChannel
    let shouldShowTypingIndicator: Bool

    func body(content: Content) -> some View {
        content
            .modifier(
                DefaultChannelHeaderModifier(
                    factory: factory,
                    channel: channel,
                    shouldShowTypingIndicator: shouldShowTypingIndicator
                )
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ConnectivitySwitch()
                }
            }
    }
}
