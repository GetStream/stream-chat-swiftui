//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Combine
import SwiftUI

struct AppConfigurationView: View {
    @State private var channelPinningEnabled = AppConfiguration.default.isChannelPinningFeatureEnabled

    var body: some View {
        NavigationView {
            List {
                Section("Connect User Configuration") {
                    NavigationLink("Translation") {
                        AppConfigurationTranslationView()
                    }
                    Toggle("Channel Pinning", isOn: $channelPinningEnabled)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("App Configuration")
        }
        .onChange(of: channelPinningEnabled, perform: { AppConfiguration.default.isChannelPinningFeatureEnabled = $0 })
    }
}

#Preview {
    AppConfigurationView()
}
