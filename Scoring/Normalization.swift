import Foundation

struct Normalization {
    static func winsorize(_ value: Double, min: Double, max: Double) -> Double {
        return Swift.max(min, Swift.min(max, value))
    }

    static func minMaxScores(values: [Double], minCap: Double, maxCap: Double, invert: Bool) -> [Double] {
        let capped = values.map { winsorize($0, min: minCap, max: maxCap) }
        guard let minValue = capped.min(), let maxValue = capped.max(), maxValue > minValue else {
            return capped.map { _ in 100 }
        }
        return capped.map { value in
            let normalized = (value - minValue) / (maxValue - minValue)
            let score = invert ? (1 - normalized) : normalized
            return score * 100
        }
    }
}
