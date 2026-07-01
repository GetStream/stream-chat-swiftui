//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import CryptoKit
import Foundation
import StreamChat

/// A thread-safe, size-bounded disk cache with least-recently-used (LRU) eviction.
/// All file I/O and in-memory index access are serialized on a private queue.
final class LRUDiskCache: @unchecked Sendable {
    private struct Entry {
        var size: Int
        var lastUsedAt: Date
    }

    let maxSizeInBytes: Int
    let directory: URL

    private var entries: [String: Entry]?
    private let queue = DispatchQueue(label: "io.getstream.StreamChatSwiftUI.LRUDiskCache", qos: .utility)

    init(directory: URL, maxSizeInBytes: Int) {
        self.directory = directory
        self.maxSizeInBytes = maxSizeInBytes
    }

    convenience init(name: String, maxSizeInBytes: Int) {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        self.init(
            directory: base.appendingPathComponent(name, isDirectory: true),
            maxSizeInBytes: maxSizeInBytes
        )
    }

    func cachedFileURL(forKey key: String, fileExtension: String?) async -> URL? {
        await withCheckedContinuation { continuation in
            cachedFileURL(forKey: key, fileExtension: fileExtension) { continuation.resume(returning: $0) }
        }
    }

    func cachedFileURL(forKey key: String, fileExtension: String?, completion: @escaping @Sendable (URL?) -> Void) {
        queue.async {
            self.loadCacheIfNeeded()
            let name = Self.storageName(forKey: key, fileExtension: fileExtension)
            let url = self.directory.appendingPathComponent(name)

            guard self.entries?[name] != nil else {
                completion(nil)
                return
            }
            guard FileManager.default.fileExists(atPath: url.path) else {
                self.entries?.removeValue(forKey: name)
                completion(nil)
                return
            }
            let now = Date()
            if var entry = self.entries?[name] {
                entry.lastUsedAt = now
                self.entries?[name] = entry
            }
            try? FileManager.default.setAttributes([.modificationDate: now], ofItemAtPath: url.path)
            completion(url)
        }
    }

    @discardableResult
    func store(fileAt tempURL: URL, forKey key: String, fileExtension: String?) async -> URL? {
        await withCheckedContinuation { continuation in
            store(fileAt: tempURL, forKey: key, fileExtension: fileExtension) { continuation.resume(returning: $0) }
        }
    }

    func store(fileAt tempURL: URL, forKey key: String, fileExtension: String?, completion: @escaping @Sendable (URL?) -> Void) {
        queue.async {
            let size = (try? tempURL.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
            guard size > 0 else {
                completion(nil)
                return
            }

            self.loadCacheIfNeeded()
            let name = Self.storageName(forKey: key, fileExtension: fileExtension)
            let destination = self.directory.appendingPathComponent(name)

            do {
                try FileManager.default.createDirectory(at: self.directory, withIntermediateDirectories: true)
                if FileManager.default.fileExists(atPath: destination.path) {
                    _ = try FileManager.default.replaceItemAt(destination, withItemAt: tempURL)
                } else {
                    try FileManager.default.moveItem(at: tempURL, to: destination)
                }
            } catch {
                log.error("Failed to store file in disk cache: \(error)")
                completion(nil)
                return
            }

            self.entries?[name] = Entry(size: size, lastUsedAt: Date())
            var cacheSize = self.entries?.values.reduce(0, { $0 + $1.size }) ?? 0
            var entryCount = self.entries?.count ?? 0
            let namesToEvict = (self.entries ?? [:])
                .sorted(by: { $0.value.lastUsedAt < $1.value.lastUsedAt })
                .prefix { entry in
                    guard cacheSize > self.maxSizeInBytes, entryCount > 1 else { return false }
                    cacheSize -= entry.value.size
                    entryCount -= 1
                    return true
                }
                .map { $0.key }
            namesToEvict.forEach { self.entries?.removeValue(forKey: $0) }

            for evicted in namesToEvict {
                try? FileManager.default.removeItem(at: self.directory.appendingPathComponent(evicted))
            }
            completion(destination)
        }
    }

    func remove(forKey key: String, fileExtension: String?) async {
        await withCheckedContinuation { continuation in
            remove(forKey: key, fileExtension: fileExtension) { continuation.resume() }
        }
    }

    func remove(forKey key: String, fileExtension: String?, completion: @escaping @Sendable () -> Void) {
        queue.async {
            let name = Self.storageName(forKey: key, fileExtension: fileExtension)
            self.entries?.removeValue(forKey: name)
            try? FileManager.default.removeItem(at: self.directory.appendingPathComponent(name))
            completion()
        }
    }

    func removeAll() async {
        await withCheckedContinuation { continuation in
            removeAll { continuation.resume() }
        }
    }

    func removeAll(completion: @escaping @Sendable () -> Void) {
        queue.async {
            self.entries = [:]
            try? FileManager.default.removeItem(at: self.directory)
            completion()
        }
    }

    private func loadCacheIfNeeded() {
        guard entries == nil else { return }
        let scanned = (try? FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ))?
            .compactMap { url -> (name: String, entry: Entry)? in
                let values = try? url.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey])
                guard let size = values?.fileSize else { return nil }
                return (url.lastPathComponent, Entry(size: size, lastUsedAt: values?.contentModificationDate ?? Date()))
            }
        entries = Dictionary(uniqueKeysWithValues: scanned ?? [])
    }

    private static func storageName(forKey key: String, fileExtension: String?) -> String {
        let hex = SHA256.hash(data: Data(key.utf8)).map { String(format: "%02x", $0) }.joined()
        if let fileExtension, !fileExtension.isEmpty {
            return "\(hex).\(fileExtension)"
        }
        return hex
    }
}
