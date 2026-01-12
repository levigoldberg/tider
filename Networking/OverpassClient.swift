import Foundation

struct OverpassClient {
    func fetchMarinas(latitude: Double, longitude: Double, radiusMeters: Double) async throws -> OverpassResponse {
        let query = """
        [out:json][timeout:25];
        (
          node[leisure=marina](around:\(Int(radiusMeters)),\(latitude),\(longitude));
          way[leisure=marina](around:\(Int(radiusMeters)),\(latitude),\(longitude));
          relation[leisure=marina](around:\(Int(radiusMeters)),\(latitude),\(longitude));
          node[seamark:harbour:category=marina](around:\(Int(radiusMeters)),\(latitude),\(longitude));
          way[seamark:harbour:category=marina](around:\(Int(radiusMeters)),\(latitude),\(longitude));
          relation[seamark:harbour:category=marina](around:\(Int(radiusMeters)),\(latitude),\(longitude));
          node[harbour](around:\(Int(radiusMeters)),\(latitude),\(longitude));
          way[harbour](around:\(Int(radiusMeters)),\(latitude),\(longitude));
          relation[harbour](around:\(Int(radiusMeters)),\(latitude),\(longitude));
        );
        out center tags;
        """
        guard let url = URL(string: "https://overpass-api.de/api/interpreter") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "data=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")".data(using: .utf8)
        return try await fetchWithRetry(request: request)
    }

    private func fetchWithRetry(request: URLRequest) async throws -> OverpassResponse {
        var attempt = 0
        var delay: UInt64 = 500_000_000
        while true {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return try JSONDecoder().decode(OverpassResponse.self, from: data)
            } catch {
                attempt += 1
                if attempt >= 3 {
                    throw error
                }
                try await Task.sleep(nanoseconds: delay)
                delay *= 2
            }
        }
    }
}

struct OverpassResponse: Codable {
    let elements: [OverpassElement]
}

struct OverpassElement: Codable {
    let type: String
    let id: Int
    let lat: Double?
    let lon: Double?
    let center: OverpassCenter?
    let tags: [String: String]?
}

struct OverpassCenter: Codable {
    let lat: Double
    let lon: Double
}
