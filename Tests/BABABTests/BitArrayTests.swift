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
        var bitArray = BitArray8()
        XCTAssertEqual(bitArray.startIndex, 0)
        XCTAssertEqual(bitArray.endIndex, 8)
        XCTAssertEqual(bitArray.count, 8)

        bitArray = BitArray(0)
        XCTAssertFalse(bitArray[0])
        XCTAssertFalse(bitArray[7])
        XCTAssertEqual(bitArray.rawValue, 0)
        XCTAssertEqual(bitArray.description, "0000_0000")

        bitArray[0] = true
        bitArray[7] = bitArray[0]
        XCTAssertTrue(bitArray[0])
        XCTAssertTrue(bitArray[7])
        XCTAssertEqual(bitArray.rawValue, 129)
        XCTAssertEqual("\(bitArray)", "1000_0001")

        bitArray = BitArray8(UInt8(0))
        var flag = false
        for idx in bitArray.indices {
            bitArray[idx] = flag
            flag.toggle()
        }

        XCTAssertEqual(bitArray.rawValue, 0xAA)
        for (idx, element) in bitArray.enumerated() {
            bitArray[idx] = !element
        }
        XCTAssertEqual(bitArray.rawValue, 0x55)
        bitArray[0...3] = 0
        XCTAssertEqual(bitArray.rawValue, 0x50)
        bitArray[4...7] = ~(bitArray[4...7])
        XCTAssertEqual(bitArray.rawValue, 0xA0)
        bitArray[0...3] = bitArray[4...7]
        XCTAssertEqual(bitArray.rawValue, 0xAA)
        XCTAssertEqual("\(bitArray)", "1010_1010")
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
