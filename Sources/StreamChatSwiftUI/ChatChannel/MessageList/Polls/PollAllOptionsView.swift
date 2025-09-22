//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct PollAllOptionsView<Factory: ViewFactory>: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewModel: PollAttachmentViewModel
    
    let factory: Factory
    
    var body: some View {
        NavigationContainerView(embedInNavigationView: true) {
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
                                factory: factory,
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
            .toolbarThemed {
                ToolbarItem(placement: .principal) {
                    Text(L10n.Message.Polls.Toolbar.optionsTitle)
                        .bold()
                        .foregroundColor(Color(colors.navigationBarTitle))
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
