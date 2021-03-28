//
//  Int.swift
//  BABAB
//
//  Created by Simon Evans on 26/03/2021.
//  Copyright © 2021 Simon Evans. All rights reserved.
//

extension Int {
    /// Creates a new Integer value from the given Boolean.
    /// - parameter value: A `Bool` used to initialise the `Int`.
    public init(_ value: Bool) {
        self = value ? 1 : 0
    }
}
