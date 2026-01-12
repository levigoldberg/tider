import SwiftUI

struct MarinaDetailView: View {
    let ranked: RankedMarina
    let useMetric: Bool
    let weights: Weights

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(ranked.marina.name)
                    .font(.title2)
                    .fontWeight(.semibold)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Raw values")
                        .font(.headline)
                    Text("Distance: \(formatDistance(ranked.distanceMeters))")
                    Text("Average wind (next 24h): \(formatKnots(ranked.environmental.windAverageMS))")
                    Text("Average current (next 24h): \(formatKnots(ranked.environmental.currentAverageMS))")
                    Text("Tide range proxy (next 24h): \(formatTideRange(ranked.environmental.tideRangeMeters))")
                    Text("Sea level height and tide range are model forecasts; not depth and not for navigation.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Score breakdown")
                        .font(.headline)
                    Text("Distance score: \(Int(ranked.scores.distance))")
                    Text("Wind score: \(Int(ranked.scores.wind))")
                    Text("Current score: \(Int(ranked.scores.current))")
                    Text("Tide range score: \(Int(ranked.scores.tideRange))")
                    Text("Total score: \(Int(ranked.totalScore))")
                    Text("Total score = Distance×\(formatWeight(weights.distance)) + Wind×\(formatWeight(weights.wind)) + Current×\(formatWeight(weights.current)) + Tide Range×\(formatWeight(weights.tideRange))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle("Marina Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func formatDistance(_ meters: Double) -> String {
        if useMetric {
            return String(format: "%.1f km", meters / 1000)
        }
        return String(format: "%.1f mi", meters / 1609.34)
    }

    private func formatKnots(_ metersPerSecond: Double) -> String {
        let knots = metersPerSecond * 1.943844
        return String(format: "%.1f kn", knots)
    }

    private func formatTideRange(_ meters: Double) -> String {
        if useMetric {
            return String(format: "%.2f m", meters)
        }
        return String(format: "%.2f ft", meters * 3.28084)
    }

    private func formatWeight(_ value: Double) -> String {
        String(format: "%.2f", value)
    }
}
