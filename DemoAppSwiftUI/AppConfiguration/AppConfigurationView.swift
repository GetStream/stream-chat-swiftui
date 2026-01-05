//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Combine
import SwiftUI

struct AppConfigurationView: View {
    var channelPinningEnabled: Binding<Bool> = Binding {
        AppConfiguration.default.isChannelPinningFeatureEnabled
    } set: { newValue in
        AppConfiguration.default.isChannelPinningFeatureEnabled = newValue
    }

    var body: some View {
        NavigationView {
            List {
                Section("Connect User Configuration") {
                    NavigationLink("Translation") {
                        AppConfigurationTranslationView()
                    }
                    Toggle("Channel Pinning", isOn: channelPinningEnabled)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("App Configuration")
        }
    }
}

#Preview {
    AppConfigurationView()
}
