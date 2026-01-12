import Foundation
import CoreLocation

struct MarinaRepository {
    private let client = OverpassClient()
    private let cache = CacheStore(folderName: "MarinaMatchOverpassCache")
    private let cacheAge: TimeInterval = 600

    func fetchMarinas(center: CLLocationCoordinate2D, radiusKm: Double) async throws -> [Marina] {
        let radiusMeters = radiusKm * 1000
        let radii = expandedRadii(initial: radiusMeters)
        var best: [Marina] = []
        for radius in radii {
            let cacheKey = cacheKeyFor(lat: center.latitude, lon: center.longitude, radius: radius)
            if let cached: [Marina] = await cache.load(key: cacheKey, maxAge: cacheAge) {
                if cached.count >= 30 || radius == radii.last {
                    return cached
                }
                best = cached
                continue
            }
            let response = try await client.fetchMarinas(latitude: center.latitude, longitude: center.longitude, radiusMeters: radius)
            let marinas = parse(response: response)
            await cache.save(key: cacheKey, value: marinas)
            if marinas.count >= 30 || radius == radii.last {
                return marinas
            }
            best = marinas
        }
        return best
    }

    private func expandedRadii(initial: Double) -> [Double] {
        let caps: [Double] = [10_000, 25_000, 50_000, 75_000, 100_000]
        var radii = [initial]
        for cap in caps where cap > initial {
            radii.append(cap)
        }
        if initial > 100_000 {
            radii = [100_000]
        }
        return Array(Set(radii)).sorted()
    }

    func parse(response: OverpassResponse) -> [Marina] {
        var seen = Set<String>()
        var marinas: [Marina] = []
        for element in response.elements {
            let id = "\(element.type)-\(element.id)"
            guard !seen.contains(id) else { continue }
            let name = element.tags?["name"]?.trimmingCharacters(in: .whitespacesAndNewlines)
            let finalName = name?.isEmpty == false ? name! : "Unnamed Marina"
            let lat = element.lat ?? element.center?.lat
            let lon = element.lon ?? element.center?.lon
            guard let latitude = lat, let longitude = lon else { continue }
            let marina = Marina(id: id, name: finalName, latitude: latitude, longitude: longitude)
            marinas.append(marina)
            seen.insert(id)
        }
        return marinas
    }

    private func cacheKeyFor(lat: Double, lon: Double, radius: Double) -> String {
        let roundedLat = String(format: "%.3f", lat)
        let roundedLon = String(format: "%.3f", lon)
        return "overpass_\(roundedLat)_\(roundedLon)_\(Int(radius))"
    }
}
