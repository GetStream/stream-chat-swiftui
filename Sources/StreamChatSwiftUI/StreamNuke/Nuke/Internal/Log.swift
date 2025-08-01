// The MIT License (MIT)
//
// Copyright (c) 2015-2024 Alexander Grebenyuk (github.com/kean).

import Foundation
import os

func signpost(_ object: AnyObject, _ name: StaticString, _ type: OSSignpostType, _ message: @autoclosure () -> String) {
    guard ImagePipeline.Configuration.isSignpostLoggingEnabled else { return }

    let nukeLog = nukeLog.value
    let signpostId = OSSignpostID(log: nukeLog, object: object)
    os_signpost(type, log: nukeLog, name: name, signpostID: signpostId, "%{public}s", message())
}

func signpost<T>(_ name: StaticString, _ work: () throws -> T) rethrows -> T {
    guard ImagePipeline.Configuration.isSignpostLoggingEnabled else { return try work() }

    let nukeLog = nukeLog.value
    let signpostId = OSSignpostID(log: nukeLog)
    os_signpost(.begin, log: nukeLog, name: name, signpostID: signpostId)
    let result = try work()
    os_signpost(.end, log: nukeLog, name: name, signpostID: signpostId)
    return result
}

private let nukeLog = Atomic(value: OSLog(subsystem: "com.github.kean.Nuke.ImagePipeline", category: "Image Loading"))

enum Formatter {
    static func bytes(_ count: Int) -> String {
        bytes(Int64(count))
    }

    static func bytes(_ count: Int64) -> String {
        ByteCountFormatter().string(fromByteCount: count)
    }
}
