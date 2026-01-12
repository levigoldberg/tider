import Foundation

struct OpenMeteoClient {
    private let httpClient = HTTPClient()

    func fetchWind(latitude: Double, longitude: Double) async throws -> OpenMeteoWindResponse {
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "hourly", value: "wind_speed_10m"),
            URLQueryItem(name: "forecast_days", value: "1"),
            URLQueryItem(name: "timezone", value: "UTC")
        ]
        guard let url = components?.url else {
            throw URLError(.badURL)
        }
        let data = try await httpClient.fetch(url: url)
        return try JSONDecoder().decode(OpenMeteoWindResponse.self, from: data)
    }
}

struct OpenMeteoWindResponse: Codable {
    let hourly: OpenMeteoWindHourly
}

struct OpenMeteoWindHourly: Codable {
    let time: [String]
    let windSpeed10m: [Double]

    enum CodingKeys: String, CodingKey {
        case time
        case windSpeed10m = "wind_speed_10m"
    }
}
