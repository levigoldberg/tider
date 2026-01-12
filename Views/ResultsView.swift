import SwiftUI
import MapKit

struct ResultsView: View {
    @ObservedObject var viewModel: ResultsViewModel
    @State private var mapPosition: MapCameraPosition

    init(viewModel: ResultsViewModel) {
        self.viewModel = viewModel
        let region = MKCoordinateRegion(center: viewModel.center, latitudinalMeters: viewModel.radiusMeters * 2, longitudinalMeters: viewModel.radiusMeters * 2)
        _mapPosition = State(initialValue: .region(region))
    }

    var body: some View {
        VStack(spacing: 0) {
            Map(position: $mapPosition) {
                ForEach(viewModel.rankedMarinas) { ranked in
                    Annotation(ranked.marina.name, coordinate: ranked.marina.coordinate) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .frame(height: 260)

            List(viewModel.rankedMarinas) { ranked in
                NavigationLink {
                    MarinaDetailView(ranked: ranked, useMetric: viewModel.useMetric, weights: viewModel.weights.normalized())
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(ranked.marina.name)
                            .font(.headline)
                        Text("Distance: \(formatDistance(ranked.distanceMeters, useMetric: viewModel.useMetric))")
                            .font(.subheadline)
                        Text("Total score: \(Int(ranked.totalScore))")
                            .font(.subheadline)
                        HStack {
                            Text("Wind: \(formatKnots(ranked.environmental.windAverageMS))")
                            Text("Current: \(formatKnots(ranked.environmental.currentAverageMS))")
                        }
                        .font(.caption)
                        Text("Tide range proxy: \(formatTideRange(ranked.environmental.tideRangeMeters, useMetric: viewModel.useMetric))")
                            .font(.caption)
                    }
                }
            }
        }
        .navigationTitle("Results")
    }

    private func formatDistance(_ meters: Double, useMetric: Bool) -> String {
        if useMetric {
            return String(format: "%.1f km", meters / 1000)
        }
        return String(format: "%.1f mi", meters / 1609.34)
    }

    private func formatKnots(_ metersPerSecond: Double) -> String {
        let knots = metersPerSecond * 1.943844
        return String(format: "%.1f kn", knots)
    }

    private func formatTideRange(_ meters: Double, useMetric: Bool) -> String {
        if useMetric {
            return String(format: "%.2f m", meters)
        }
        return String(format: "%.2f ft", meters * 3.28084)
    }
}
