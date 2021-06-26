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
        XCTAssertFalse(ba[0])
        XCTAssertFalse(ba[7])
        XCTAssertEqual(ba.rawValue, 0)
        XCTAssertEqual(ba.description, "0000_0000")

        ba[0] = true
        ba[7] = ba[0]
        XCTAssertTrue(ba[0])
        XCTAssertTrue(ba[7])
        XCTAssertEqual(ba.rawValue, 129)
        XCTAssertEqual("\(ba)", "1000_0001")

        ba = BitArray8(UInt8(0))
        var flag = false
        for (idx, _) in ba.enumerated() {
            ba[idx] = flag
            flag.toggle()
        }

        XCTAssertEqual(ba.rawValue, 0xAA)
        for (idx, element) in ba.enumerated() {
            ba[idx] = !element
        }
        XCTAssertEqual(ba.rawValue, 0x55)
        ba[0...3] = 0
        XCTAssertEqual(ba.rawValue, 0x50)
        ba[4...7] = ~(ba[4...7])
        XCTAssertEqual(ba.rawValue, 0xA0)
        ba[0...3] = ba[4...7]
        XCTAssertEqual(ba.rawValue, 0xAA)
        XCTAssertEqual("\(ba)", "1010_1010")
    }

    func testSubSequence() {
        var allBitsSet = BitArray16(UInt16.max)
        XCTAssertEqual(allBitsSet[0..<0].rawValue, 0)
        XCTAssertEqual(allBitsSet[0..<16].rawValue, UInt16.max)
        XCTAssertEqual(allBitsSet[0..<8].rawValue, 0xff)
        XCTAssertEqual(allBitsSet[8..<16].rawValue, 0xff)

        allBitsSet[0..<8] = BitArray16(0x5555)
        XCTAssertEqual(allBitsSet.rawValue, 0xff55)
        allBitsSet[8..<16] = BitArray16(0xAA)
        XCTAssertEqual(allBitsSet.rawValue, 0xAA55)
    }

    static var allTests = [
        ("testBitArray", testBitArray),
        ("testSubSequence", testSubSequence),
    ]
}
