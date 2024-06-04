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
        validation: @escaping (String) -> Bool = UIAlertControllerView.defaultActionValidation,
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
                validation: validation,
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
    let validation: (String) -> Bool
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
                let didEdit = UIAction { [weak alert, weak textField] _ in
                    guard let defaultAction = alert?.actions.first(where: { $0.style == .default }) else { return }
                    defaultAction.isEnabled = validation(textField?.text ?? "")
                }
                textField.font = .preferredFont(forTextStyle: .body)
                textField.placeholder = placeholder
                textField.text = text
                textField.addAction(didEdit, for: .allEditingEvents)
            }
            alert.addAction(
                UIAlertAction(title: cancel, style: .cancel) { _ in
                    isPresented = false
                }
            )
            let textField = alert.textFields?.first
            alert.addAction(
                UIAlertAction(title: accept, style: .default) { _ in
                    text = textField?.text?.trimmed ?? ""
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
    
    static func defaultActionValidation(_ text: String) -> Bool {
        !text.trimmed.isEmpty
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}

private extension UIAlertControllerView {
    final class Coordinator {
        var alertController: UIAlertController?
        
        init(alertController: UIAlertController? = nil) {
            self.alertController = alertController
        }
    }
}
