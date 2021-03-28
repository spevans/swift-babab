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
    public func unalignedLoad<T: FixedWidthInteger>(fromByteOffset offset: Int = 0, as type: T.Type) -> T {
        var value = T(0)
        memcpy(&value, self.advanced(by: offset), MemoryLayout<T>.size)
        return value
    }
}

extension UnsafeMutableRawPointer {
    public func unalignedStoreBytes<T>(of value: T, toByteOffset offset: Int, as type: T.Type) {
        var _value = value
        memcpy(self.advanced(by: offset), &_value, MemoryLayout<T>.size)
    }
}
