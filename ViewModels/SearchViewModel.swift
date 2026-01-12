import Foundation
import CoreLocation

@MainActor
final class SearchViewModel: ObservableObject {
    enum LoadingState: Equatable {
        case idle
        case searchingLocation
        case findingMarinas
        case fetchingEnvironment(current: Int, total: Int)
        case error(String)
    }

    @Published var queryText: String = ""
    @Published var radiusKm: Double = 25
    @Published var useMetric: Bool = true
    @Published var boat = Boat.empty
    @Published var weights = Weights.defaultWeights
    @Published var state: LoadingState = .idle
    @Published var resultsViewModel: ResultsViewModel?
    @Published var showResults = false

    private let locationService = LocationSearchService()
    private let marinaRepository = MarinaRepository()
    private let environmentalRepository = EnvironmentalRepository()

    func findMarinas() async {
        state = .searchingLocation
        do {
            let coordinate = try await locationService.geocode(query: queryText)
            state = .findingMarinas
            let marinas = try await marinaRepository.fetchMarinas(center: coordinate, radiusKm: radiusKm)
            let distances = computeDistances(center: coordinate, marinas: marinas)
            state = .fetchingEnvironment(current: 0, total: marinas.count)
            let envs = try await environmentalRepository.fetchEnvironmentalBatch(marinas: marinas) { [weak self] current, total in
                Task { @MainActor in
                    self?.state = .fetchingEnvironment(current: current, total: total)
                }
            }
            let resultsVM = ResultsViewModel(center: coordinate, radiusMeters: radiusKm * 1000, marinas: marinas, environmentals: envs, distances: distances, weights: weights, useMetric: useMetric)
            resultsViewModel = resultsVM
            showResults = true
            state = .idle
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    private func computeDistances(center: CLLocationCoordinate2D, marinas: [Marina]) -> [String: Double] {
        let centerLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
        var result: [String: Double] = [:]
        for marina in marinas {
            let location = CLLocation(latitude: marina.latitude, longitude: marina.longitude)
            result[marina.id] = centerLocation.distance(from: location)
        }
        return result
    }
}
