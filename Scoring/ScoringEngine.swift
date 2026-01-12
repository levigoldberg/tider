import Foundation

struct ScoringEngine {
    func rank(marinas: [Marina], environmentals: [String: MarinaEnvironmental], distances: [String: Double], weights: Weights, radiusMeters: Double) -> [RankedMarina] {
        let weight = weights.normalized()
        let windValues = marinas.map { environmentals[$0.id]?.windAverageMS ?? 0 }.map { $0 * 1.943844 }
        let currentValues = marinas.map { environmentals[$0.id]?.currentAverageMS ?? 0 }.map { $0 * 1.943844 }
        let tideValues = marinas.map { environmentals[$0.id]?.tideRangeMeters ?? 0 }
        let distanceValues = marinas.map { distances[$0.id] ?? radiusMeters }

        let windScores = Normalization.minMaxScores(values: windValues, minCap: 0, maxCap: 30, invert: true)
        let currentScores = Normalization.minMaxScores(values: currentValues, minCap: 0, maxCap: 6, invert: true)
        let tideScores = Normalization.minMaxScores(values: tideValues, minCap: 0, maxCap: 2.5, invert: true)
        let distanceScores = Normalization.minMaxScores(values: distanceValues, minCap: 0, maxCap: radiusMeters, invert: true)

        var ranked: [RankedMarina] = []
        for (index, marina) in marinas.enumerated() {
            guard let env = environmentals[marina.id], let distance = distances[marina.id] else { continue }
            let distanceScore = distanceScores[safe: index] ?? 100
            let windScore = windScores[safe: index] ?? 100
            let currentScore = currentScores[safe: index] ?? 100
            let tideScore = tideScores[safe: index] ?? 100
            let total = (distanceScore * weight.distance) + (windScore * weight.wind) + (currentScore * weight.current) + (tideScore * weight.tideRange)
            let scores = MarinaScores(distance: distanceScore, wind: windScore, current: currentScore, tideRange: tideScore)
            ranked.append(RankedMarina(id: marina.id, marina: marina, distanceMeters: distance, environmental: env, scores: scores, totalScore: total))
        }
        return ranked.sorted { $0.totalScore > $1.totalScore }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
