//
//  NumberSet.swift
//  BABAB
//
//  Created by Simon Evans on 25/06/2021.
//  Copyright © 2021 Simon Evans. All rights reserved.
//

/// `NumberSet` uses a specified unsigned `FixedWidthInteger` as the storage for a Set containing the numbers
/// 0...`bitWidth`. eg a `UInt8` can contain the numbers `0...7`, a `UInt64` can store `0...63`.
/// The storage uses a bit per number where bit[`x`] is used to store `x`. This gives an ordering
/// of the set from lowest to highest.
/// The `rawValue` property represents the underlying storage and can be easily interpreted.
/// ```
/// rawValue = 0b1001_0001  [0, 4, 7]
/// ```
public struct NumberSet<T: FixedWidthInteger & UnsignedInteger>: SetAlgebra {
    /// The elements stored in the `NumberSet` are of type `Int`.
    public typealias Element = Int

    /// The underlying storage. Read only.
    private(set) public var rawValue: T
    /// A Boolean value that indicates whether the set is empty.
    public var isEmpty: Bool { rawValue == 0 }
    /// The number of elements in the set.
    public var count: Int { rawValue.nonzeroBitCount }
    /// The total number of elements that the set can contain without allocating new storage.
    public var capacity: Int { T.bitWidth }
    /// The first element of the collection.
    ///
    /// If the collection is empty, the value of this property is `nil`.
    public var first: Int? { rawValue.lowestBitSet }

    /// Creates an empty set.
    @inline(__always)
    public init() {
        self.rawValue = 0
    }

    /// Creates a new set from a finite sequence of items.
    /// - parameter sequence: The elements to use as members of the new set.
    public init<S: Sequence>(_ sequence: __owned S) where S.Element == Element {
        self.rawValue = sequence.reduce(into: T(0), { $0 |= T(1 << T($1)) })
    }

    /// Create a new set from a literal value.
    ///
    /// Use this initialiser to create a new set. Member `x` corresponds to bit x. To create a set
    /// containing the numbers 1 and 5:
    /// ```
    /// let numberSet = Set<UInt8>(rawValue: 0b0010_0010)
    /// print(numberSet)
    /// // prints [1, 5]
    /// ```
    /// - parameter rawValue: A literal with the members of the new set represented by the appropaite bit being set.
    @inline(__always)
    public init(rawValue: T) {
        self.rawValue = rawValue
    }

    /// Inserts the given element in the set if it is not already present.
    ///
    /// - parameter newMember: An element to insert into the set.
    /// - returns: (true, newMember) if newMember was not contained in the set. If an element equal to
    /// newMember was already contained in the set, the method returns (false, oldMember), where oldMember
    /// is the element that was equal to newMember.
    /// In some cases, oldMember may be distinguishable from newMember by identity comparison or some other means.
    @discardableResult
    mutating public func insert(_ newMember: __owned Int) -> (inserted: Bool, memberAfterInsert: Int) {
        if rawValue.bit(newMember) { return (false, newMember) }

        rawValue.bit(newMember, true)
        return (true, newMember)
    }

    /// Inserts the given element into the set unconditionally.
    ///
    /// - parameter newMember: An element to insert into the set.
    /// - returns: An element equal to newMember if the set already contained such a member; otherwise, `nil`.
    /// In some cases, the returned element may be distinguishable from newMember by identity comparison or some
    /// other means.
    mutating public func update(with newMember: __owned Int) -> Int? {
        if rawValue.bit(newMember) { return newMember }

        rawValue.bit(newMember, true)
        return nil
    }

    /// Removes the specified element from the set.
    ///
    /// - parameter member: The element to remove from the set.
    /// - returns: The value of the member parameter if it was a member of the set; otherwise, `nil`.
    mutating public func remove(_ member: Int) -> Int? {
        guard rawValue.bit(member) else { return nil }
        rawValue.bit(member, false)
        return member
    }

    /// Removes the first element of the set.
    ///
    /// A `NumberSet` is not an ordered collection so  the “first” element may is always the element with the lowest
    /// numeric value. The set must not be empty.
    /// Complexity: O(1).
    /// - returns: A member of the set. This memeber is the element with the lowest numeric value.
    @discardableResult
    mutating public func removeFirst() -> Int {
        return rawValue.clearLowestBitSet()!
    }

    /// Removes the element at the given index of the set.
    ///
    /// - parameter position: The index of the member to remove. position must be a valid index of the set,
    /// and must not be equal to the set’s end index.
    /// - returns: The element that was removed from the set.
    @discardableResult
    mutating public func remove(at position: Int) -> Int {
        precondition(position >= 0)
        precondition(position < T.bitWidth)
        var position = position
        for bitIndex in 0..<rawValue.bitWidth {
            let mask = T(1 << bitIndex)
            if rawValue & mask != 0 {
                if position == 0 {
                    rawValue &= ~mask
                    return bitIndex
                }
                position -= 1
            }
        }
        fatalError("Index out of bounds")
    }

    /// Removes all members from the set.
    ///
    /// - parameter keepingCapacity:This parameter is ignore as the underlying storage is fixed.
    mutating public func removeAll(keepingCapacity keepCapacity: Bool = false) {
        rawValue = 0
    }

    /// Returns a Boolean value that indicates whether the given element exists in the set.
    /// - parameter member: An element to look for in the set.
    /// - returns: `true` if member exists in the set; otherwise, `false`.
    @inline(__always)
    public func contains(_ member: Int) -> Bool { rawValue.bit(member) }

    /// Returns the minimum element in the sequence.
    /// - returns: The sequence’s minimum element. If the sequence has no elements, returns `nil`.
    @inline(__always)
    public func min() -> Int? { self.rawValue.lowestBitSet }

    /// Returns the maximum element in the sequence.
    /// - returns: The sequence’s maximum element. If the sequence has no elements, returns `nil`.
    @inline(__always)
    public func max() -> Int? { self.rawValue.highestBitSet }

    /// Returns a Boolean value that indicates whether this set has no members in common with the given set.
    ///
    /// - parameter other: Another `NumberSet` of the same type as the current `NumberSet`.
    /// - returns: `true` if the set has no elements in common with other; otherwise, `false`.
    @inline(__always)
    public func isDisjoint(with other: Self) -> Bool {
        return self.rawValue & other.rawValue == 0
    }

    /// Returns a new set containing the elements of this set that do not occur in the given set.
    ///
    /// - parameter other: Another `NumberSet` of the same type as the current `NumberSet`.
    /// - returns: A new set.
    @inline(__always)
    public func subtracting(_ other: Self) -> Self {
        return Self(rawValue: self.rawValue & ~other.rawValue)
    }

    /// Returns a new set with the elements of both this and the given set.
    ///
    /// - parameter other: Another `NumberSet` of the same type as the current `NumberSet`.
    /// - returns: A new set with the unique elements of this set and `other`.
    @inline(__always)
    __consuming public func union(_ other: __owned Self) -> Self {
        return Self(rawValue: self.rawValue | other.rawValue)
    }

    /// Returns a new set with the elements that are common to both this set and the given set.
    ///
    /// - parameter other: Another `NumberSet` of the same type as the current `NumberSet`.
    /// - returns: A new set.
    @inline(__always)
    __consuming public func intersection(_ other: Self) -> Self {
        return Self(rawValue: self.rawValue & other.rawValue)
    }

    /// Returns a new set with the elements that are either in this set or in the given set, but not in both.
    ///
    /// - parameter other: Another `NumberSet` of the same type as the current `NumberSet`.
    /// - returns: A new set.
    @inline(__always)
    __consuming public func symmetricDifference(_ other: __owned Self) -> Self {
        return Self(rawValue: self.rawValue ^ other.rawValue)
    }

    /// Removes the elements of the given set from this set.
    ///
    /// - parameter other: Another `NumberSet` of the same type as the current `NumberSet`.
    @inline(__always)
    mutating public func subtract(_ other: Self) {
        self.rawValue &= ~other.rawValue
    }

    /// Adds the elements of the given set to the set.
    ///
    /// - parameter other: Another `NumberSet` of the same type as the current `NumberSet`.
    @inline(__always)
    mutating public func formUnion(_ other: __owned Self) {
        self.rawValue |= other.rawValue
    }

    /// Inserts the elements of the given sequence into the set.
    ///
    /// - parameter other: A sequence of elements. `other` must be finite.
    public mutating func formUnion<S>(_ other: S) where Element == S.Element, S: Sequence {
        self.rawValue |= other.reduce(into: T(0), { $0 |= T(1 << T($1)) })
    }

    /// Removes the elements of this set that aren’t also in the given set.
    ///
    /// - parameter other: Another `NumberSet` of the same type as the current `NumberSet`.
    @inline(__always)
    mutating public func formIntersection(_ other: Self) {
        self.rawValue &= other.rawValue
    }

    /// Removes the elements of the set that are also in the given set and adds the members of the given set that are
    /// not already in the set.
    ///
    /// - parameter other: Another `NumberSet` of the same type as the current `NumberSet`.
    @inline(__always)
    mutating public func formSymmetricDifference(_ other: __owned Self) {
        self.rawValue ^= other.rawValue
    }
}

extension NumberSet {
    /// Returns a Boolean value indicating whether two sets have equal elements.
    /// - parameter lhs: A `NumberSet`
    /// - parameter rhs: Another `NumberSet` of the same type.
    /// - returns: `true` if the `lhs` and `rhs` have the same elements; otherwise, `false`.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}

extension NumberSet: Sequence {
    /// Returns an iterator over the members of the set..
    public func makeIterator() -> NumberSetIterator<T> {
        return NumberSetIterator<T>(rawValue: rawValue)
    }
}

extension NumberSet: CustomStringConvertible {
    /// A string that represents the contents of the set.
    public var description: String {
        return "[" + self.map { "\($0)" }.joined(separator: ", ") + "]"
    }
}

/// An `Iterator` that return the elements of a `NumberSet`.
public struct NumberSetIterator<T: FixedWidthInteger & UnsignedInteger>: IteratorProtocol {
    private var rawValue: T
    /// The elements returned by the `NumberSetIterator` are of type `Int`.
    public typealias Element = Int

    /// Creates a new iterator from the specified value.
    ///
    /// - parameter rawValue: An unsigned `FixedWidhtInteger` with a bit represeting each element that will
    /// be returned by the iterator.
    public init(rawValue: T) {
        self.rawValue = rawValue
    }

    /// Advances to the next element and returns it, or `nil` if no next element exists.
    ///
    /// The next element returned is represented by the lowest bit that is set and is cleared before returning.
    /// Once all of the bits are clear then all subsequent calls return `nil`.
    public mutating func next() -> Element? {
        return rawValue.clearLowestBitSet()
    }
}
