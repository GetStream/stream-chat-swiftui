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

    var forceRTL: Binding<Bool> = Binding {
        AppConfiguration.default.forceRTL
    } set: { newValue in
        AppConfiguration.default.forceRTL = newValue
    }

    var giphyGridEnabled: Binding<Bool> = Binding {
        AppConfiguration.default.isGiphyGridEnabled
    } set: { newValue in
        AppConfiguration.default.isGiphyGridEnabled = newValue
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
                Section("Layout") {
                    Toggle("Force RTL (preview)", isOn: forceRTL)
                }
                Section("Composer") {
                    Toggle("GIF grid (Giphy picker)", isOn: giphyGridEnabled)
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
