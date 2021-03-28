//
//  BitArrayTests.swift
//  BABABTests
//
//  Created by Simon Evans on 27/03/2021.
//

import BABAB
import XCTest

final class BitArrayTests: XCTestCase {

    func testBitArray() {
        var ba = BitArray8()
        XCTAssertEqual(ba.startIndex, 0)
        XCTAssertEqual(ba.endIndex, 8)
        XCTAssertEqual(ba.count, 8)

        ba = BitArray(0)
        XCTAssertEqual(ba[0], 0)
        XCTAssertEqual(ba[7], 0)
        XCTAssertEqual(ba.rawValue, 0)
        XCTAssertEqual(ba.description, "00000000")

        ba[0] = 1
        ba[7] = ba[0]
        XCTAssertEqual(ba[0], 1)
        XCTAssertEqual(ba[7], 1)
        XCTAssertEqual(ba.rawValue, 129)
        XCTAssertEqual("\(ba)", "10000001")

        ba = BitArray8(UInt8(0))
        var flag = false
        for (idx, _) in ba.enumerated() {
            ba[idx] = Int(flag)
            flag.toggle()
        }

        XCTAssertEqual(ba.rawValue, 0xAA)
        for (idx, element) in ba.enumerated() {
            ba[idx] = 1 - element
        }
        XCTAssertEqual(ba.rawValue, 0x55)
        ba[0...3] = 0
        XCTAssertEqual(ba.rawValue, 0x50)
        ba[4...7] = ~(ba[4...7])
        XCTAssertEqual(ba.rawValue, 0xA0)
        ba[0...3] = ba[4...7]
        XCTAssertEqual(ba.rawValue, 0xAA)
        XCTAssertEqual("\(ba)", "10101010")
    }

    static var allTests = [
        ("testBitArray", testBitArray)
    ]
}
