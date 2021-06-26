//
//  ByteArray.swift
//  BABAB
//
//  Created by Simon Evans on 23/06/2021.
//  Copyright © 2017 - 2021 Simon Evans. All rights reserved.
//
//  ByteArray<x> types. Treat UInt8/UInt16/UInt32/UInt64 as arrays of bytes.
//

public struct ByteArray<T: FixedWidthInteger & UnsignedInteger>: RandomAccessCollection, MutableCollection,
                                                                 RangeReplaceableCollection, BidirectionalCollection {

    public typealias Index = Int
    public typealias Element = UInt8
    public typealias SubSequence = Self

    private(set) public var rawValue: T
    var maxElements: Int { Int(T.bitWidth / 8) - 1 }

    /// The position of the first element in a nonempty array. Always zero.
    public var startIndex: Index { 0 }
    /// The array’s “past the end” position—that is, the position one greater than the last valid subscript argument.
    /// This value is always equal to the `bitWidth` of the underlying storage.
    public var endIndex: Index { Int(rawValue & 0xff) }
    /// The number of elements in the array. This is fixed at the `bitWidth` of the underlying storage.
    public var count: Int { Int(rawValue & 0xff) }
    public var capacity: Int { (T.bitWidth / 8) - 1 }
    /// Returns the position immediately before the given index.
    public func index(before index: Index) -> Index {
        return index - 1
    }
    /// Replaces the given index with its successor.
    public func index(after index: Index) -> Index {
        return index + 1
    }

    static public func == (lhs: Self<T>, rhs: Self<T>) -> Bool { lhs.rawValue == rhs.rawValue }
    static public func != (lhs: Self<T>, rhs: Self<T>) -> Bool { lhs.rawValue != rhs.rawValue }

    /// Creates a new, empty array. All the elements are set to zero.
    public init() {
        rawValue = 0
    }

    public init<S: Sequence>(_ sequence: __owned S) where S.Element == Element {
        let maxElements = Int(T.bitWidth / 8) - 1
        var elementCount = 0
        var value = sequence.reduce(into: T(0), {
            elementCount += 1
            guard elementCount <= maxElements else { fatalError("Sequence contains too many elements") }
            $0 |= T($1) << (elementCount * 8)
        })
        value |= T(elementCount)
        rawValue = value
    }

    @inline(__always)
    public init(rawValue: T) {
        self.rawValue = rawValue
    }

    public init(repeating: Element, count: Int) {
        let maxElements = Int(T.bitWidth / 8) - 1
        precondition(0...maxElements ~= count)
        var value = T(0)
        for _ in 0..<count {
            value |= T(repeating)
            value <<= Element.bitWidth
        }
        value |= T(count)
        rawValue = value
    }

    mutating public func append(_ newElement: Element) {
        precondition(count < maxElements)
        let index = count
        incrementCount()
        self[index] = newElement
    }

    mutating public func popFirst() -> Element? {
        guard count > 0 else { return nil }
        let newCount = count - 1
        rawValue >>= 8
        let element = UInt8(truncatingIfNeeded: rawValue)
        maskDataBits(newCount: newCount)
        return element
    }

    mutating public func popLast() -> Element? {
        guard count > 0 else { return nil }
        let newCount = count - 1
        let element = self[newCount]
        maskDataBits(newCount: newCount)
        return element
    }

    mutating public func reserveCapacity(_ capacity: Int) {
        guard capacity <= self.capacity else {
            fatalError("\(capacity) exceeds maximum capacity of ByteArray of \(self.capacity) elements")
        }
    }

    /// Accesses the element at the specified position.
    /// - parameter index: The position of the element to access. index must be greater than or equal to startIndex and
    ///   less than endIndex.
    /// - returns: The bit value of the element.
    /// - precondition: The index is in the valid range of `startIndex` upto but not including`endIndex`.
    public subscript(index: Index) -> Element {
        get {
            precondition(index >= 0)
            precondition(index < count)

            let value = (rawValue >> T((index + 1) * 8)) & 0xff
            return Element(value)
        }

        set(newValue) {
            precondition(index >= 0)
            precondition(index < count)

            let shift = T((index + 1) * 8)
            rawValue |= (T(0xff) << shift)
            rawValue ^= T(~newValue) << shift
        }
    }

    mutating public func removeAll() {
        rawValue = 0
    }

    mutating public func removeAll(keepingCapacity keepCapacity: Bool) {
        rawValue = 0
    }

    @discardableResult
    mutating public func removeFirst() -> UInt8 {
        precondition(count > 0, "No elements available to remove.")
        return popFirst()!
    }

    mutating public func removeFirst(_ elements: Int) {
        if elements == 0 { return }
        precondition(elements >= 0, "Number of elements to remove should be non-negative")
        precondition(elements <= count, "Can't remove more items from a collection than it has")
        let newCount = count - elements
        rawValue >>= (T(elements) * 8)
        maskDataBits(newCount: newCount)
    }

    @discardableResult
    mutating public func removeLast() -> Element {
        precondition(count > 0, "No elements available to remove.")
        return popLast()!
    }

    mutating public func removeLast(_ elements: Int) {
        if elements == 0 { return }
        precondition(elements >= 0, "Number of elements to remove should be non-negative")
        precondition(elements <= count, "Can't remove more items from a collection than it has")
        maskDataBits(newCount: count - elements)
    }

    mutating public func insert(_ newElement: Element, at index: Int) {
        precondition(index >= 0, "Index of element to add should be non-negative")
        precondition(index <= endIndex, "Array index is out of range")
        precondition(count < maxElements, "Can't insert any more elements")

        let shift = T(index + 1) * 8

        let upperMask = (T.max << shift)
        let lowerMask = ~upperMask

        let lowerBits = rawValue & lowerMask
        let upperBits = ((rawValue & upperMask) << 8)

        rawValue = lowerBits | (T(newElement) << shift) | upperBits
        incrementCount()
    }

    @discardableResult
    mutating public func remove(at index: Int) -> Element {
        precondition(index >= 0, "Index of element to remove should be non-negative")
        precondition(index < count, "Can't remove more items from a collection than it has")

        let element = self[index]
        let shift = T(index + 1) * 8
        let upperMask = (T.max << shift)
        let lowerMask = ~upperMask

        let upperBits = (rawValue >> 8) & upperMask
        let lowerBits = rawValue & lowerMask

        rawValue = upperBits | lowerBits
        rawValue -= 1
        return element
    }

    // Mask off the data bits, excluding the count bits with get set to 0, then set the
    // count to the new value.
    mutating private func maskDataBits(newCount: Int) {
        let mask = (rawValue.maskFrom(bitCount: newCount * 8) << 8)
        rawValue &= mask
        rawValue |= T(newCount)
    }

    mutating private func incrementCount() {
        rawValue += 1
    }
}

extension ByteArray: CustomStringConvertible {
    public var description: String {
        return "[" + self.map { "\($0)" }.joined(separator: ", ") + "]"
    }
}

extension ByteArray: CustomDebugStringConvertible {
    public var debugDescription: String { rawValue.hex(separators: true) }
}

extension ByteArray: Sequence {
    // public typealias Iterator = ByteArrayIterator

    public func makeIterator() -> ByteArrayIterator<T> {
        return ByteArrayIterator(array: self)
    }
}

public struct ByteArrayIterator<T: FixedWidthInteger & UnsignedInteger>: IteratorProtocol {
    private var array: ByteArray<T>
    public typealias Element = UInt8

    public init(array: ByteArray<T>) {
        self.array = array
    }

    mutating public func next() -> Element? {
        return array.popFirst()
    }
}
