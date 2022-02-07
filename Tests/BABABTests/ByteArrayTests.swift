//
//  ByteArrayTests.swift
//  BABABTests
//
//  Created by Simon Evans on 26/06/2021.
//  Copyright © 2021 Simon Evans. All rights reserved.
//

import BABAB
import XCTest

class ByteArrayTests: XCTestCase {
    func testInit() {
        do {
            let array = ByteArray<UInt8>()
            XCTAssertEqual(array.capacity, 0)
            XCTAssertEqual(array.count, 0)
            XCTAssertEqual(array.rawValue, 0)
        }

        do {
            let array = ByteArray<UInt32>(repeating: 0x55, count: 0)
            XCTAssertEqual(array.capacity, 3)
            XCTAssertEqual(array.count, 0)
            XCTAssertEqual(array.rawValue, 0x0)
        }

        do {
            let array = ByteArray<UInt32>(repeating: 0x55, count: 2)
            XCTAssertEqual(array.count, 2)
            XCTAssertEqual(array.rawValue, 0x555502)
        }

        do {
            let array = ByteArray<UInt64>(rawValue: 0x0102_0303)
            XCTAssertEqual(array.count, 3)
            XCTAssertEqual(array.description, "[3, 2, 1]")
        }

        do {
            let array = ByteArray<UInt64>([])
            XCTAssertEqual(array.count, 0)
            XCTAssertEqual(array.rawValue, 0)
            XCTAssertEqual(array.description, "[]")
        }

        do {
            let array = ByteArray<UInt64>([2, 4, 6, 8, 10])
            XCTAssertEqual(array.count, 5)
            XCTAssertEqual(array.description, "[2, 4, 6, 8, 10]")
        }
    }

    func testCapacity() {
        do {
            var array = ByteArray<UInt8>([])
            XCTAssertEqual(array.capacity, 0)
            array.reserveCapacity(0)
            array.removeAll(keepingCapacity: true)
            XCTAssertEqual(array.rawValue, 0)
        }
        do {
            var array = ByteArray<UInt16>([1])
            XCTAssertEqual(array.capacity, 1)
            array.reserveCapacity(1)
            array.removeAll(keepingCapacity: false)
            XCTAssertEqual(array.rawValue, 0)
        }
        do {
            var array = ByteArray<UInt32>([2, 3])
            XCTAssertEqual(array.capacity, 3)
            array.reserveCapacity(2)
            array.removeAll(keepingCapacity: true)
            XCTAssertEqual(array.rawValue, 0)
        }
        do {
            var array = ByteArray<UInt64>([0xA1, 0xB2, 0xC3])
            XCTAssertEqual(array.capacity, 7)
            array.reserveCapacity(6)
            array.removeAll(keepingCapacity: false)
            XCTAssertEqual(array.rawValue, 0)
        }
    }

    func testEqual() {
        XCTAssertTrue(ByteArray<UInt32>() == ByteArray<UInt32>())
        XCTAssertTrue(ByteArray<UInt32>() == ByteArray<UInt32>(rawValue: 0))
        XCTAssertTrue(ByteArray<UInt32>() == ByteArray<UInt32>([]))
        XCTAssertTrue(ByteArray<UInt32>() == ByteArray<UInt32>(repeating: 0xFF, count: 0))
        XCTAssertTrue(ByteArray<UInt32>([1]) == ByteArray<UInt32>(rawValue: 0x0101))

        XCTAssertFalse(ByteArray<UInt32>() != ByteArray<UInt32>())
        XCTAssertTrue(ByteArray<UInt32>() != ByteArray<UInt32>(rawValue: 0x0101))
        XCTAssertTrue(ByteArray<UInt32>(repeating: 0x03, count: 1) != ByteArray<UInt32>([3, 4]))
    }

    func testSubscript() {
        var array = ByteArray<UInt64>([1, 2, 3, 4])
        XCTAssertEqual(array[0], 1)
        XCTAssertEqual(array[3], 4)
        array[0] = 9
        XCTAssertEqual(array[0], 9)
    }

    func testAdding() {
        var array = ByteArray<UInt64>()
        array.append(1)
        array.append(3)
        array.append(5)
        XCTAssertEqual(array.description, "[1, 3, 5]")
        array.insert(2, at: 0)
        XCTAssertEqual(array.description, "[2, 1, 3, 5]")
        array.insert(8, at: 4)
        XCTAssertEqual(array.description, "[2, 1, 3, 5, 8]")

        array = ByteArray<UInt64>([1, 6])
        array.insert(contentsOf: [7, 8, 9], at: 1)
        XCTAssertEqual(array.description, "[1, 7, 8, 9, 6]")
    }

    func testRemove() {
        var array = ByteArray<UInt64>([1, 2, 3, 4, 5, 6, 7])
        XCTAssertEqual(array.description, "[1, 2, 3, 4, 5, 6, 7]")
        XCTAssertEqual(array.removeFirst(), 1)
        XCTAssertEqual(array.description, "[2, 3, 4, 5, 6, 7]")
        XCTAssertEqual(array.rawValue, 0x07_0605_0403_0206)

        XCTAssertEqual(array.removeFirst(), 2)
        XCTAssertEqual(array.description, "[3, 4, 5, 6, 7]")
        XCTAssertEqual(array.rawValue, 0x0706_0504_0305)

        array.removeFirst(3)
        XCTAssertEqual(array.count, 2)
        XCTAssertEqual(array.description, "[6, 7]")
        XCTAssertEqual(array.rawValue, 0x070602)

        array.removeAll()
        XCTAssertEqual(array.description, "[]")
        XCTAssertEqual(array.rawValue, 0)

        array = ByteArray<UInt64>([1, 2, 3, 4, 5, 6, 7])
        XCTAssertEqual(array.removeLast(), 7)
        XCTAssertEqual(array.count, 6)
        XCTAssertEqual(array.rawValue, 0x06_0504_0302_0106)
        array.removeLast(4)
        XCTAssertEqual(array.count, 2)
        XCTAssertEqual(array.rawValue, 0x020102)
        XCTAssertEqual(array.removeLast(), 2)
        XCTAssertEqual(array.removeLast(), 1)
        XCTAssertEqual(array.count, 0)
        XCTAssertEqual(array.rawValue, 0)

        array = ByteArray<UInt64>([1, 2, 3, 4, 5, 6, 7])
        XCTAssertEqual(array.remove(at: 0), 1)
        XCTAssertEqual(array.count, 6)
        XCTAssertEqual(array.description, "[2, 3, 4, 5, 6, 7]")
        XCTAssertEqual(array.rawValue, 0x07_0605_0403_0206)

        XCTAssertEqual(array.remove(at: 3), 5)
        XCTAssertEqual(array.count, 5)
        XCTAssertEqual(array.description, "[2, 3, 4, 6, 7]")
        XCTAssertEqual(array.rawValue, 0x0706_0403_0205)

        XCTAssertEqual(array.remove(at: 4), 7)
        XCTAssertEqual(array.count, 4)
        XCTAssertEqual(array.description, "[2, 3, 4, 6]")
        XCTAssertEqual(array.rawValue, 0x06_0403_0204)

        XCTAssertEqual(array.remove(at: array.index(before: array.endIndex)), 6)
        XCTAssertEqual(array.count, 3)
        XCTAssertEqual(array.description, "[2, 3, 4]")
        XCTAssertEqual(array.rawValue, 0x0403_0203)

        XCTAssertEqual(array.remove(at: array.index(after: array.startIndex)), 3)
        XCTAssertEqual(array.count, 2)
        XCTAssertEqual(array.description, "[2, 4]")
        XCTAssertEqual(array.rawValue, 0x040202)

        XCTAssertEqual(array.remove(at: array.startIndex), 2)
        XCTAssertEqual(array.count, 1)
        XCTAssertEqual(array.description, "[4]")
        XCTAssertEqual(array.rawValue, 0x0401)
    }

    func testPop() {
        var array = ByteArray<UInt64>([1, 2, 3, 4, 5, 6, 7])
        XCTAssertEqual(array.popFirst(), 1)
        XCTAssertEqual(array.rawValue, 0x07_0605_0403_0206)
        XCTAssertEqual(array.popFirst(), 2)
        XCTAssertEqual(array.rawValue, 0x0706_0504_0305)
        XCTAssertEqual(array.popLast(), 7)
        XCTAssertEqual(array.rawValue, 0x06_0504_0304)
        XCTAssertEqual(array.popFirst(), 3)
        XCTAssertEqual(array.rawValue, 0x0605_0403)
        XCTAssertEqual(array.popLast(), 6)
        XCTAssertEqual(array.rawValue, 0x050402)
        XCTAssertEqual(array.popLast(), 5)
        XCTAssertEqual(array.rawValue, 0x0401)
        XCTAssertEqual(array.popFirst(), 4)
        XCTAssertEqual(array.rawValue, 0x0)
        XCTAssertNil(array.popFirst())
        XCTAssertNil(array.popLast())
    }

    func testSequence() {
        var baIterator = ByteArray<UInt64>([1, 2, 3]).makeIterator()

        XCTAssertEqual(baIterator.next(), 1)
        XCTAssertEqual(baIterator.next(), 2)
        XCTAssertEqual(baIterator.next(), 3)
        XCTAssertNil(baIterator.next())
        XCTAssertNil(baIterator.next())

        baIterator = ByteArray<UInt64>().makeIterator()
        XCTAssertNil(baIterator.next())
    }



    func testRangeReplaceable() {
        typealias TestType = ByteArray<UInt64>
        var array = ByteArray<UInt64>([1, 2, 3, 4, 5, 6])

        XCTAssertEqual(array[0...1].description, "[1, 2]")
        XCTAssertEqual(array[array.startIndex..<array.endIndex].description, "[1, 2, 3, 4, 5, 6]")
        XCTAssertEqual(array[..<3].description, "[1, 2, 3]")
        XCTAssertEqual(array[2...].description, "[3, 4, 5, 6]")
        XCTAssertEqual(array[..<0].description, "[]")

        array[1...4] = TestType([0])
        XCTAssertEqual(array, TestType([1, 0, 6]))

        array[1...1] = TestType([7, 8, 9])
        XCTAssertEqual(array, TestType([1, 7, 8, 9, 6]))

        array[..<0] = TestType([2, 3])
        XCTAssertEqual(array, TestType([2, 3, 1, 7, 8, 9, 6]))

        array[...] = TestType()
        XCTAssertEqual(array, TestType())
    }

    static var allTests = [
        ("testInit", testInit),
        ("testCapacity", testCapacity),
        ("testEqual", testEqual),
        ("testSubscript", testSubscript),
        ("testAdding", testAdding),
        ("testRemove", testRemove),
        ("testPop", testPop),
        ("testSequence", testSequence),
        ("testRangeReplaceable", testRangeReplaceable)
    ]
}
