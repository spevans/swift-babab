//
//  NumberSetTests.swift
//  BABABTests
//
//  Created by Simon Evans on 26/06/2021.
//

import BABAB
import XCTest

class NumberSetTests: XCTestCase {
    let set0 = NumberSet<UInt16>()
    let set1 = NumberSet<UInt16>([1, 2, 3])
    let set2 = NumberSet<UInt16>([3, 4, 5])
    let set3 = NumberSet<UInt16>([7, 8, 9])
    let set4 = NumberSet<UInt16>([0, 1, 2, 3, 4, 5, 6])
    let set5 = NumberSet<UInt16>([3])
    let set6 = NumberSet<UInt16>([1, 2, 3, 4])
    let setAll = NumberSet<UInt16>(rawValue: UInt16.max)

    func testInit() {
        var ns = NumberSet<UInt8>()
        XCTAssertTrue(ns.isEmpty)
        XCTAssertEqual(ns.description, "[]")

        XCTAssertFalse(ns.contains(0))
        XCTAssertFalse(ns.contains(7))
        ns.insert(0)
        ns.insert(3)
        ns.insert(6)
        XCTAssertTrue(ns.contains(0))
        XCTAssertFalse(ns.contains(1))
        XCTAssertEqual(ns.rawValue, 0b0100_1001)
        XCTAssertEqual(ns.description, "[0, 3, 6]")

        ns = NumberSet<UInt8>(rawValue: 0b1010_1010)
        XCTAssertEqual(ns.description, "[1, 3, 5, 7]")

        XCTAssertEqual(NumberSet<UInt32>([1, 3, 5, 7]).rawValue, 0b1010_1010)
    }

    func testProperties() {
        // .isEmpty
        XCTAssertTrue(self.set0.isEmpty)
        XCTAssertFalse(self.set1.isEmpty)

        // .count
        XCTAssertEqual(self.set0.count, 0)
        XCTAssertEqual(self.set1.count, 3)
        XCTAssertEqual(self.setAll.count, 16)

        // .capacity
        XCTAssertEqual(self.set0.capacity, 16)
        XCTAssertEqual(self.setAll.capacity, 16)

        // .first
        XCTAssertNil(self.set0.first)
        XCTAssertEqual(self.set1.first, 1)
        XCTAssertEqual(self.setAll.first, 0)

        // !=
        XCTAssertNotEqual(self.set0, self.set1)
        XCTAssertNotEqual(self.set0, self.setAll)
    }

    func testMinMax() {
        XCTAssertNil(self.set0.min())
        XCTAssertNil(self.set0.max())

        XCTAssertEqual(self.set5.min(), 3)
        XCTAssertEqual(self.set5.max(), 3)

        XCTAssertEqual(self.setAll.min(), 0)
        XCTAssertEqual(self.setAll.max(), 15)
    }

    func testUpdates() {
        var ns = NumberSet<UInt>()

        // Insert '0', check before and after insert.
        XCTAssertFalse(ns.contains(0))
        var (inserted, afterInsert) = ns.insert(0)
        XCTAssertTrue(inserted)
        XCTAssertTrue(ns.contains(0))
        XCTAssertEqual(afterInsert, 0)
        XCTAssertFalse(ns.isEmpty)

        // Insert '0', check it was already inserted.
        (inserted, afterInsert) = ns.insert(0)
        XCTAssertFalse(inserted)
        XCTAssertEqual(afterInsert, 0)
        XCTAssertTrue(ns.contains(0))

        // Check removal of non-existant member returns nil.
        XCTAssertFalse(ns.contains(1))
        XCTAssertNil(ns.remove(1))

        // Check removal of existing member returns the member.
        XCTAssertEqual(ns.remove(0), 0)
        XCTAssertFalse(ns.contains(0))
        XCTAssertTrue(ns.isEmpty)

        // Check removal of already removed member returns nil.
        XCTAssertNil(ns.remove(0))

        XCTAssertNil(ns.update(with: 3))
        XCTAssertEqual(ns.update(with: 3), 3)

        var cns = Set<Character>()
        XCTAssertNil(cns.update(with: Character("A")))
        XCTAssertEqual(cns.update(with: Character("A")), Character("A"))
    }

    func testUnion() {
        XCTAssertEqual(self.set1.union(self.set0), self.set1)
        XCTAssertEqual(self.set0.union(self.set1), self.set1)
        XCTAssertEqual(self.set1.union(self.setAll), self.setAll)
        XCTAssertEqual(self.set1.union(self.set2), [1, 2, 3, 4, 5])
        XCTAssertEqual(self.set2.union(self.set3), [3, 4, 5, 7, 8, 9])

        do {
            var set1Copy = self.set1
            set1Copy.formUnion(self.set0)
            XCTAssertEqual(set1Copy, self.set1)
        }

        do {
            var set0Copy = self.set0
            set0Copy.formUnion(self.set1)
            XCTAssertEqual(set0Copy, self.set1)
        }

        do {
            var set1Copy = self.set1
            set1Copy.formUnion(self.set2)
            XCTAssertEqual(set1Copy, [1, 2, 3, 4, 5])
        }

        do {
            var set2Copy = self.set2
            set2Copy.formUnion(self.set3)
            XCTAssertEqual(set2Copy, [3, 4, 5, 7, 8, 9])
        }
    }

    func testDisjoint() {
        XCTAssertTrue(self.set0.isDisjoint(with: self.set0))
        XCTAssertFalse(self.set1.isDisjoint(with: self.set1))
        XCTAssertFalse(self.set1.isDisjoint(with: self.set2))
        XCTAssertTrue(self.set1.isDisjoint(with: self.set3))
    }

    func testIntersection() {
        XCTAssertEqual(self.set0.intersection(self.set0), self.set0)
        XCTAssertEqual(self.set1.intersection(self.set1), self.set1)
        XCTAssertEqual(self.set1.intersection(self.set2), self.set5)
        XCTAssertEqual(self.set0.intersection(self.set1), self.set0)
        XCTAssertEqual(self.set1.intersection(self.set3), self.set0)

        do {
            var set0Copy = self.set0
            set0Copy.formIntersection(self.set0)
            XCTAssertEqual(set0Copy, self.set0)
        }
        do {
            var set1Copy = self.set1
            set1Copy.formIntersection(self.set1)
            XCTAssertEqual(set1Copy, self.set1)
        }
        do {
            var set1Copy = self.set1
            set1Copy.formIntersection(self.set2)
            XCTAssertEqual(set1Copy, self.set5)
        }
        do {
            var set0Copy = self.set0
            set0Copy.formIntersection(self.set1)
            XCTAssertEqual(set0Copy, self.set0)
        }
        do {
            var set1Copy = self.set1
            set1Copy.formIntersection(self.set3)
            XCTAssertEqual(set1Copy, self.set0)
        }
    }

    func testSubtract() {
        XCTAssertEqual(self.set0.subtracting(self.set0), self.set0)
        XCTAssertEqual(self.set1.subtracting(self.set1), self.set0)
        XCTAssertEqual(self.set1.subtracting(self.set0), self.set1)
        XCTAssertEqual(self.set1.subtracting(self.set2), [1, 2])
        XCTAssertEqual(self.set2.subtracting(self.set1), [4, 5])
        XCTAssertEqual(self.set4.subtracting(self.set1), [0, 4, 5, 6])

        do {
            var set0Copy = self.set0
            set0Copy.subtract(self.set0)
            XCTAssertEqual(set0Copy, self.set0)
        }
        do {
            var set1Copy = self.set1
            set1Copy.subtract(self.set1)
            XCTAssertEqual(set1Copy, self.set0)
        }
        do {
            var set1Copy = self.set1
            set1Copy.subtract(self.set0)
            XCTAssertEqual(set1Copy, self.set1)
        }
        do {
            var set1Copy = self.set1
            set1Copy.subtract(self.set2)
            XCTAssertEqual(set1Copy, [1, 2])
        }
        do {
            var set2Copy = self.set2
            set2Copy.subtract(self.set1)
            XCTAssertEqual(set2Copy, [4, 5])
        }
        do {
            var set4Copy = self.set4
            set4Copy.subtract(self.set1)
            XCTAssertEqual(set4Copy, [0, 4, 5, 6])
        }
    }

    func testSymmetricDifference() {
        XCTAssertEqual(self.set0.symmetricDifference(self.set0), self.set0)
        XCTAssertEqual(self.set0.symmetricDifference(self.set1), self.set1)
        XCTAssertEqual(self.set1.symmetricDifference(self.set2), [1, 2, 4, 5])
        XCTAssertEqual(self.set1.symmetricDifference(self.set3), [1, 2, 3, 7, 8, 9])
        XCTAssertEqual(self.set1.symmetricDifference(self.set6), [4])

        do {
            var set0Copy = self.set0
            set0Copy.formSymmetricDifference(self.set0)
            XCTAssertEqual(set0Copy, self.set0)
        }
        do {
            var set0Copy = self.set0
            set0Copy.formSymmetricDifference(self.set1)
            XCTAssertEqual(set0Copy, self.set1)
        }
        do {
            var set1Copy = self.set1
            set1Copy.formSymmetricDifference(self.set2)
            XCTAssertEqual(set1Copy, [1, 2, 4, 5])
        }
        do {
            var set1Copy = self.set1
            set1Copy.formSymmetricDifference(self.set3)
            XCTAssertEqual(set1Copy, [1, 2, 3, 7, 8, 9])
        }
        do {
            var set1Copy = self.set1
            set1Copy.formSymmetricDifference(self.set6)
            XCTAssertEqual(set1Copy, [4])
        }
    }

    static var allTests = [
        ("testInit", testInit),
        ("testProperties", testProperties),
        ("testMinMax", testMinMax),
        ("testUpdates", testUpdates),
        ("testUnion", testUnion),
        ("testDisjoint", testDisjoint),
        ("testIntersection", testIntersection),
        ("testSubtract", testSubtract),
        ("testSymmetricDifference", testSymmetricDifference),
    ]
}
