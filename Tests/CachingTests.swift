import XCTest
@testable import MarinaMatch

final class CachingTests: XCTestCase {
    func testCacheReadWrite() async {
        let store = CacheStore(folderName: "TestCache_\(UUID().uuidString)")
        let value = MarinaEnvironmental(windAverageMS: 1, currentAverageMS: 2, tideRangeMeters: 0.5, fetchedAt: Date())
        await store.save(key: "sample", value: value)
        let loaded: MarinaEnvironmental? = await store.load(key: "sample", maxAge: 3600)
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.windAverageMS, value.windAverageMS, accuracy: 0.001)
    }
}
