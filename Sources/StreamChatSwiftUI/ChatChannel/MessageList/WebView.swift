//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI
import WebKit

/// SwiftUI web view wrapper for `WKWebView`.
struct WebView: UIViewRepresentable {
    var url: URL
    @Binding var isLoading: Bool
    @Binding var title: String?
    @Binding var error: Error?

    func makeCoordinator() -> Coordinator {
        Coordinator(
            webView: self,
            isLoading: $isLoading,
            title: $title,
            error: $error
        )
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: CGRect.zero)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.isScrollEnabled = true
        webView.load(URLRequest(url: url))
        return webView.withAccessibilityIdentifier(identifier: "WKWebView")
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // We don't need handling updates of the view at the moment.
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        var isLoading: Binding<Bool>
        var title: Binding<String?>
        var error: Binding<Error?>

        init(
            webView: WebView,
            isLoading: Binding<Bool>,
            title: Binding<String?>,
            error: Binding<Error?>
        ) {
            parent = webView
            self.isLoading = isLoading
            self.title = title
            self.error = error
        }

        public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            isLoading.wrappedValue = true
        }

        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoading.wrappedValue = false

            webView.evaluateJavaScript("document.title") { data, _ in
                if let title = data as? String, !title.isEmpty {
                    self.title.wrappedValue = title
                }
            }
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            isLoading.wrappedValue = false
            self.error.wrappedValue = error
        }

        func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation!,
            withError error: Error
        ) {
            isLoading.wrappedValue = false
            self.error.wrappedValue = error
        }
    }
}
