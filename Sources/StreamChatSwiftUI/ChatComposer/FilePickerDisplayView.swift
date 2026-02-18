//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View shown after the native file picker is closed.
struct FilePickerDisplayView: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors

    @Binding var filePickerShown: Bool
    var onFilesPicked: ([URL]) -> Void

    var body: some View {
        ZStack {
            Button {
                filePickerShown = true
            } label: {
                Text(L10n.Composer.Files.addMore)
                    .font(fonts.bodyBold)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundColor(Color(colors.highlightedAccentBackground))
        .sheet(isPresented: $filePickerShown) {
            AttachmentFilePickerView(onFilesPicked: onFilesPicked)
        }
    }
}
