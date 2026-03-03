//
// Copyright © 2026 Stream.io Inc. All rights reserved.
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

/// A circular spinner badge used as a loading indicator over media content.
///
/// Renders a white circular badge with a border and an animated spinner inside.
public struct LoadingSpinnerView: View {
    @Injected(\.colors) private var colors

    let size: CGFloat

    public init(size: CGFloat = 32) {
        self.size = size
    }

    public var body: some View {
        ZStack {
            Circle()
                .fill(Color(colors.background))
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(size / 40)
        }
        .frame(width: size, height: size)
        .accessibilityIdentifier("LoadingSpinnerView")
    }
}

/// Loading view showing redacted channel list data.
public struct RedactedLoadingView<Factory: ViewFactory>: View {
    public var factory: Factory

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                factory.makeChannelListTopView(
                    options: ChannelListTopViewOptions(
                        searchText: .constant("")
                    )
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
