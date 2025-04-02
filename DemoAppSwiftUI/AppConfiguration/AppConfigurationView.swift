//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Combine
import SwiftUI

struct AppConfigurationView: View {
    var body: some View {
        NavigationView {
            List {
                Section("Connect User Configuration") {
                    NavigationLink("Translation") {
                        AppConfigurationTranslationView()
                    }
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
