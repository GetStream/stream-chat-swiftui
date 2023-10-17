//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct BottomReactionsView: View {
    
    var onTap: () -> ()
    
    var body: some View {
        HStack {
            Button(
                action: onTap,
                label: {
                    Image(systemName: "face.smiling.inverse")
                }
            )
        }
        
    }
}
