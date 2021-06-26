//
//  FixedWidthInteger+Extras.swift
//  BABAB
//
//  Created by Simon Evans on 25/06/2021.
//  Copyright © 2021 Simon Evans. All rights reserved.
//

extension FixedWidthInteger {

    public func bit(_ index: Int) -> Bool {
        precondition(index >= 0 && index < self.bitWidth, "Bit must be in range 0-\(self.bitWidth)")
        let mask = Self(1 << Self(index))
        return self & mask != 0
    }

    mutating public func bit(_ index: Int, _ newValue: Bool) {
        precondition(index >= 0 && index < self.bitWidth, "Bit must be in range 0-\(self.bitWidth)")
        let mask = Self(1 << Self(index))
        if newValue {
            self |= mask
        } else {
            self &= ~mask
        }
    }

    @inlinable
    public var lowestBitSet: Int? {
        guard self != 0 else { return nil }
        return self.trailingZeroBitCount
    }

    @inlinable
    public var highestBitSet: Int? {
        guard self != 0 else { return nil }
        return (self.bitWidth - self.leadingZeroBitCount) - 1
    }

    @inlinable
    @discardableResult
    public mutating func clearLowestBitSet() -> Int? {
        guard let bit = lowestBitSet else { return nil }
        self.bit(bit, false)
        return bit
    }

    @inlinable
    @discardableResult
    public mutating func clearHighestBitSet() -> Int? {
        guard let bit = highestBitSet else { return nil }
        self.bit(bit, false)
        return bit
    }

    public init<C: Collection>(littleEndianBytes: C) where C.Element == UInt8, C.Index == Int {
        let count = Self.bitWidth / 8
        precondition(littleEndianBytes.count >= count)

        var value = Self(0)
        var shift = 0
        for idx in littleEndianBytes.startIndex..<(littleEndianBytes.startIndex + count) {
            value |= Self(littleEndianBytes[idx]) << shift
            shift += 8
        }
        self = value
    }

    public init<C: Collection>(bigEndianBytes: C) where C.Element == UInt8, C.Index == Int {
        let count = Self.bitWidth / 8
        precondition(bigEndianBytes.count >= count)

        var value = Self(0)
        for idx in bigEndianBytes.startIndex..<(bigEndianBytes.startIndex + count) {
            value <<= 8
            value |= Self(bigEndianBytes[idx])
        }
        self = value
    }
}

extension FixedWidthInteger {
    public func maskFrom(bitCount: Int) -> Self {
        if bitCount == Self.bitWidth {
            return Self.max
        } else {
            return Self(1 << Self(bitCount)) - Self(1)
        }
    }
}

extension FixedWidthInteger where Self: UnsignedInteger {
    public init?(bcd: Self) {
        var bcd = bcd
        var value = Self(0)
        var multiplier = Self(1)
        let nibbles = Self.bitWidth / 4
        for _ in 1...nibbles {
            let nibble = bcd & 0xf
            guard nibble <= 9 else { return nil }
            bcd >>= 4
            value += (nibble * multiplier)
            multiplier *= 10
        }
        self = value
    }

    public var bcdValue: Self? {
        var value = self
        var shift = Self(0)
        var result = Self(0)

        while value > 0 {
            guard (Self.bitWidth - Int(shift)) >= 4 else { return nil }
            let nibble = value % 10
            result |= (nibble << shift)
            value /= 10
            shift += 4
        }
        return result
    }
}
