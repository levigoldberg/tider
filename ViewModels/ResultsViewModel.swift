import Foundation
import CoreLocation
import Combine

@MainActor
final class ResultsViewModel: ObservableObject {
    @Published var rankedMarinas: [RankedMarina]
    @Published var weights: Weights {
        didSet { rescore() }
    }
    @Published var useMetric: Bool

    let center: CLLocationCoordinate2D
    let radiusMeters: Double
    let rawMarinas: [Marina]
    let environmentals: [String: MarinaEnvironmental]
    let distances: [String: Double]

    private let scoring = ScoringEngine()

    init(center: CLLocationCoordinate2D, radiusMeters: Double, marinas: [Marina], environmentals: [String: MarinaEnvironmental], distances: [String: Double], weights: Weights, useMetric: Bool) {
        self.center = center
        self.radiusMeters = radiusMeters
        self.rawMarinas = marinas
        self.environmentals = environmentals
        self.distances = distances
        self.weights = weights
        self.useMetric = useMetric
        self.rankedMarinas = scoring.rank(marinas: marinas, environmentals: environmentals, distances: distances, weights: weights, radiusMeters: radiusMeters)
    }

    func rescore() {
        rankedMarinas = scoring.rank(marinas: rawMarinas, environmentals: environmentals, distances: distances, weights: weights, radiusMeters: radiusMeters)
    }
}
