//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI
import WebKit

/// Displays an animated GIF via WKWebView (SwiftUI's AsyncImage only shows the first frame).
/// Shared by the Giphy grid and the custom_giphy message bubble.
struct AnimatedGifView: UIViewRepresentable {
    let gifURL: URL

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.isUserInteractionEnabled = false
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.backgroundColor = .clear
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard gifURL != context.coordinator.lastLoadedURL else { return }
        context.coordinator.lastLoadedURL = gifURL

        guard gifURL.scheme == "https" || gifURL.scheme == "http" else { return }
        // Load our HTML; img src is escaped so we request the image directly (avoids Giphy consent page that load(URLRequest) would hit).
        let escaped = Self.escapeForHTMLAttribute(gifURL.absoluteString)
        let html = """
        <html><head><meta name="viewport" content="width=device-width,initial-scale=1"/></head>\
        <body style="margin:0;background:transparent;width:100%;height:100%;">\
        <img src="\(escaped)" style="width:100%;height:100%;object-fit:cover;display:block;" />\
        </body></html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }

    private static func escapeForHTMLAttribute(_ value: String) -> String {
        value
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }

    final class Coordinator {
        var lastLoadedURL: URL?
    }
}
