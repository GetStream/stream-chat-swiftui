//
// Copyright © 2024 Stream.io Inc. All rights reserved.
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

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                factory.makeChannelListTopView(
                    searchText: .constant("")
                )

                LazyVStack(spacing: 0) {
                    ForEach(0..<20) { _ in
                        RedactedChannelCell()
                            .shimmering()
                        Divider()
                    }
                }
            }
        }
        .accessibilityIdentifier("RedactedLoadingView")
    }
}

struct RedactedChannelCell: View {

    @Injected(\.colors) private var colors

    private let circleSize: CGFloat = 48

    private var redactedColor: Color {
        Color(colors.disabledColorForColor(colors.text))
    }

    public var body: some View {
        HStack(alignment: .center) {
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
