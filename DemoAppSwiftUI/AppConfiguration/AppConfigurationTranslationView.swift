//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct AppConfigurationTranslationView: View {
    @Environment(\.dismiss) var dismiss
    
    var selection: Binding<TranslationLanguage?> = Binding {
        AppConfiguration.default.translationLanguage
    } set: { newValue in
        AppConfiguration.default.translationLanguage = newValue
    }
    
    var body: some View {
        List {
            ForEach(TranslationLanguage.all, id: \.languageCode) { language in
                Button(action: {
                    selection.wrappedValue = language
                    dismiss()
                }) {
                    HStack {
                        Text(language.languageCode)
                        Spacer()
                        if selection.wrappedValue == language {
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
