import XCTest
@testable import BABAB

final class BitArrayTests: XCTestCase {

    func testBitArray8() {
        var ba = BitArray8(0)
        ba[3] = 1
        XCTAssertEqual(ba.rawValue, 8)
    }

    static var allTests = [
        ("testBitArray8", testBitArray8),
    ]
}
