import XCTest
@testable import MarinaMatch

final class OverpassParsingTests: XCTestCase {
    func testParsingNodesWaysRelations() {
        let response = OverpassResponse(elements: [
            OverpassElement(type: "node", id: 1, lat: 10, lon: 20, center: nil, tags: ["name": "Harbor One"]),
            OverpassElement(type: "way", id: 2, lat: nil, lon: nil, center: OverpassCenter(lat: 30, lon: 40), tags: [:]),
            OverpassElement(type: "relation", id: 3, lat: nil, lon: nil, center: OverpassCenter(lat: 50, lon: 60), tags: ["name": ""])
        ])
        let repo = MarinaRepository()
        let marinas = repo.parse(response: response)
        XCTAssertEqual(marinas.count, 3)
        XCTAssertEqual(marinas[0].name, "Harbor One")
        XCTAssertEqual(marinas[1].name, "Unnamed Marina")
        XCTAssertEqual(marinas[2].name, "Unnamed Marina")
        XCTAssertEqual(marinas[1].id, "way-2")
    }
}
