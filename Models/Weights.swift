import Foundation

struct Weights: Codable, Equatable {
    var distance: Double
    var wind: Double
    var current: Double
    var tideRange: Double

    static let defaultWeights = Weights(distance: 0.35, wind: 0.30, current: 0.25, tideRange: 0.10)

    func normalized() -> Weights {
        let total = max(distance + wind + current + tideRange, 0.0001)
        return Weights(
            distance: distance / total,
            wind: wind / total,
            current: current / total,
            tideRange: tideRange / total
        )
    }
}
