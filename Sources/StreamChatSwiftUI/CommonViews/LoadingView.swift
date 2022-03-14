//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Simple loading view with a progress indicator.
public struct LoadingView: View {
    public var body: some View {
        VStack {
            Spacer()
            ProgressView()
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

/// Loading view showing redacted channel list data.
public struct RedactedLoadingView<Factory: ViewFactory>: View {
    
    public var factory: Factory
    
    @State private var opacity: Double = 0.5
    
    private let duration: Double = 0.75
    private let maxOpacity: Double = 1.0
    
    public var body: some View {
        ScrollView {
            VStack {
                factory.makeChannelListTopView(
                    searchText: .constant("")
                )
                
                VStack(spacing: 0) {
                    ForEach(0..<20) { _ in
                        RedactedChannelCell()
                        Divider()
                    }
                }
                .opacity(opacity)
                .transition(.opacity)
                .onAppear {
                    let baseAnimation = Animation.easeInOut(duration: duration)
                    let repeated = baseAnimation.repeatForever(autoreverses: true)
                    withAnimation(repeated) {
                        self.opacity = maxOpacity
                    }
                }
            }
        }
    }
}

struct RedactedChannelCell: View {
    
    @Injected(\.colors) private var colors
    
    private let circleSize: CGFloat = 48
    
    private var redactedColor: Color {
        Color(colors.disabledColorForColor(colors.text))
    }
    
    public var body: some View {
        HStack {
            Circle()
                .fill(redactedColor)
                .frame(width: circleSize, height: circleSize)
            
            VStack(alignment: .leading) {
                RedactedRectangle(width: 70, redactedColor: redactedColor)
                
                HStack {
                    RedactedRectangle(redactedColor: redactedColor)
                    RedactedRectangle(width: 50, redactedColor: redactedColor)
                }
            }
        }
        .padding(.all, 8)
    }
}

struct RedactedRectangle: View {
    
    var width: CGFloat?
    var redactedColor: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(redactedColor)
            .frame(width: width, height: 16)
    }
}
