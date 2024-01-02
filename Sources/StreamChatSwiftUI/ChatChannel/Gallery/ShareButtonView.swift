//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// View for presenting a button which has a share action.
struct ShareButtonView: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    @Injected(\.images) var images

    var content: [Any]
    @State var isSharePresented = false

    var body: some View {
        Button(action: {
            self.isSharePresented = true
        }, label: {
            Image(uiImage: images.share)
                .customizable()
                .frame(width: 18, height: 22)
        })
            .foregroundColor(Color(colors.text))
            .sheet(isPresented: $isSharePresented) {
                ShareActivityView(activityItems: content)
            }
    }
}

/// View controller reprensetable which wraps up the activity view controller.
struct ShareActivityView: UIViewControllerRepresentable {

    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<ShareActivityView>
    ) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        controller.popoverPresentationController?.sourceView = UIApplication.shared.windows.first?.rootViewController?.view

        return controller
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: UIViewControllerRepresentableContext<ShareActivityView>
    ) { /* Not needed. */ }
}
