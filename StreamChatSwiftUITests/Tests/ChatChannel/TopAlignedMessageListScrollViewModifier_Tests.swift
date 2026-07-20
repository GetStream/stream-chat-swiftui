//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

@MainActor final class TopAlignedMessageListScrollViewModifier_Tests: StreamChatTestCase {
    func test_messageListConfig_startsMessagesAtTopByDefault() {
        XCTAssertTrue(MessageListConfig().shouldMessagesStartAtTheTop)
    }

    func test_shortList_isAlignedAtTop() async throws {
        let model = TopAlignedListModel(itemCount: 2)
        let recorder = TopAlignedListFrameRecorder()

        showView(TopAlignedListHarness(model: model, recorder: recorder, isEnabled: true))
        try await settle()

        let frames = try XCTUnwrap(recorder.latestFrames)
        XCTAssertEqual(try XCTUnwrap(frames.values.map(\.minY).min()), 0, accuracy: 10)
        XCTAssertLessThan(try XCTUnwrap(frames.values.map(\.maxY).max()), 100)
    }

    func test_shortList_remainsAlignedAtBottomWhenDisabled() async throws {
        let model = TopAlignedListModel(itemCount: 2)
        let recorder = TopAlignedListFrameRecorder()

        showView(TopAlignedListHarness(model: model, recorder: recorder, isEnabled: false))
        try await settle()

        let frames = try XCTUnwrap(recorder.latestFrames)
        XCTAssertGreaterThan(try XCTUnwrap(frames.values.map(\.minY).min()), 100)
        XCTAssertEqual(try XCTUnwrap(frames.values.map(\.maxY).max()), 190, accuracy: 10)
    }

    func test_insertingIntoShortList_doesNotMoveExistingMessages() async throws {
        let model = TopAlignedListModel(itemCount: 2)
        let recorder = TopAlignedListFrameRecorder()
        let referenceId = try XCTUnwrap(model.items.last)

        showView(TopAlignedListHarness(model: model, recorder: recorder, isEnabled: true))
        try await settle()
        recorder.track(referenceId)

        withAnimation(.linear(duration: 0.3)) {
            model.items.insert(-1, at: 0)
        }
        try await settle(for: 0.5)

        let displacements = try XCTUnwrap(recorder.displacements)
        XCTAssertEqual(try XCTUnwrap(displacements.last), 0, accuracy: 1)
        XCTAssertLessThanOrEqual(displacements.map(abs).max() ?? 0, 1)
    }

    func test_insertingIntoShortList_withScrollToLatestRequest_doesNotMoveExistingMessages() async throws {
        let model = TopAlignedListModel(itemCount: 2)
        let recorder = TopAlignedListFrameRecorder()
        let referenceId = try XCTUnwrap(model.items.last)

        showView(TopAlignedListHarness(model: model, recorder: recorder, isEnabled: true))
        try await settle()
        recorder.track(referenceId)

        withAnimation(.linear(duration: 0.3)) {
            model.items.insert(-1, at: 0)
            model.scrollToLatestRequest += 1
        }
        try await settle(for: 0.5)

        let displacements = try XCTUnwrap(recorder.displacements)
        XCTAssertEqual(try XCTUnwrap(displacements.last), 0, accuracy: 1)
        XCTAssertLessThanOrEqual(displacements.map(abs).max() ?? 0, 1)
    }

    func test_insertionCrossingVisibleHeight_movesContinuouslyByOverflowOnly() async throws {
        let model = TopAlignedListModel(itemCount: 4)
        let recorder = TopAlignedListFrameRecorder()
        let referenceId = try XCTUnwrap(model.items.last)

        showView(TopAlignedListHarness(model: model, recorder: recorder, isEnabled: true))
        try await settle()
        recorder.track(referenceId)

        withAnimation(.linear(duration: 0.3)) {
            model.items.insert(-1, at: 0)
        }
        try await settle(for: 0.5)

        let displacements = try XCTUnwrap(recorder.displacements)
        XCTAssertEqual(try XCTUnwrap(displacements.first), 0, accuracy: 0.5)
        let finalDisplacement = try XCTUnwrap(displacements.last)
        XCTAssertLessThan(finalDisplacement, -1)
        XCTAssertGreaterThan(finalDisplacement, -39)
        XCTAssertTrue(displacements.contains { $0 < -1 && $0 > finalDisplacement + 1 })
        for (current, next) in zip(displacements, displacements.dropFirst()) {
            XCTAssertLessThanOrEqual(next, current + 0.5)
        }
    }

    func test_insertingIntoScrollableList_keepsRegularInsertionAnimation() async throws {
        let model = TopAlignedListModel(itemCount: 6)
        let recorder = TopAlignedListFrameRecorder()
        let referenceId = try XCTUnwrap(model.items.first)

        showView(TopAlignedListHarness(model: model, recorder: recorder, isEnabled: true))
        try await settle()
        recorder.track(referenceId)

        withAnimation(.linear(duration: 0.3)) {
            model.items.insert(-1, at: 0)
        }
        try await settle(for: 0.5)

        let displacements = try XCTUnwrap(recorder.displacements)
        XCTAssertEqual(try XCTUnwrap(displacements.last), -40, accuracy: 1)
        XCTAssertTrue(displacements.contains { $0 < -1 && $0 > -39 })
    }

    func test_scrollableList_initiallyShowsLatestMessageAtBottom() async throws {
        let model = TopAlignedListModel(itemCount: 100)
        let recorder = TopAlignedListFrameRecorder()

        showView(TopAlignedListHarness(model: model, recorder: recorder, isEnabled: true))
        try await settle(for: 0.5)

        let latestFrame = try XCTUnwrap(recorder.latestFrames?[0])
        XCTAssertGreaterThan(latestFrame.minY, 140)
        XCTAssertEqual(latestFrame.maxY, 190, accuracy: 10)
    }

    func test_scrollableList_keepsLatestMessageAtBottomWhenRowsFinishLayingOut() async throws {
        let model = TopAlignedListModel(itemCount: 100, rowHeight: 20)
        let recorder = TopAlignedListFrameRecorder()

        showView(TopAlignedListHarness(model: model, recorder: recorder, isEnabled: true))
        try await settle()
        model.rowHeight = 40
        try await settle(for: 0.5)

        let latestFrame = try XCTUnwrap(recorder.latestFrames?[0])
        XCTAssertGreaterThan(latestFrame.minY, 140)
        XCTAssertEqual(latestFrame.maxY, 190, accuracy: 10)
    }

    private func settle(for seconds: TimeInterval = 0.2) async throws {
        try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}

@MainActor private final class TopAlignedListModel: ObservableObject {
    @Published var items: [Int]
    @Published var scrollToLatestRequest = 0
    @Published var rowHeight: CGFloat

    init(itemCount: Int, rowHeight: CGFloat = 40) {
        items = Array(0..<itemCount)
        self.rowHeight = rowHeight
    }
}

@MainActor private final class TopAlignedListFrameRecorder {
    private(set) var latestFrames: [Int: CGRect]?
    private(set) var displacements: [CGFloat]?
    private var referenceId: Int?
    private var initialPosition: CGFloat?

    func track(_ id: Int) {
        referenceId = id
        initialPosition = latestFrames?[id]?.minY
        displacements = [0]
    }

    func record(_ frames: [Int: CGRect]) {
        latestFrames = frames
        guard let referenceId, let initialPosition, let position = frames[referenceId]?.minY else { return }
        let displacement = position - initialPosition
        if abs(displacement - (displacements?.last ?? .infinity)) > 0.01 {
            displacements?.append(displacement)
        }
    }
}

private struct TopAlignedListHarness: View {
    @ObservedObject var model: TopAlignedListModel
    let recorder: TopAlignedListFrameRecorder
    let isEnabled: Bool

    var body: some View {
        ScrollViewReader { scrollView in
            ScrollView {
                Color.clear.frame(height: 10)

                LazyVStack(spacing: 0) {
                    ForEach(model.items, id: \.self) { id in
                        Color.clear
                            .frame(height: model.rowHeight)
                            .background(
                                GeometryReader { proxy in
                                    Color.clear.preference(
                                        key: TopAlignedListFramesPreferenceKey.self,
                                        value: [id: proxy.frame(in: .named("TopAlignedList"))]
                                    )
                                }
                            )
                            .flippedUpsideDown()
                    }
                }
                .modifier(
                    LegacyTopAlignedMessageListScrollViewModifier(
                        isEnabled: isEnabled
                    )
                )
                .overlay(alignment: .top) {
                    Color.clear
                        .frame(height: 0)
                        .id("TopAlignedListBottom")
                }
            }
            .modifier(TopAlignedMessageListScrollViewModifier(isEnabled: isEnabled))
            .onChange(of: model.scrollToLatestRequest) { _ in
                withAnimation(.linear(duration: 0.3)) {
                    scrollView.scrollTo("TopAlignedListBottom", anchor: .bottom)
                }
            }
        }
        .flippedUpsideDown()
        .frame(width: 200, height: 200)
        .coordinateSpace(name: "TopAlignedList")
        .onPreferenceChange(TopAlignedListFramesPreferenceKey.self) { frames in
            recorder.record(frames)
        }
    }
}

private struct TopAlignedListFramesPreferenceKey: PreferenceKey {
    static let defaultValue = [Int: CGRect]()

    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { _, next in next })
    }
}
