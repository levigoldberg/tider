import XCTest
@testable import MarinaMatch

final class ScoringEngineTests: XCTestCase {
    func testNormalizationWinsorizationCaps() {
        let values = [0.0, 10.0, 50.0]
        let scores = Normalization.minMaxScores(values: values, minCap: 0, maxCap: 30, invert: true)
        XCTAssertEqual(scores.count, 3)
        XCTAssertEqual(scores.first, 100, accuracy: 0.01)
        XCTAssertEqual(scores.last, 0, accuracy: 0.01)
    }

    func testRankingWithWeights() {
        let marinas = [
            Marina(id: "n-1", name: "One", latitude: 0, longitude: 0),
            Marina(id: "n-2", name: "Two", latitude: 0, longitude: 0)
        ]
        let env1 = MarinaEnvironmental(windAverageMS: 2, currentAverageMS: 1, tideRangeMeters: 0.5, fetchedAt: Date())
        let env2 = MarinaEnvironmental(windAverageMS: 6, currentAverageMS: 3, tideRangeMeters: 1.5, fetchedAt: Date())
        let envs = ["n-1": env1, "n-2": env2]
        let distances = ["n-1": 1000.0, "n-2": 5000.0]
        let weights = Weights(distance: 0.4, wind: 0.3, current: 0.2, tideRange: 0.1)
        let ranked = ScoringEngine().rank(marinas: marinas, environmentals: envs, distances: distances, weights: weights, radiusMeters: 10_000)
        XCTAssertEqual(ranked.first?.marina.id, "n-1")
    }
}
