//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI

extension View {
    /// Presents an alert with a text field for entering text.
    ///
    /// - Note: iOS 14 lacks alert with text field support.
    func uiAlert(
        title: String,
        isPresented: Binding<Bool>,
        message: String = "",
        text: Binding<String>,
        placeholder: String = "",
        cancel: String = L10n.Alert.Actions.cancel,
        accept: String,
        action: @escaping () -> Void
    ) -> some View {
        ZStack {
            UIAlertControllerView(
                isPresented: isPresented,
                title: title,
                message: message,
                text: text,
                placeholder: placeholder,
                cancel: cancel,
                accept: accept,
                action: action
            )
            .frame(height: 0)
            self
        }
    }
}

private struct UIAlertControllerView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let title: String
    let message: String
    @Binding var text: String
    let placeholder: String
    let cancel: String
    let accept: String
    let action: () -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented && uiViewController.presentedViewController == nil {
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            context.coordinator.alertController = alert
            alert.addTextField { textField in
                textField.font = .preferredFont(forTextStyle: .body)
                textField.placeholder = placeholder
                textField.text = text
            }
            alert.addAction(
                UIAlertAction(title: cancel, style: .cancel) { _ in
                    isPresented = false
                }
            )
            let textField = alert.textFields?.first
            alert.addAction(
                UIAlertAction(title: accept, style: .default) { _ in
                    text = textField?.text ?? ""
                    isPresented = false
                    action()
                }
            )
            DispatchQueue.main.async {
                uiViewController.present(alert, animated: true)
            }
        }
        if !isPresented {
            context.coordinator.alertController?.dismiss(animated: true)
        }
    }
    
    static func dismantleUIViewController(_ uiViewController: UIViewController, coordinator: Coordinator) {
        coordinator.alertController?.dismiss(animated: true)
        coordinator.alertController = nil
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}

private extension UIAlertControllerView {
    final class Coordinator: NSObject, UITextFieldDelegate {
        var alertController: UIAlertController?
        
        init(alertController: UIAlertController? = nil) {
            self.alertController = alertController
        }
    }
}
