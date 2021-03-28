//
// BitArray.swift
// BABAB
//
// Created by Simon Evans on 28/03/2017.
// Copyright © 2017 - 2021 Simon Evans. All rights reserved.
//
// BitArray<x> types. Treat UInt8/UInt16/UInt32/UInt64 as arrays of bits.
//

public typealias BitArray8 = BitArray<UInt8>
public typealias BitArray16 = BitArray<UInt16>
public typealias BitArray32 = BitArray<UInt32>
public typealias BitArray64 = BitArray<UInt64>

public struct BitArray<T: FixedWidthInteger & UnsignedInteger>: BidirectionalCollection, MutableCollection,
    CustomStringConvertible
{

    public typealias Index = Int
    public typealias Element = Int
    typealias SubSequnce = Self

    public private(set) var rawValue: T

    public var startIndex: Self.Index { 0 }
    public var endIndex: Self.Index { rawValue.bitWidth }
    public var count: Int { rawValue.bitWidth }

    public func index(before i: Self.Index) -> Self.Index {
        return i - 1
    }

    public func index(after i: Self.Index) -> Self.Index {
        return i + 1
    }

    public var description: String {
        let num = String(rawValue, radix: 2)
        let width = T.bitWidth
        return String(repeating: "0", count: width - num.count) + num
    }

    public init() {
        rawValue = 0
    }

    public init(_ rawValue: Int) {
        self.rawValue = T(rawValue)
    }

    public init(_ rawValue: UInt) {
        self.rawValue = T(rawValue)
    }

    public init(_ rawValue: T) {
        self.rawValue = rawValue
    }

    public subscript(index: Int) -> Int {
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

    public subscript(index: ClosedRange<Int>) -> T {
        get {
            var ret: T = 0
            var bit: T = 1

            for i in index {
                let mask: T = 1 << i
                if rawValue & mask != 0 {
                    ret |= bit
                }
                bit <<= 1
            }
            return ret
        }
        set {
            var bit: T = 1
            for i in index {
                let mask: T = 1 << i
                if (newValue & bit) == 0 {
                    rawValue &= ~mask
                } else {
                    rawValue |= mask
                }
                bit <<= 1
            }
        }
    }
}
