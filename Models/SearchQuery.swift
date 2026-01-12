import Foundation
import CoreLocation

struct SearchQuery: Equatable {
    var text: String
    var radiusKm: Double
    var useMetric: Bool
    var boat: Boat
    var weights: Weights
    var coordinate: CLLocationCoordinate2D?
}

extension SearchQuery {
    static let empty = SearchQuery(text: "", radiusKm: 25, useMetric: true, boat: .empty, weights: .defaultWeights, coordinate: nil)
}
