import Foundation

struct OpenMeteoMarineClient {
    private let httpClient = HTTPClient()

    func fetchMarine(latitude: Double, longitude: Double) async throws -> OpenMeteoMarineResponse {
        var components = URLComponents(string: "https://marine-api.open-meteo.com/v1/marine")
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "hourly", value: "ocean_current_velocity,sea_level_height_msl"),
            URLQueryItem(name: "forecast_days", value: "1"),
            URLQueryItem(name: "timezone", value: "UTC")
        ]
        guard let url = components?.url else {
            throw URLError(.badURL)
        }
        let data = try await httpClient.fetch(url: url)
        return try JSONDecoder().decode(OpenMeteoMarineResponse.self, from: data)
    }
}

struct OpenMeteoMarineResponse: Codable {
    let hourly: OpenMeteoMarineHourly
}

struct OpenMeteoMarineHourly: Codable {
    let time: [String]
    let oceanCurrentVelocity: [Double]?
    let seaLevelHeightMsl: [Double]?

    enum CodingKeys: String, CodingKey {
        case time
        case oceanCurrentVelocity = "ocean_current_velocity"
        case seaLevelHeightMsl = "sea_level_height_msl"
    }
}
