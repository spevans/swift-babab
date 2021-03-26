//
//  Bool.swift
//  BABAB
//
//  Created by Simon Evans on 26/03/2021.
//  Copyright © 2021 Simon Evans. All rights reserved.
//


extension Bool {
    public init(_ value: Int) {
        precondition(value == 0 || value == 1)
        self = value == 1 ? true : false
    }
}
