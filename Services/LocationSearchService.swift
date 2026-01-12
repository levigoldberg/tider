import Foundation
import MapKit

struct LocationSearchService {
    func geocode(query: String) async throws -> CLLocationCoordinate2D {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        do {
            let response = try await MKLocalSearch(request: request).start()
            if let coordinate = response.mapItems.first?.placemark.coordinate {
                return coordinate
            }
        } catch {
            // fallback below
        }
        return try await geocodeFallback(query: query)
    }

    private func geocodeFallback(query: String) async throws -> CLLocationCoordinate2D {
        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.geocodeAddressString(query)
        if let coordinate = placemarks.first?.location?.coordinate {
            return coordinate
        }
        throw NSError(domain: "LocationSearchService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to find location"])
    }
}
