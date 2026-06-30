//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import CryptoKit
import Foundation
import StreamChat

/// A thread-safe, size-bounded disk cache with least-recently-used (LRU) eviction. All blocking
/// file I/O runs outside the lock, which guards only the in-memory index.
final class LRUDiskCache: Sendable {
    private struct Entry {
        var size: Int
        var lastUsedAt: Date
    }

    let maxSizeInBytes: Int
    let directory: URL

    private let entries = AllocatedUnfairLock<[String: Entry]?>(nil)

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

    func cachedFileURL(forKey key: String, fileExtension: String?) -> URL? {
        loadCacheIfNeeded()
        let name = Self.storageName(forKey: key, fileExtension: fileExtension)
        let url = directory.appendingPathComponent(name)

        let isIndexed = entries.withLock { $0?[name] != nil }
        guard isIndexed else { return nil }

        guard FileManager.default.fileExists(atPath: url.path) else {
            entries.withLock { $0?.removeValue(forKey: name) }
            return nil
        }

        entries.withLock { entries in
            guard var entry = entries?[name] else { return }
            entry.lastUsedAt = Date()
            entries?[name] = entry
        }
        return url
    }

    @discardableResult
    func store(fileAt tempURL: URL, forKey key: String, fileExtension: String?) -> URL? {
        let size = (try? tempURL.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
        guard size > 0 else { return nil }

        loadCacheIfNeeded()
        let name = Self.storageName(forKey: key, fileExtension: fileExtension)
        let destination = directory.appendingPathComponent(name)

        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            if FileManager.default.fileExists(atPath: destination.path) {
                _ = try FileManager.default.replaceItemAt(destination, withItemAt: tempURL)
            } else {
                try FileManager.default.moveItem(at: tempURL, to: destination)
            }
        } catch {
            log.error("Failed to store file in disk cache: \(error)")
            return nil
        }

        let namesToEvict: [String] = entries.withLock { entries in
            entries?[name] = Entry(size: size, lastUsedAt: Date())
            var cacheSize = entries?.values.reduce(0, { $0 + $1.size }) ?? 0
            var entryCount = entries?.count ?? 0
            let evicted = (entries ?? [:])
                .sorted(by: { $0.value.lastUsedAt < $1.value.lastUsedAt })
                .prefix { entry in
                    guard cacheSize > maxSizeInBytes, entryCount > 1 else { return false }
                    cacheSize -= entry.value.size
                    entryCount -= 1
                    return true
                }
                .map { $0.key }
            evicted.forEach { entries?.removeValue(forKey: $0) }
            return evicted
        }

        for evicted in namesToEvict {
            try? FileManager.default.removeItem(at: directory.appendingPathComponent(evicted))
        }
        return destination
    }

    func remove(forKey key: String, fileExtension: String?) {
        let name = Self.storageName(forKey: key, fileExtension: fileExtension)
        entries.withLock { $0?.removeValue(forKey: name) }
        try? FileManager.default.removeItem(at: directory.appendingPathComponent(name))
    }

    func removeAll() {
        entries.withLock { $0 = [:] }
        try? FileManager.default.removeItem(at: directory)
    }

    private func loadCacheIfNeeded() {
        if entries.withLock({ $0 != nil }) { return }
        let scanned = (try? FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.fileSizeKey],
            options: [.skipsHiddenFiles]
        ))?
            .compactMap { url -> (name: String, size: Int)? in
                let values = try? url.resourceValues(forKeys: [.fileSizeKey])
                guard let size = values?.fileSize else { return nil }
                return (url.lastPathComponent, size)
            }

        entries.withLock { entries in
            guard entries == nil else { return }
            entries = Dictionary(
                uniqueKeysWithValues: (scanned ?? []).map { ($0.name, Entry(size: $0.size, lastUsedAt: Date())) }
            )
        }
    }

    private static func storageName(forKey key: String, fileExtension: String?) -> String {
        let hex = SHA256.hash(data: Data(key.utf8)).map { String(format: "%02x", $0) }.joined()
        if let fileExtension, !fileExtension.isEmpty {
            return "\(hex).\(fileExtension)"
        }
        return hex
    }
}
