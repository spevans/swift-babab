//
//  UnsafeRawPointer.swift
//  BABAB
//
//  Created by Simon Evans on 26/03/2021.
//  Copyright © 2021 Simon Evans. All rights reserved.
//

#if os(Linux)
    import Glibc
#elseif os(macOS)
    import Darwin
#endif

extension UnsafeRawPointer {
    /// Returns a new instance of the given type, constructed from the raw memory at the specified offset.
    /// The type to be loaded must be a trivial type.
    /// ```
    /// The memory at this pointer plus offset does not need to be properly aligned for accessing T.
    /// It must be initialized to T or another type that is layout compatible with T.
    /// The returned instance is unassociated  with the value in the memory referenced by this pointer.
    /// ```
    /// - parameter offset: The offset from this pointer, in bytes. `offset`. The default is zero.
    /// - parameter type: The type of the instance to create.
    /// - returns: A new instance of type T, read from the raw bytes at offset.
    public func unalignedLoad<T: FixedWidthInteger>(fromByteOffset offset: Int = 0, as type: T.Type) -> T {
        var value = T(0)
        memcpy(&value, self.advanced(by: offset), MemoryLayout<T>.size)
        return value
    }
}

extension UnsafeMutableRawPointer {
    /// Stores a trivial type into raw memory at the specified offset.
    /// ```
    /// The type T to be stored must be a trivial type. The memory must be uninitialized, initialized to T,
    /// or initialized to another trivial type that is layout compatible with T.
    /// ```
    /// - parameter value: The value to store as raw bytes.
    /// - parameter offset: The offset from this pointer, in bytes. The default is zero.
    /// - parameter type: The type of value.
    public func unalignedStoreBytes<T>(of value: T, toByteOffset offset: Int, as type: T.Type) {
        var _value = value
        memcpy(self.advanced(by: offset), &_value, MemoryLayout<T>.size)
    }
}
