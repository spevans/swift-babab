//
// BitArray.swift
// BABAB
//
// Created by Simon Evans on 28/03/2017.
// Copyright © 2017 - 2021 Simon Evans. All rights reserved.
//
// BitArray<x> types. Treat UInt8/UInt16/UInt32/UInt64 as arrays of bits.
//

/// A `BitArray` with 8 elements.
public typealias BitArray8 = BitArray<UInt8>
/// A `BitArray` with 16 elements.
public typealias BitArray16 = BitArray<UInt16>
/// A `BitArray` with 32 elements.
public typealias BitArray32 = BitArray<UInt32>
/// A `BitArray` with 64 elements.
public typealias BitArray64 = BitArray<UInt64>

/// A type that uses a fixed width, unsigned integer as storage for an array of bits. The number of bits is fixed and by default are set to zero.
/// ```
/// Using fixed width arrays of bits can be used to implement bitfield like data structures.
/// As an example, consider an 8-bit value that represents the following data
///
/// +---------+---------+-------+-------+
/// | b7:4    | b2:3    | b1    | b0    |
/// | Value 2 | Value 1 | Flag2 | Flag1 |
/// +---------+---------+-------+-------+
///
/// struct Data {
///     private var bits: BitArray8
///
///     var flag1: Bool {
///         get { Bool(bits[0]) }
///         set { bits[0] = Int(newValue) }
///
///     var flag2: Bool { bits[1] }
///
///     var value1: Int { bits[2...3] }
///
///     var value2: Int {
///         get { bits[4...7] }
///         set { buts[4...7] = newValue }
///     }
/// }
/// ```
public struct BitArray<T: FixedWidthInteger & UnsignedInteger>: RandomAccessCollection, MutableCollection,
    CustomStringConvertible
{
    /// The `Index` type for a `BitArray` is an `Int`.
    public typealias Index = Int
    /// The `Element` type for a `BitArry` is an `Int` of value zero or one.
    public typealias Element = Int
    /// A sequence that represents a contiguous subrange of the collection’s elements.
    public typealias SubSequence = Self
    /// The underlying storage.
    public private(set) var rawValue: T

    /// The position of the first element in a nonempty array. Always zero.
    public var startIndex: Self.Index { 0 }
    /// The array’s “past the end” position—that is, the position one greater than the last valid subscript argument.
    /// This value is always equal to the `bitWidth` of the underlying storage.
    public var endIndex: Self.Index { rawValue.bitWidth }
    /// The number of elements in the array. This is fixed at the `bitWidth` of the underlying storage.
    public var count: Int { rawValue.bitWidth }
    /// Returns the position immediately before the given index.
    public func index(before i: Self.Index) -> Self.Index {
        return i - 1
    }
    /// Replaces the given index with its successor.
    public func index(after i: Self.Index) -> Self.Index {
        return i + 1
    }
    /// A textual representation of the array and its elements.
    public var description: String {
        let num = String(rawValue, radix: 2)
        let width = T.bitWidth
        return String(repeating: "0", count: width - num.count) + num
    }

    /// Creates a new, empty array. All the elements are set to zero.
    public init() {
        rawValue = 0
    }

    /// Create a new array initiialising the underlying storage to the supplied value.
    /// - parameter rawValue: The initial value to set the storage to.
    public init(_ rawValue: Int) {
        self.rawValue = T(rawValue)
    }

    /// Create a new array initiialising the underlying storage to the supplied value.
    /// - parameter rawValue: The initial value to set the storage to.
    public init(_ rawValue: UInt) {
        self.rawValue = T(rawValue)
    }

    /// Create a new array initiialising the underlying storage to the supplied value.
    /// - parameter rawValue: The initial value to set the storage to.
    public init(_ rawValue: T) {
        self.rawValue = rawValue
    }

    /// Accesses the element at the specified position.
    /// - parameter index:The position of the element to access. index must be greater than or equal to startIndex and less than endIndex.
    /// - returns: The bit value of the element.
    /// - precondition: The index is in the valid range of `startIndex` upto but not including`endIndex`.
    public subscript(index: Index) -> Int {
        get {
            precondition(index >= 0)
            precondition(index < T.bitWidth)

            return (rawValue & (T(1) << index) == 0) ? 0 : 1
        }

        set(newValue) {
            precondition(index >= 0)
            precondition(index < T.bitWidth)
            precondition(newValue == 0 || newValue == 1)

            let mask: T = 1 << index
            if newValue == 1 {
                rawValue |= mask
            } else {
                rawValue &= ~mask
            }
        }
    }

    private func maskFrom(bitCount: Int) -> T {
        if bitCount == T.bitWidth {
            return T.max
        } else {
            return T(1 << T(bitCount)) - T(1)
        }
    }

    /// A subrange of the array's elements.
    /// ```
    /// The result is a full-width array with the elements in the given range
    /// in the lowest bits of the returned array.
    /// If the original array
    ///
    /// let a = BitArray16(0x0A50) // 0000101001010000
    /// let b = a[8..<16]          // 0000000000001010
    ///
    /// ```
    /// - parameter bounds: A range of integers. The bounds of the range must be valid indices of the array.
    /// - returns: A new array with the selected elements.
    /// - precondition: `bounds.lowerBound` >= 0.
    /// - precondition: `bounds.upperBound`<= The number of elements in the array.
    public subscript(bounds: Range<Index>) -> SubSequence {
        get {
            precondition(bounds.lowerBound >= 0)
            precondition(bounds.upperBound <= T.bitWidth)
            let bitCount = bounds.upperBound - bounds.lowerBound
            guard bitCount > 0 else { return Self() }
            let mask = maskFrom(bitCount: bitCount)
            let newRawValue = (self.rawValue >> bounds.lowerBound) & mask
            return Self(newRawValue)
        }
        set {
            precondition(bounds.lowerBound >= 0)
            precondition(bounds.upperBound <= T.bitWidth)
            let bitCount = bounds.upperBound - bounds.lowerBound
            guard bitCount > 0 else { return }
            let mask = maskFrom(bitCount: bitCount)

            let value = (newValue.rawValue & mask) << bounds.lowerBound
            self.rawValue &= ~(mask << bounds.lowerBound)
            self.rawValue |= value
        }
    }

    /// The integer value representing the array's elements.
    /// ```
    /// The result is the integer value of the selected elements (bits) of the array.
    ///
    /// let a = BitArray16(0x0A50) // 0000101001010000
    /// let b = a[8..<16]          // b = 0xA
    /// print(b)                   // 10
    /// ```
    /// - parameter bounds: A range of integers. The bounds of the range must be valid indices of the array.
    /// - returns: An integer representation of the selected elements.
    /// - precondition: `bounds.lowerBound` >= 0.
    /// - precondition: `bounds.upperBound`< The number of elements in the array.
    public subscript(bounds: ClosedRange<Index>) -> T {
        get {
            precondition(bounds.lowerBound >= 0)
            precondition(bounds.upperBound < T.bitWidth)
            let bitCount = 1 + bounds.upperBound - bounds.lowerBound
            let mask = maskFrom(bitCount: bitCount)
            return (self.rawValue >> bounds.lowerBound) & mask
        }
        set {
            precondition(bounds.lowerBound >= 0)
            precondition(bounds.upperBound < T.bitWidth)

            let bitCount = 1 + bounds.upperBound - bounds.lowerBound
            guard bitCount > 0 else { return }

            let mask = maskFrom(bitCount: bitCount)
            let value = (newValue & mask) << bounds.lowerBound
            self.rawValue &= ~(mask << bounds.lowerBound)
            self.rawValue |= value
        }
    }
}
