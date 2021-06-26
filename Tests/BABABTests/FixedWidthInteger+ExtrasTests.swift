//
//  FixedWidthInteger+ExtrasTests.swift
//  BABABTests
//
//  Created by Simon Evans on 24/06/2021.
//  Copyright © 2021 Simon Evans. All rights reserved.
//

import BABAB
import XCTest

class FixedWidthIntegerExtrasTests: XCTestCase {

    func testBit() {
        var byte = UInt8(0)
        XCTAssertFalse(byte.bit(0))
        XCTAssertFalse(byte.bit(7))

        byte.bit(0, true)
        XCTAssertTrue(byte.bit(0))
        XCTAssertEqual(byte, 1)

        byte.bit(7, true)
        XCTAssertTrue(byte.bit(7))
        XCTAssertEqual(byte, 129)
    }

    func testBitSet() {
        var value = UInt16(0)

        XCTAssertNil(value.lowestBitSet)
        XCTAssertNil(value.highestBitSet)
        XCTAssertNil(value.clearLowestBitSet())
        XCTAssertNil(value.clearHighestBitSet())

        value = UInt16.max
        XCTAssertEqual(value.lowestBitSet, 0)
        XCTAssertEqual(value.highestBitSet, 15)
        XCTAssertEqual(value.clearLowestBitSet(), 0)
        XCTAssertEqual(value.clearLowestBitSet(), 1)
        XCTAssertEqual(value.clearHighestBitSet(), 15)
        XCTAssertEqual(value.clearHighestBitSet(), 14)

        value = 0b1000
        XCTAssertEqual(value.lowestBitSet, 3)
        XCTAssertEqual(value.highestBitSet, 3)

        XCTAssertEqual(value.clearLowestBitSet(), 3)
        XCTAssertNil(value.lowestBitSet)
        XCTAssertNil(value.highestBitSet)
        XCTAssertNil(value.clearHighestBitSet())

        value = 0b1000
        XCTAssertEqual(value.clearHighestBitSet(), 3)
        XCTAssertNil(value.lowestBitSet)
        XCTAssertNil(value.highestBitSet)
        XCTAssertNil(value.clearLowestBitSet())

        value = 0b0110
        value.clearLowestBitSet()
        value.clearLowestBitSet()
        XCTAssertEqual(value, 0)
    }

    func testInitFromCollection() {
        let bytes: [UInt8] = [0, 1, 2, 3, 4, 0x5, 0xb6, 0xc7, 0xd8, 0xe9, 0xff]

        XCTAssertEqual(UInt8(littleEndianBytes: bytes), 0)
        XCTAssertEqual(UInt8(littleEndianBytes: bytes[3...]), 3)
        XCTAssertEqual(UInt8(littleEndianBytes: bytes[9...9]), 0xe9)
        XCTAssertEqual(UInt16(littleEndianBytes: bytes[9...]), 0xffe9)
        XCTAssertEqual(UInt32(littleEndianBytes: bytes[1...]), 0x04030201)
        XCTAssertEqual(UInt64(littleEndianBytes: bytes), 0xc7b6050403020100)

        XCTAssertEqual(UInt8(bigEndianBytes: bytes), 0)
        XCTAssertEqual(UInt8(bigEndianBytes: bytes[3...]), 3)
        XCTAssertEqual(UInt8(bigEndianBytes: bytes[9...9]), 0xe9)
        XCTAssertEqual(UInt16(bigEndianBytes: bytes[9...]), 0xe9ff)
        XCTAssertEqual(UInt32(bigEndianBytes: bytes[1...]), 0x01020304)
        XCTAssertEqual(UInt64(bigEndianBytes: bytes), 0x000102030405b6c7)
    }

    func testBCD() {
        XCTAssertEqual(UInt8(bcd: 0x12), 12)
        XCTAssertNil(UInt8(bcd: 123))

        XCTAssertNil(UInt8(123).bcdValue)
        XCTAssertEqual(UInt32(1357).bcdValue, 0x1357)
    }

    static var allTests = [
        ("testBit", testBit),
        ("testBitSet", testBitSet),
        ("testInitFromCollection", testInitFromCollection),
        ("testBCD", testBCD),
    ]
}
