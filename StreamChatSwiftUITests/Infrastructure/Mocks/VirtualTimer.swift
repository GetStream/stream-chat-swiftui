//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChat
import XCTest

struct VirtualTimeTimer: StreamChat.Timer {
    static var time: VirtualTime!

    static func schedule(timeInterval: TimeInterval, queue: DispatchQueue, onFire: @escaping () -> Void) -> TimerControl {
        Self.time.scheduleTimer(
            interval: timeInterval,
            repeating: false,
            callback: { _ in onFire() }
        )
    }

    static func scheduleRepeating(
        timeInterval: TimeInterval,
        queue: DispatchQueue,
        onFire: @escaping () -> Void
    ) -> RepeatingTimerControl {
        Self.time.scheduleTimer(
            interval: timeInterval,
            repeating: true,
            callback: { _ in onFire() }
        )
    }

    static func currentTime() -> Date {
        Date(timeIntervalSinceReferenceDate: time.currentTime)
    }
}

extension VirtualTime.TimerControl: TimerControl, RepeatingTimerControl {}

/// This class allows simulating time-based events in tests.
class VirtualTime {
    typealias Seconds = TimeInterval

    /// Specifies the number of seconds the execution pauses for after the virtual time is advanced.
    ///
    /// This is needed to give the system time to execute async tasks properly. Typically, you don't need to change this value.
    var timeAdvanceExecutionDelay: TimeInterval = 1 / 1_000_000

    var scheduledTimers: [VirtualTime.TimerControl] = []
    var currentTime: Seconds

    enum State {
        case running
        case waiting
        case stopped
    }

    var state: State = .stopped

    init(initialTime: TimeInterval = 0) {
        currentTime = initialTime
    }

    /// Simulates running the virtual time.
    ///
    /// - Parameter numberOfSeconds: The number of virtual seconds the time should advance of. If `nil` it runs until
    /// all timers are in the inactive state.
    func run(numberOfSeconds: Seconds? = nil) {
        let targetTime: Seconds = numberOfSeconds.map { $0 + currentTime } ?? .greatestFiniteMagnitude
        state = .running

        var keepRunning = true

        while keepRunning {
            let sortedTimers = scheduledTimers
                .map { (nextFireTime: $0.nextFireTime(currentTime: currentTime), timer: $0) }
                .filter { $0.nextFireTime != nil && $0.timer.isActive }
                .sorted { $0.nextFireTime! < $1.nextFireTime! }

            let nextTime = sortedTimers.first?.nextFireTime
            if let nextTime = nextTime, nextTime > currentTime, nextTime <= targetTime {
                currentTime = nextTime
            } else {
                // If `numberOfSeconds` was specified, set the current time to the target time.
                if targetTime != .greatestFiniteMagnitude {
                    currentTime = targetTime
                }

                keepRunning = false
            }

            let timersToRun = sortedTimers
                .prefix { $0.nextFireTime! == currentTime }

            timersToRun
                .map(\.timer)
                .forEach { $0.callback($0) }

            _ = XCTWaiter.wait(for: [.init()], timeout: timeAdvanceExecutionDelay)
        }

        if numberOfSeconds == nil {
            state = .waiting
        } else {
            state = .stopped
        }
    }

    func scheduleTimer(interval: TimeInterval, repeating: Bool, callback: @escaping (TimerControl) -> Void) -> TimerControl {
        let timer = TimerControl(
            scheduledFireTime: currentTime + interval,
            repeatingPeriod: repeating ? interval : 0,
            callback: callback
        )
        scheduledTimers.append(timer)

        if state == .waiting {
            run()
        }

        return timer
    }
}

extension VirtualTime {
    /// Internal representation of a timer scheduled with `VirtualTime`. Not meant to be used directly.
    class TimerControl {
        private(set) var isActive = true

        var repeatingPeriod: TimeInterval
        var scheduledFireTime: TimeInterval
        var callback: (TimerControl) -> Void

        init(scheduledFireTime: TimeInterval, repeatingPeriod: TimeInterval, callback: @escaping (TimerControl) -> Void) {
            self.repeatingPeriod = repeatingPeriod
            self.scheduledFireTime = scheduledFireTime
            self.callback = callback
        }

        func resume() {
            isActive = true
        }

        func suspend() {
            isActive = false
        }

        func cancel() {
            isActive = false
        }

        func nextFireTime(currentTime: TimeInterval) -> TimeInterval? {
            // First fire
            if scheduledFireTime > currentTime {
                return scheduledFireTime
            }

            // Repeated fire
            if scheduledFireTime <= currentTime, repeatingPeriod > 0 {
                let elapsedTime = currentTime - scheduledFireTime
                return currentTime + (repeatingPeriod - elapsedTime.truncatingRemainder(dividingBy: repeatingPeriod))
            }

            return nil
        }
    }
}
