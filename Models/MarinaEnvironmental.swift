import Foundation

struct MarinaEnvironmental: Codable, Equatable {
    let windAverageMS: Double
    let currentAverageMS: Double
    let tideRangeMeters: Double
    let fetchedAt: Date
}
