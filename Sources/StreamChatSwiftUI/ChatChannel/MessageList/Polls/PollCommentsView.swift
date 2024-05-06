//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct PollCommentsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var viewModel: PollCommentsViewModel
    
    init(pollController: PollController) {
        _viewModel = StateObject(
            wrappedValue: PollCommentsViewModel(pollController: pollController)
        )
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(viewModel.comments) { comment in
                        Text(comment.answerText ?? "")
                            .padding(.horizontal)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Poll comments")
                        .bold()
                }
                
                ToolbarItem(placement: .topBarLeading) {
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
