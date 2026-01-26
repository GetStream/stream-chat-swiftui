//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

@available(iOS, introduced: 14.0, deprecated: 15.0)
@MainActor extension Compatibility where Content: View {
    @ViewBuilder
    func task<T: Equatable>(
        id: T,
        priority: _Concurrency.TaskPriority = .userInitiated,
        action: @escaping @Sendable () async -> Void
    ) -> some View {
        if #available(iOS 15.0, *) {
            content.task(id: id, priority: priority, action)
        } else {
            content.modifier(
                TaskCompatibilityViewModifier(
                    id: id,
                    priority: priority,
                    action: action
                )
            )
        }
    }
}

@available(iOS, introduced: 14.0, deprecated: 15.0)
private struct TaskCompatibilityViewModifier<ID: Equatable>: ViewModifier {
    let id: ID
    let priority: _Concurrency.TaskPriority
    let action: @Sendable () async -> Void
    
    @State private var task: Task<Void, Never>?
    @State private var taskId: ID?
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                guard id != taskId else { return }
                startTask(id: id)
            }
            .onDisappear {
                cancelTask()
            }
            .onChange(of: id) { newValue in
                cancelTask()
                startTask(id: newValue)
            }
    }
    
    private func startTask(id: ID) {
        taskId = id
        task = Task(priority: priority) {
            do {
                try Task.checkCancellation()
                await action()
            } catch {
                taskId = nil
            }
        }
    }
    
    private func cancelTask() {
        task?.cancel()
        task = nil
    }
}
