//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SwiftUI

public struct NewChatView: View {
    @StateObject var viewModel: NewChatViewModel
    
    public init() {
        _viewModel = StateObject(
            wrappedValue: ViewModelsFactory.makeNewChatViewModel()
        )
    }
    
    public var body: some View {
        Text("New chat view")
    }
}
