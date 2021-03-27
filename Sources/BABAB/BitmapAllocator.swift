//
//  BitmapAllocator.swift
//  BABAB
//
//  Created by Simon Evans on 03/11/2020.
//  Copyright © 2020 - 2021 Simon Evans. All rights reserved.
//
//  Simple allocators that use a bitmap in a fixed width integer to store free/allocated blocks.
//

protocol BitmapAllocatorProtocol {
    var entryCount: Int { get }
    var freeEntryCount: Int { get }
    var hasSpace: Bool { get }
    mutating func allocate() -> Int?
    mutating func free(entry: Int)
}

public typealias BitmapAllocator8 = BitmapAllocator<UInt8>
public typealias BitmapAllocator16 = BitmapAllocator<UInt16>
public typealias BitmapAllocator32 = BitmapAllocator<UInt32>
public typealias BitmapAllocator64 = BitmapAllocator<UInt64>
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

/// Bitmap using UInt64 to allocate upto 8 entries.
public struct BitmapAllocator<BitmapType: FixedWidthInteger & UnsignedInteger>:
    BitmapAllocatorProtocol, CustomStringConvertible
{
    private var bitmap: BitmapType  // Bits 0: Allocated, 1: Free

    public var description: String { binNum(bitmap) }
    public var entryCount: Int { BitmapType.bitWidth }
    public var freeEntryCount: Int { bitmap.nonzeroBitCount }
    public var hasSpace: Bool { bitmap != 0 }

    public init() {
        // Mark all the bits as free - set to 1
        bitmap = BitmapType.max
    }

    public mutating func allocate() -> Int? {
        let tzbc = bitmap.trailingZeroBitCount
        guard tzbc < entryCount else { return nil }
        bitmap &= ~BitmapType(1 << tzbc)
        return tzbc
    }

    public mutating func free(entry: Int) {
        let bit: BitmapType = 1 << BitmapType(entry)
        precondition(bitmap & bit == 0)
        bitmap |= bit
    }
}

/// Bitmap using upto 2x UInt64 to allocate upto 128 entries.
public struct DoubleBitmapAllocator<BitmapType: FixedWidthInteger & UnsignedInteger>:
    BitmapAllocatorProtocol, CustomStringConvertible
{
    private var bitmap0: BitmapType  // Bits 0: Allocated, 1: Free
    private var bitmap1: BitmapType

    public var description: String { "\(binNum(bitmap1))-\(binNum(bitmap0))" }
    public var entryCount: Int { 2 * BitmapType.bitWidth }
    public var freeEntryCount: Int { bitmap0.nonzeroBitCount + bitmap1.nonzeroBitCount }
    public var hasSpace: Bool { bitmap0 != 0 || bitmap1 != 0 }

    public init() {
        // Set the bits to 1 to mark them as available
        bitmap0 = BitmapType.max
        bitmap1 = BitmapType.max
    }

    // Returns index of the least significant 1-bit of x, or if x is zero, returns nil
    // (same as __builtin_ffs)
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
