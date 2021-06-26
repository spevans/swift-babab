//
//  Bool.swift
//  BABAB
//
//  Created by Simon Evans on 26/03/2021.
//  Copyright © 2021 Simon Evans. All rights reserved.
//

extension Bool {
    /// Creates a new Boolean value from the given Integer.
    /// - parameter value: An `Int` used to initialise the `Bool`.
    /// - precondition: `value` is equal to 0 or 1.
    public init<T: BinaryInteger>(_ value: T) {
        precondition(value == 0 || value == 1)
        self = (value == 1) ? true : false
    }
}
