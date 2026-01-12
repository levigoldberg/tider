import Foundation

struct RankedMarina: Identifiable, Hashable {
    let id: String
    let marina: Marina
    let distanceMeters: Double
    let environmental: MarinaEnvironmental
    let scores: MarinaScores
    let totalScore: Double
}

struct MarinaScores: Hashable {
    let distance: Double
    let wind: Double
    let current: Double
    let tideRange: Double
}
