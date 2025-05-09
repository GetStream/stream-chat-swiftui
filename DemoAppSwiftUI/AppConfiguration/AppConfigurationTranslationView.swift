//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct AppConfigurationTranslationView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        List {
            ForEach(TranslationLanguage.all, id: \.languageCode) { language in
                Button(action: {
                    AppConfiguration.default.translationLanguage = language
                    dismiss()
                }) {
                    HStack {
                        Text(language.languageCode)
                        Spacer()
                        if AppConfiguration.default.translationLanguage == language {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .foregroundStyle(.primary)
            }
            .navigationTitle("Translation Language")
        }
    }
}

extension TranslationLanguage {
    static let all = allCases.sorted(by: { $0.languageCode < $1.languageCode })
}

#Preview {
    NavigationView {
        AppConfigurationTranslationView()
    }
}
