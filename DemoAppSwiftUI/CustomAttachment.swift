//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

class CustomMessageResolver: MessageTypeResolving {

    func hasCustomAttachment(message: ChatMessage) -> Bool {
        let messageComponents = message.text.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        return !messageComponents.filter { component in
            isValidEmail(component)
        }
        .isEmpty
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

struct CustomAttachmentView: View {

    let message: ChatMessage
    let width: CGFloat
    let isFirst: Bool

    var body: some View {
        HStack {
            Image(systemName: "envelope")
            Text(message.text)
        }
        .padding()
        .frame(maxWidth: width)
        .messageBubble(for: message, isFirst: isFirst)
    }
}

struct CustomMessageTextView: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts

    var message: ChatMessage
    var isFirst: Bool

    public var body: some View {
        Text(message.text)
            .padding()
            .messageBubble(for: message, isFirst: isFirst)
            .foregroundColor(Color.blue)
            .font(fonts.bodyBold)
            .overlay(
                BottomRightView {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .offset(x: 1, y: -1)
                }
            )
    }
}
