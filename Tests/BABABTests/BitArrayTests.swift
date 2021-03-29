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
