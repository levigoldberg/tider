import Foundation

struct Boat: Codable, Equatable {
    var loaMeters: Double
    var beamMeters: Double
    var draftMeters: Double

    static let empty = Boat(loaMeters: 0, beamMeters: 0, draftMeters: 0)
}
