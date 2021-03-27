//
//  BitmapAllocatorTests.swift
//  BABABTests
//
//  Created by Simon Evans on 27/03/2021.
//

import BABAB
import XCTest

final class BitmapAllocatorTests: XCTestCase {

    func testBitmapAllocator() {
        var allocator = BitmapAllocator<UInt8>()
        XCTAssertEqual(allocator.entryCount, 8)
        XCTAssertEqual(allocator.freeEntryCount, 8)
        XCTAssertEqual(allocator.hasSpace, true)
        XCTAssertEqual("\(allocator)", "11111111")

        XCTAssertEqual(allocator.allocate(), 0)
        XCTAssertEqual(allocator.allocate(), 1)
        XCTAssertEqual(allocator.allocate(), 2)
        XCTAssertEqual(allocator.freeEntryCount, 5)
        XCTAssertEqual("\(allocator)", "11111000")

        allocator.free(entry: 0)
        XCTAssertEqual(allocator.freeEntryCount, 6)
        XCTAssertEqual("\(allocator)", "11111001")

        for _ in 1...6 {
            XCTAssertNotNil(allocator.allocate())
        }
        // All allocated now
        XCTAssertNil(allocator.allocate())
        XCTAssertEqual(allocator.freeEntryCount, 0)
        XCTAssertEqual("\(allocator)", "00000000")
    }

    func testDoubleBitmapAllocator() {
        var allocator = DoubleBitmapAllocator<UInt16>()
        XCTAssertEqual(allocator.entryCount, 32)
        XCTAssertEqual(allocator.freeEntryCount, 32)
        XCTAssertEqual(allocator.hasSpace, true)
        XCTAssertEqual("\(allocator)", "1111111111111111-1111111111111111")

        XCTAssertEqual(allocator.allocate(), 0)
        XCTAssertEqual(allocator.allocate(), 1)
        XCTAssertEqual(allocator.allocate(), 2)
        XCTAssertEqual(allocator.freeEntryCount, 29)
        XCTAssertEqual("\(allocator)", "1111111111111111-1111111111111000")

        for _ in 1...16 {
            XCTAssertNotNil(allocator.allocate())
        }
        XCTAssertEqual("\(allocator)", "1111111111111000-0000000000000000")
        XCTAssertEqual(allocator.freeEntryCount, 13)

        allocator.free(entry: 3)
        allocator.free(entry: 12)
        XCTAssertEqual("\(allocator)", "1111111111111000-0001000000001000")
        XCTAssertEqual(allocator.freeEntryCount, 15)

        for _ in 1...15 {
            XCTAssertNotNil(allocator.allocate())
        }
        // All allocated now
        XCTAssertNil(allocator.allocate())
        XCTAssertEqual(allocator.freeEntryCount, 0)
        XCTAssertEqual("\(allocator)", "0000000000000000-0000000000000000")
        XCTAssertFalse(allocator.hasSpace)

        allocator.free(entry: 30)
        XCTAssertEqual("\(allocator)", "0100000000000000-0000000000000000")
        XCTAssertTrue(allocator.hasSpace)
    }

    static var allTests = [
        ("testBitmapAllocator", testBitmapAllocator),
        ("testDoubleBitmapAllocator", testDoubleBitmapAllocator),
    ]
}
