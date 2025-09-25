//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import SwiftUI

/// Converts markdown string to AttributedString with styling attributes.
final class MarkdownFormatter {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    
    private let markdownParser = MarkdownParser()
        
    @available(iOS 15, *)
    func format(
        _ string: String,
        attributes: AttributeContainer,
        layoutDirection: LayoutDirection
    ) -> AttributedString {
        do {
            return try markdownParser.style(
                markdown: string,
                options: MarkdownParser.ParsingOptions(layoutDirectionLeftToRight: layoutDirection == .leftToRight),
                attributes: attributes,
                inlinePresentationIntentAttributes: inlinePresentationIntentAttributes(for:),
                presentationIntentAttributes: presentationIntentAttributes(for:in:)
            )
        } catch {
            log.debug("Failed to parse markdown with error \(error.localizedDescription)")
            return AttributedString(string, attributes: attributes)
        }
    }
    
    // MARK: - Styling Attributes
    
    @available(iOS 15, *)
    private func inlinePresentationIntentAttributes(
        for inlinePresentationIntent: InlinePresentationIntent
    ) -> AttributeContainer? {
        nil // use default attributes
    }
    
    @available(iOS 15, *)
    private func presentationIntentAttributes(
        for presentationKind: PresentationIntent.Kind,
        in presentationIntent: PresentationIntent
    ) -> AttributeContainer? {
        switch presentationKind {
        case .blockQuote:
            return AttributeContainer()
                .foregroundColor(Color(colors.subtitleText))
        case .codeBlock:
            return AttributeContainer()
                .font(fonts.body.monospaced())
        case let .header(level):
            let font: Font = switch level {
            case 1:
                fonts.title
            case 2:
                fonts.title2
            case 3:
                fonts.title3
            case 4:
                fonts.headline
            case 5:
                fonts.subheadline
            default:
                fonts.footnote
            }
            let foregroundColor: Color? = level >= 6 ? Color(colors.subtitleText) : nil
            if let foregroundColor {
                return AttributeContainer()
                    .font(font)
                    .foregroundColor(foregroundColor)
            } else {
                return AttributeContainer()
                    .font(font)
            }
        default:
            return nil
        }
    }
}
