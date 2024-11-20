//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct PollAllOptionsView: View {
    
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewModel: PollAttachmentViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    HStack {
                        Text(viewModel.poll.name)
                            .bold()
                        Spacer()
                    }
                    .withPollsBackground()
                    
                    LazyVStack(spacing: 32) {
                        ForEach(viewModel.poll.options) { option in
                            PollOptionView(
                                viewModel: viewModel,
                                option: option,
                                optionFont: fonts.headline,
                                textColor: Color(colors.text),
                                alternativeStyle: true,
                                checkboxButtonSpacing: 8
                            )
                        }
                    }
                    .withPollsBackground()
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(L10n.Message.Polls.Toolbar.optionsTitle)
                        .bold()
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
