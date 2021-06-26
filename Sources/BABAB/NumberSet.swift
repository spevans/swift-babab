//
//  NumberSet.swift
//  BABAB
//
//  Created by Simon Evans on 25/06/2021.
//  Copyright © 2021 Simon Evans. All rights reserved.
//

public struct NumberSet<T: FixedWidthInteger & UnsignedInteger>: SetAlgebra {
    public typealias Element = Int

    private(set) public var rawValue: T
    public var isEmpty: Bool { rawValue == 0 }
    public var count: Int { rawValue.nonzeroBitCount }
    public var capacity: Int { T.bitWidth }
    public var first: Int? { rawValue.lowestBitSet }

    @inline(__always)
    public init() {
        self.rawValue = 0
    }

    public init<S: Sequence>(_ sequence: __owned S) where S.Element == Element {
        self.rawValue = sequence.reduce(into: T(0), { $0 |= T(1 << $1) })
    }

    @inline(__always)
    public init(rawValue: T) {
        self.rawValue = rawValue
    }

    @discardableResult
    mutating public func insert(_ newMember: __owned Int) -> (inserted: Bool, memberAfterInsert: Int) {
        if rawValue.bit(newMember) { return (false, newMember) }

        rawValue.bit(newMember, true)
        return (true, newMember)
    }

    mutating public func update(with newMember: __owned Int) -> Int? {
        if rawValue.bit(newMember) { return newMember }

        rawValue.bit(newMember, true)
        return nil
    }

    mutating public func remove(_ member: Int) -> Int? {
        guard rawValue.bit(member) else { return nil }
        rawValue.bit(member, false)
        return member
    }

    @inline(__always)
    public func contains(_ member: Int) -> Bool { rawValue.bit(member) }

    @inline(__always)
    public func min() -> Int? { self.rawValue.lowestBitSet }

    @inline(__always)
    public func max() -> Int? { self.rawValue.highestBitSet }

    @inline(__always)
    public func isDisjoint(with other: Self) -> Bool {
        return self.rawValue & other.rawValue == 0
    }

    @inline(__always)
    public func subtracting(_ other: Self) -> Self {
        return Self(rawValue: self.rawValue & ~other.rawValue)
    }

    @inline(__always)
    __consuming public func union(_ other: __owned Self) -> Self {
        return Self(rawValue: self.rawValue | other.rawValue)
    }

    @inline(__always)
    __consuming public func intersection(_ other: Self) -> Self {
        return Self(rawValue: self.rawValue & other.rawValue)
    }

    @inline(__always)
    __consuming public func symmetricDifference(_ other: __owned Self) -> Self {
        return Self(rawValue: self.rawValue ^ other.rawValue)
    }

    @inline(__always)
    mutating public func subtract(_ other: Self) {
        self.rawValue &= ~other.rawValue
    }

    @inline(__always)
    mutating public func formUnion(_ other: __owned Self) {
        self.rawValue |= other.rawValue
    }

    @inline(__always)
    mutating public func formIntersection(_ other: Self) {
        self.rawValue &= other.rawValue
    }

    @inline(__always)
    mutating public func formSymmetricDifference(_ other: __owned Self) {
        self.rawValue ^= other.rawValue
    }
}

extension NumberSet {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}

extension NumberSet: Sequence {
    public typealias Iterator = NumberSetIterator

    public func makeIterator() -> NumberSetIterator<T> {
        return NumberSetIterator<T>(rawValue: rawValue)
    }
}

extension NumberSet: CustomStringConvertible {
    public var description: String {
        return "[" + self.map { "\($0)" }.joined(separator: ", ") + "]"
    }
}

public struct NumberSetIterator<T: FixedWidthInteger & UnsignedInteger>: IteratorProtocol {
    private var rawValue: T
    public typealias Element = Int

    public init(rawValue: T) {
        self.rawValue = rawValue
    }

    public mutating func next() -> Element? {
        return rawValue.clearLowestBitSet()
    }
}
