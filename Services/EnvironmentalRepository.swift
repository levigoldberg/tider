import Foundation
import CoreLocation

actor AsyncSemaphore {
    private let limit: Int
    private var current: Int = 0
    private var waiters: [CheckedContinuation<Void, Never>] = []

    init(limit: Int) {
        self.limit = limit
    }

    func acquire() async {
        if current < limit {
            current += 1
            return
        }
        await withCheckedContinuation { continuation in
            waiters.append(continuation)
        }
    }

    func release() {
        if !waiters.isEmpty {
            let continuation = waiters.removeFirst()
            continuation.resume()
        } else {
            current = max(current - 1, 0)
        }
    }
}

struct EnvironmentalRepository {
    private let windClient = OpenMeteoClient()
    private let marineClient = OpenMeteoMarineClient()
    private let cache = CacheStore(folderName: "MarinaMatchEnvironmentalCache")
    private let cacheAge: TimeInterval = 1800
    private let semaphore = AsyncSemaphore(limit: 6)

    func fetchEnvironmental(for marina: Marina) async throws -> MarinaEnvironmental {
        let key = cacheKeyFor(lat: marina.latitude, lon: marina.longitude)
        if let cached: MarinaEnvironmental = await cache.load(key: key, maxAge: cacheAge) {
            return cached
        }
        let wind = try await windClient.fetchWind(latitude: marina.latitude, longitude: marina.longitude)
        let marine = try await marineClient.fetchMarine(latitude: marina.latitude, longitude: marina.longitude)
        let windAvg = average(values: wind.hourly.windSpeed10m)
        let currentAvg = average(values: marine.hourly.oceanCurrentVelocity ?? [])
        let tideRange = range(values: marine.hourly.seaLevelHeightMsl ?? [])
        let environmental = MarinaEnvironmental(windAverageMS: windAvg, currentAverageMS: currentAvg, tideRangeMeters: tideRange, fetchedAt: Date())
        await cache.save(key: key, value: environmental)
        return environmental
    }

    func fetchEnvironmentalBatch(marinas: [Marina], onProgress: @escaping (Int, Int) -> Void) async throws -> [String: MarinaEnvironmental] {
        var results: [String: MarinaEnvironmental] = [:]
        let total = marinas.count
        var completed = 0
        try await withThrowingTaskGroup(of: (String, MarinaEnvironmental).self) { group in
            for marina in marinas {
                await semaphore.acquire()
                group.addTask {
                    defer { Task { await semaphore.release() } }
                    let env = try await fetchEnvironmental(for: marina)
                    return (marina.id, env)
                }
            }
            for try await (id, env) in group {
                completed += 1
                onProgress(completed, total)
                results[id] = env
            }
        }
        return results
    }

    private func average(values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }

    private func range(values: [Double]) -> Double {
        guard let min = values.min(), let max = values.max() else { return 0 }
        return max - min
    }

    private func cacheKeyFor(lat: Double, lon: Double) -> String {
        let roundedLat = String(format: "%.3f", lat)
        let roundedLon = String(format: "%.3f", lon)
        return "env_\(roundedLat)_\(roundedLon)"
    }
}
