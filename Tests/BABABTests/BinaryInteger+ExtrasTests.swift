//
//  BinaryInteger+ExtrasTests.swift
//  BABABTests
//
//  Created by Simon Evans on 26/06/2021.
//

import BABAB
import XCTest

class BinaryIntegerExtrasTests: XCTestCase {
    func testInit() {
        XCTAssertEqual(Int(false), 0)
        XCTAssertEqual(UInt8(true), 1)
    }

    func testHex() {
        XCTAssertEqual(UInt8.min.hex(), "00")
        XCTAssertEqual(UInt8.max.hex(), "ff")
        XCTAssertEqual(UInt16.min.hex(), "0000")
        XCTAssertEqual(UInt16.max.hex(), "ffff")
        XCTAssertEqual(UInt32.min.hex(), "00000000")
        XCTAssertEqual(UInt32.max.hex(), "ffffffff")
        XCTAssertEqual(UInt64.min.hex(), "0000000000000000")
        XCTAssertEqual(UInt64.max.hex(), "ffffffffffffffff")
        XCTAssertEqual(UInt8.min.hex(separators: true), "00")
        XCTAssertEqual(UInt8.max.hex(separators: true), "ff")
        XCTAssertEqual(UInt16.min.hex(separators: true), "0000")
        XCTAssertEqual(UInt16.max.hex(separators: true), "ffff")
        XCTAssertEqual(UInt32.min.hex(separators: true), "0000_0000")
        XCTAssertEqual(UInt32.max.hex(separators: true), "ffff_ffff")
        XCTAssertEqual(UInt64.min.hex(separators: true), "0000_0000_0000_0000")
        XCTAssertEqual(UInt64.max.hex(separators: true), "ffff_ffff_ffff_ffff")
    }

    func testOctal() {
        XCTAssertEqual(UInt8.min.octal(), "000")
        XCTAssertEqual(UInt8.max.octal(), "377")
        XCTAssertEqual(UInt16.min.octal(), "000000")
        XCTAssertEqual(UInt16.max.octal(), "177777")
        XCTAssertEqual(UInt32.min.octal(), "00000000000")
        XCTAssertEqual(UInt32.max.octal(), "37777777777")
        XCTAssertEqual(UInt64.min.octal(), "0000000000000000000000")
        XCTAssertEqual(UInt64.max.octal(), "1777777777777777777777")
        XCTAssertEqual(UInt8.min.octal(separators: true), "000")
        XCTAssertEqual(UInt8.max.octal(separators: true), "377")
        XCTAssertEqual(UInt16.min.octal(separators: true), "00_0000")
        XCTAssertEqual(UInt16.max.octal(separators: true), "17_7777")
        XCTAssertEqual(UInt32.min.octal(separators: true), "000_0000_0000")
        XCTAssertEqual(UInt32.max.octal(separators: true), "377_7777_7777")
        XCTAssertEqual(UInt64.min.octal(separators: true), "00_0000_0000_0000_0000_0000")
        XCTAssertEqual(UInt64.max.octal(separators: true), "17_7777_7777_7777_7777_7777")
    }

    func testBinary() {
        XCTAssertEqual(UInt8.min.binary(), "00000000")
        XCTAssertEqual(UInt8.max.binary(), "11111111")
        XCTAssertEqual(UInt16.min.binary(), "0000000000000000")
        XCTAssertEqual(UInt16.max.binary(), "1111111111111111")
        XCTAssertEqual(UInt32.min.binary(), "00000000000000000000000000000000")
        XCTAssertEqual(UInt32.max.binary(), "11111111111111111111111111111111")
        XCTAssertEqual(UInt64.min.binary(), "0000000000000000000000000000000000000000000000000000000000000000")
        XCTAssertEqual(UInt64.max.binary(), "1111111111111111111111111111111111111111111111111111111111111111")
        XCTAssertEqual(UInt8.min.binary(separators: true), "0000_0000")
        XCTAssertEqual(UInt8.max.binary(separators: true), "1111_1111")
        XCTAssertEqual(UInt16.min.binary(separators: true), "0000_0000_0000_0000")
        XCTAssertEqual(UInt16.max.binary(separators: true), "1111_1111_1111_1111")
        XCTAssertEqual(UInt32.min.binary(separators: true), "0000_0000_0000_0000_0000_0000_0000_0000")
        XCTAssertEqual(UInt32.max.binary(separators: true), "1111_1111_1111_1111_1111_1111_1111_1111")
        XCTAssertEqual(UInt64.min.binary(separators: true),
                       "0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000")
        XCTAssertEqual(UInt64.max.binary(separators: true),
                       "1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111")
    }

    static var allTests = [
        ("testInit", testInit),
        ("testHex", testHex),
        ("testOctal", testOctal),
        ("testBinary", testBinary),
    ]
}
