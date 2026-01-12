import Foundation

struct CacheEntry<T: Codable>: Codable {
    let timestamp: Date
    let value: T
}

actor CacheStore {
    private let directory: URL

    init(folderName: String) {
        let fileManager = FileManager.default
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = base.appendingPathComponent(folderName, isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        directory = dir
    }

    func load<T: Codable>(key: String, maxAge: TimeInterval) async -> T? {
        let fileURL = directory.appendingPathComponent(key).appendingPathExtension("json")
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        guard let entry = try? JSONDecoder().decode(CacheEntry<T>.self, from: data) else {
            return nil
        }
        if Date().timeIntervalSince(entry.timestamp) > maxAge {
            return nil
        }
        return entry.value
    }

    func save<T: Codable>(key: String, value: T) async {
        let entry = CacheEntry(timestamp: Date(), value: value)
        guard let data = try? JSONEncoder().encode(entry) else {
            return
        }
        let fileURL = directory.appendingPathComponent(key).appendingPathExtension("json")
        try? data.write(to: fileURL, options: .atomic)
    }
}
