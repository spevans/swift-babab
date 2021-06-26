//
//  Bool+ExtrasTests.swift
//  BABABTests
//
//  Created by Simon Evans on 26/06/2021.
//  Copyright © 2021 Simon Evans. All rights reserved.
//

import XCTest

class BoolExtrasTests: XCTestCase {

    func testInit() {
        XCTAssertTrue(Bool(1))
        XCTAssertFalse(Bool(0))
        XCTAssertFalse(Bool(UInt.min))
    }

    static var allTests = [
        ("testInit", testInit),
    ]
}
