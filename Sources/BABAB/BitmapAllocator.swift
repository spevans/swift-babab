//
//  BitmapAllocator.swift
//  BABAB
//
//  Created by Simon Evans on 03/11/2020.
//  Copyright © 2020 - 2021 Simon Evans. All rights reserved.
//
//  Simple allocators that use a bitmap in a fixed width integer to store free/allocated blocks.
//

/// A type that allows for allocating and deallocating entries using an unsigned fixed width integer to hold the allocated entries.
/// The entries are in the range of 0 to 2^(bitmap width). Thus an allocator with a `UInt8` bitmap will return entries in the range 0 - 255.
protocol BitmapAllocatorProtocol {
    /// Returns the total number of entries that can be allocated.
    var entryCount: Int { get }
    /// Returns the number of entries that have not been allocated.
    var freeEntryCount: Int { get }
    /// Returns a Boolean value indicating whether the allocator has unallocated entries.
    var hasSpace: Bool { get }
    /// Returns the next free entry or `nil` if the allocator is full.
    mutating func allocate() -> Int?
    /// Frees the entry allowing it to be reused.
    mutating func free(entry: Int)
}

/// A bitmap allocatior with capacity for 8 items.
public typealias BitmapAllocator8 = BitmapAllocator<UInt8>
/// A bitmap allocatior with capacity for 16 items.
public typealias BitmapAllocator16 = BitmapAllocator<UInt16>
/// A bitmap allocatior with capacity for 32 items.
public typealias BitmapAllocator32 = BitmapAllocator<UInt32>
/// A bitmap allocatior with capacity for 64 items.
public typealias BitmapAllocator64 = BitmapAllocator<UInt64>
/// A bitmap allocatior with capacity for 128 items.
public typealias BitmapAllocator128 = DoubleBitmapAllocator<UInt64>

// Value as binary with '0' padding.
private func binNum<T: FixedWidthInteger & UnsignedInteger>(_ value: T) -> String {
    let num = String(value, radix: 2)
    let width = T.bitWidth
    if num.count < width {
        return String(repeating: "0", count: width - num.count) + num
    }
    return num
}

/// An allocator that uses an `UnsignedInteger` to store the allocated entries allowing upto `.bitWidth` entries to be allocated.
public struct BitmapAllocator<BitmapType: FixedWidthInteger & UnsignedInteger>:
    BitmapAllocatorProtocol, CustomStringConvertible
{
    private var bitmap: BitmapType  // Bits 0: Allocated, 1: Free

    /// A textual description of the allocator.
    /// - returns: A zero padding binary representation of the bitmap.
    public var description: String { binNum(bitmap) }
    /// - returns: The total number of entries that can be allocated.
    public var entryCount: Int { BitmapType.bitWidth }
    /// - returns: The number of entries that have not been allocated.
    public var freeEntryCount: Int { bitmap.nonzeroBitCount }
    /// - returns: A boolean value indicating whether the allocator has unallocated entries.
    public var hasSpace: Bool { bitmap != 0 }

    /// Creates a new, empty allocator.
    public init() {
        // Mark all the bits as free - set to 1
        bitmap = BitmapType.max
    }

    /// Allocate the next free entry.
    /// - returns: The next free entry or `nil` if the allocator is full.
    public mutating func allocate() -> Int? {
        let tzbc = bitmap.trailingZeroBitCount
        guard tzbc < entryCount else { return nil }
        bitmap &= ~BitmapType(1 << tzbc)
        return tzbc
    }

    /// Frees the entry allowing it to be reused.
    /// - parameter entry: The entry index to be freed.
    /// - precondition: The entry must be currently allocated.
    public mutating func free(entry: Int) {
        let bit: BitmapType = 1 << BitmapType(entry)
        precondition(bitmap & bit == 0)
        bitmap |= bit
    }
}

/// An allocator that uses 2 `UnsignedInteger`s to store the allocated entries allowing upto 2x `.bitWidth` entries to be allocated.
public struct DoubleBitmapAllocator<BitmapType: FixedWidthInteger & UnsignedInteger>:
    BitmapAllocatorProtocol, CustomStringConvertible
{
    private var bitmap0: BitmapType  // Bits 0: Allocated, 1: Free
    private var bitmap1: BitmapType

    /// A textual description of the allocator.
    /// - returns: A zero padding binary representation of the bitmap.
    public var description: String { "\(binNum(bitmap1))-\(binNum(bitmap0))" }
    /// - returns: The total number of entries that can be allocated.
    public var entryCount: Int { 2 * BitmapType.bitWidth }
    /// - returns: The number of entries that have not been allocated.
    public var freeEntryCount: Int { bitmap0.nonzeroBitCount + bitmap1.nonzeroBitCount }
    /// - returns: A boolean value indicating whether the allocator has unallocated entries.
    public var hasSpace: Bool { bitmap0 != 0 || bitmap1 != 0 }

    /// Creates a new, empty allocator.
    public init() {
        // Set the bits to 1 to mark them as available
        bitmap0 = BitmapType.max
        bitmap1 = BitmapType.max
    }

    /// Allocate the next free entry.
    /// - returns: The next free entry or `nil` if the allocator is full.
    public mutating func allocate() -> Int? {
        let tzbc0 = bitmap0.trailingZeroBitCount
        if tzbc0 < BitmapType.bitWidth {
            bitmap0 &= ~(BitmapType(1 << tzbc0))
            return tzbc0
        }

        let tzbc1 = bitmap1.trailingZeroBitCount
        if tzbc1 < BitmapType.bitWidth {
            bitmap1 &= ~(BitmapType(1 << tzbc1))
            return tzbc1 + BitmapType.bitWidth
        }

        return nil
    }

    /// Frees the entry allowing it to be reused.
    /// - parameter entry: The entry index to be freed.
    /// - precondition: The entry must be currently allocated.
    public mutating func free(entry: Int) {
        if entry < BitmapType.bitWidth {
            let bit: BitmapType = 1 << BitmapType(entry)
            precondition(bitmap0 & bit == 0)
            bitmap0 |= bit
        } else {
            let bit: BitmapType = 1 << BitmapType(entry - BitmapType.bitWidth)
            precondition(bitmap1 & bit == 0)
            bitmap1 |= bit
        }
    }
}
