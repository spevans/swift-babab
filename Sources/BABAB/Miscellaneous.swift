//
//  Miscellaneous.swift
//  BABAB
//
//  Created by Simon Evans on 26/03/2021.
//  Copyright © 2021 Simon Evans. All rights reserved.
//


public func hexNum<T: FixedWidthInteger & UnsignedInteger>(_ value: T) -> String {
    let num = String(value, radix: 16)
    let width = T.bitWidth / 4
    if num.count <= width {
        return String(repeating: "0", count: width - num.count) + num
    }
    return num
}
