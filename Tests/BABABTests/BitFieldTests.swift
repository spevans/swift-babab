//
//  BitFieldTests.swift
//  BABABTests
//
//  Created by Simon Evans on 27/03/2021.
//

import BABAB
import XCTest

final class BitFieldTests: XCTestCase {

    func testBitField() {
        var bitField = BitField8()
        XCTAssertEqual(bitField.startIndex, 0)
        XCTAssertEqual(bitField.endIndex, 8)
        XCTAssertEqual(bitField.count, 8)

        bitField = BitField(0)
        XCTAssertFalse(bitField[0])
        XCTAssertFalse(bitField[7])
        XCTAssertEqual(bitField.rawValue, 0)
        XCTAssertEqual(bitField.description, "0000_0000")

        bitField[0] = true
        bitField[7] = bitField[0]
        XCTAssertTrue(bitField[0])
        XCTAssertTrue(bitField[7])
        XCTAssertEqual(bitField.rawValue, 129)
        XCTAssertEqual("\(bitField)", "1000_0001")

        bitField = BitField8(UInt8(0))
        var flag = false
        for idx in bitField.indices {
            bitField[idx] = flag
            flag.toggle()
        }

        XCTAssertEqual(bitField.rawValue, 0xAA)
        for (idx, element) in bitField.enumerated() {
            bitField[idx] = !element
        }
        XCTAssertEqual(bitField.rawValue, 0x55)
        bitField[0...3] = 0
        XCTAssertEqual(bitField.rawValue, 0x50)
        bitField[4...7] = ~(bitField[4...7])
        XCTAssertEqual(bitField.rawValue, 0xA0)
        bitField[0...3] = bitField[4...7]
        XCTAssertEqual(bitField.rawValue, 0xAA)
        XCTAssertEqual("\(bitField)", "1010_1010")
    }

    func testSubSequence() {
        var allBitsSet = BitField16(UInt16.max)
        XCTAssertEqual(allBitsSet[0..<0].rawValue, 0)
        XCTAssertEqual(allBitsSet[0..<16].rawValue, UInt16.max)
        XCTAssertEqual(allBitsSet[0..<8].rawValue, 0xff)
        XCTAssertEqual(allBitsSet[8..<16].rawValue, 0xff)

        allBitsSet[0..<8] = BitField16(0x5555)
        XCTAssertEqual(allBitsSet.rawValue, 0xff55)
        allBitsSet[8..<16] = BitField16(0xAA)
        XCTAssertEqual(allBitsSet.rawValue, 0xAA55)
    }

    static var allTests = [
        ("testBitField", testBitField),
        ("testSubSequence", testSubSequence),
    ]
}
