//
//  HexDumpTests.swift
//  BABABTests
//
//  Created by Simon Evans on 27/03/2021.
//

import XCTest
import BABAB


class HexDumpTests: XCTestCase {

    func testHexNum() {
        XCTAssertEqual(hexNum(UInt8.min), "00")
        XCTAssertEqual(hexNum(UInt8.max), "ff")
        XCTAssertEqual(hexNum(UInt16.min), "0000")
        XCTAssertEqual(hexNum(UInt16.max), "ffff")
        XCTAssertEqual(hexNum(UInt32.min), "00000000")
        XCTAssertEqual(hexNum(UInt32.max), "ffffffff")
        XCTAssertEqual(hexNum(UInt64.min), "0000000000000000")
        XCTAssertEqual(hexNum(UInt64.max), "ffffffffffffffff")
    }

    func testEmptyCollections() {
        XCTAssertEqual(hexDump([]), "")
        XCTAssertEqual(hexDump([], showASCII: true), "")
        XCTAssertEqual(hexDump([], startAddress: UInt16(0x123)), "")
        XCTAssertEqual(hexDump([], startAddress: UInt32(0x123), showASCII: true), "")
    }

    func testStartAddress() {
        let bytes: [UInt8] = [0x30, 0x31]

        XCTAssertEqual(hexDump(bytes, startAddress: UInt8(1)), "01:    30 31")
        XCTAssertEqual(hexDump(bytes, startAddress: UInt16(0x12)), "0012:       30 31")
        XCTAssertEqual(hexDump(bytes, startAddress: UInt32(0x12345678)), "12345678:                         30 31")

        let expected64 = """
        0123456789abcdef:                                              30
        0123456789abcdf0: 31
        """
        XCTAssertEqual(hexDump(bytes, startAddress: UInt64(0x0123456789abcdef)), expected64)

    }

    func testShowASCII() {
        let bytes = (0...15).map { UInt8($0) }
        XCTAssertEqual(hexDump(bytes, startAddress: UInt8(0), showASCII: true), "00: 00 01 02 03 04 05 06 07-08 09 0a 0b 0c 0d 0e 0f ................")

        let expected1 = """
        01:    00 01 02 03 04 05 06-07 08 09 0a 0b 0c 0d 0e  ...............
        10: 0f                                              .
        """
        XCTAssertEqual(hexDump(bytes, startAddress: UInt8(1), showASCII: true), expected1)

        let expected15 = """
        0f:                                              00                .
        10: 01 02 03 04 05 06 07 08-09 0a 0b 0c 0d 0e 0f    ...............
        """
        XCTAssertEqual(hexDump(bytes, startAddress: UInt8(15), showASCII: true), expected15)

        let asciiBytes = (0x30..<0x40).map { UInt8($0) }
        XCTAssertEqual(hexDump(asciiBytes, startAddress: UInt8(0), showASCII: true), "00: 30 31 32 33 34 35 36 37-38 39 3a 3b 3c 3d 3e 3f 0123456789:;<=>?")

    }

    func testDumpMemory() {
        XCTAssertEqual(hexDump([0x30, 0x31]), "30 31")
        XCTAssertEqual(hexDump([0x30, 0x31], showASCII: true), "30 31                                           01")
        XCTAssertEqual(hexDump([0x30, 0x31], startAddress: UInt16(0xf)), "000f:                                              30\n0010: 31")
        XCTAssertEqual(hexDump([0x30, 0x31], startAddress: UInt16(0xf)), "000f:                                              30\n0010: 31")


        let bytes: [UInt8] = [0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x20, 0x54, 0x68, 0x65, 0x72, 0x65, 0x20, 0x57, 0x6f, 0x72, 0x6c, 0x64, 0x0a]

        let expected1 = """
        48 65 6c 6c 6f 20 54 68-65 72 65 20 57 6f 72 6c
        64 0a
        """
        XCTAssertEqual(hexDump(bytes), expected1)

        let expected2 = """
        48 65 6c 6c 6f 20 54 68-65 72 65 20 57 6f 72 6c Hello There Worl
        64 0a                                           d.
        """
        XCTAssertEqual(hexDump(bytes, showASCII: true), expected2)

        let expected3 = """
        87654321:    48 65 6c 6c 6f 20 54-68 65 72 65 20 57 6f 72
        87654330: 6c 64 0a
        """
        XCTAssertEqual(hexDump(bytes, startAddress: UInt32(0x87654321)), expected3)

        let expected4 = """
        87654321:    48 65 6c 6c 6f 20 54-68 65 72 65 20 57 6f 72  Hello There Wor
        87654330: 6c 64 0a                                        ld.
        """
        XCTAssertEqual(hexDump(bytes, startAddress: UInt32(0x87654321), showASCII: true), expected4)


        let allBytes = (0...0xff).map { UInt8($0) }

        let largeDump1 = """
            ff fe fd fc fb fa f9 f8-f7 f6 f5 f4 f3 f2 f1 f0
            ef ee ed ec eb ea e9 e8-e7 e6 e5 e4 e3 e2 e1 e0
            df de dd dc db da d9 d8-d7 d6 d5 d4 d3 d2 d1 d0
            cf ce cd cc cb ca c9 c8-c7 c6 c5 c4 c3 c2 c1 c0
            bf be bd bc bb ba b9 b8-b7 b6 b5 b4 b3 b2 b1 b0
            af ae ad ac ab aa a9 a8-a7 a6 a5 a4 a3 a2 a1 a0
            9f 9e 9d 9c 9b 9a 99 98-97 96 95 94 93 92 91 90
            8f 8e 8d 8c 8b 8a 89 88-87 86 85 84 83 82 81 80
            7f 7e 7d 7c 7b 7a 79 78-77 76 75 74 73 72 71 70
            6f 6e 6d 6c 6b 6a 69 68-67 66 65 64 63 62 61 60
            5f 5e 5d 5c 5b 5a 59 58-57 56 55 54 53 52 51 50
            4f 4e 4d 4c 4b 4a 49 48-47 46 45 44 43 42 41 40
            3f 3e 3d 3c 3b 3a 39 38-37 36 35 34 33 32 31 30
            2f 2e 2d 2c 2b 2a 29 28-27 26 25 24 23 22 21 20
            1f 1e 1d 1c 1b 1a 19 18-17 16 15 14 13 12 11 10
            0f 0e 0d 0c 0b 0a 09 08-07 06 05 04 03 02 01 00
            """
        XCTAssertEqual(hexDump(allBytes.reversed()), largeDump1)

        let largeDump2 = #"""
            00 01 02 03 04 05 06 07-08 09 0a 0b 0c 0d 0e 0f ................
            10 11 12 13 14 15 16 17-18 19 1a 1b 1c 1d 1e 1f ................
            20 21 22 23 24 25 26 27-28 29 2a 2b 2c 2d 2e 2f  !"#$%&'()*+,-./
            30 31 32 33 34 35 36 37-38 39 3a 3b 3c 3d 3e 3f 0123456789:;<=>?
            40 41 42 43 44 45 46 47-48 49 4a 4b 4c 4d 4e 4f @ABCDEFGHIJKLMNO
            50 51 52 53 54 55 56 57-58 59 5a 5b 5c 5d 5e 5f PQRSTUVWXYZ[\]^_
            60 61 62 63 64 65 66 67-68 69 6a 6b 6c 6d 6e 6f `abcdefghijklmno
            70 71 72 73 74 75 76 77-78 79 7a 7b 7c 7d 7e 7f pqrstuvwxyz{|}~.
            80 81 82 83 84 85 86 87-88 89 8a 8b 8c 8d 8e 8f ................
            90 91 92 93 94 95 96 97-98 99 9a 9b 9c 9d 9e 9f ................
            a0 a1 a2 a3 a4 a5 a6 a7-a8 a9 aa ab ac ad ae af ................
            b0 b1 b2 b3 b4 b5 b6 b7-b8 b9 ba bb bc bd be bf ................
            c0 c1 c2 c3 c4 c5 c6 c7-c8 c9 ca cb cc cd ce cf ................
            d0 d1 d2 d3 d4 d5 d6 d7-d8 d9 da db dc dd de df ................
            e0 e1 e2 e3 e4 e5 e6 e7-e8 e9 ea eb ec ed ee ef ................
            f0 f1 f2 f3 f4 f5 f6 f7-f8 f9 fa fb fc fd fe ff ................
            """#
        XCTAssertEqual(hexDump(allBytes, showASCII: true), largeDump2)

        let largeDump3 = #"""
            0000000000003039:                            00 01 02 03 04 05 06          .......
            0000000000003040: 07 08 09 0a 0b 0c 0d 0e-0f 10 11 12 13 14 15 16 ................
            0000000000003050: 17 18 19 1a 1b 1c 1d 1e-1f 20 21 22 23 24 25 26 ......... !"#$%&
            0000000000003060: 27 28 29 2a 2b 2c 2d 2e-2f 30 31 32 33 34 35 36 '()*+,-./0123456
            0000000000003070: 37 38 39 3a 3b 3c 3d 3e-3f 40 41 42 43 44 45 46 789:;<=>?@ABCDEF
            0000000000003080: 47 48 49 4a 4b 4c 4d 4e-4f 50 51 52 53 54 55 56 GHIJKLMNOPQRSTUV
            0000000000003090: 57 58 59 5a 5b 5c 5d 5e-5f 60 61 62 63 64 65 66 WXYZ[\]^_`abcdef
            00000000000030a0: 67 68 69 6a 6b 6c 6d 6e-6f 70 71 72 73 74 75 76 ghijklmnopqrstuv
            00000000000030b0: 77 78 79 7a 7b 7c 7d 7e-7f 80 81 82 83 84 85 86 wxyz{|}~........
            00000000000030c0: 87 88 89 8a 8b 8c 8d 8e-8f 90 91 92 93 94 95 96 ................
            00000000000030d0: 97 98 99 9a 9b 9c 9d 9e-9f a0 a1 a2 a3 a4 a5 a6 ................
            00000000000030e0: a7 a8 a9 aa ab ac ad ae-af b0 b1 b2 b3 b4 b5 b6 ................
            00000000000030f0: b7 b8 b9 ba bb bc bd be-bf c0 c1 c2 c3 c4 c5 c6 ................
            0000000000003100: c7 c8 c9 ca cb cc cd ce-cf d0 d1 d2 d3 d4 d5 d6 ................
            0000000000003110: d7 d8 d9 da db dc dd de-df e0 e1 e2 e3 e4 e5 e6 ................
            0000000000003120: e7 e8 e9 ea eb ec ed ee-ef f0 f1 f2 f3 f4 f5 f6 ................
            0000000000003130: f7 f8 f9 fa fb fc fd fe-ff                      .........
            """#
        XCTAssertEqual(hexDump(allBytes, startAddress: UInt(12345), showASCII: true), largeDump3)
    }

    func testColumnSeparator() {

        // Single byte, no separator
        let byte: [UInt8] = [0x30]
        XCTAssertEqual(hexDump(byte), "30")
        XCTAssertEqual(hexDump(byte, startAddress: UInt8(0)), "00: 30")
        XCTAssertEqual(hexDump(byte, startAddress: UInt8(6)), "06:                   30")
        XCTAssertEqual(hexDump(byte, startAddress: UInt8(7)), "07:                      30")
        XCTAssertEqual(hexDump(byte, startAddress: UInt8(8)), "08:                         30")

        // Two bytes, separator between columns 7 & 8
        let bytes: [UInt8] = [0x30, 0x31]

        XCTAssertEqual(hexDump(bytes), "30 31")
        XCTAssertEqual(hexDump(bytes, startAddress: UInt8(0)), "00: 30 31")
        XCTAssertEqual(hexDump(bytes, startAddress: UInt8(6)), "06:                   30 31")
        XCTAssertEqual(hexDump(bytes, startAddress: UInt8(7)), "07:                      30-31")
        XCTAssertEqual(hexDump(bytes, startAddress: UInt8(8)), "08:                         30 31")
    }


    static var allTests = [
        ("testHexNum", testHexNum),
        ("testEmptyCollections", testEmptyCollections),
        ("testStartAddress", testStartAddress),
        ("testShowASCII", testShowASCII),
        ("testDumpMemory", testDumpMemory),
        ("testColumnSeparator", testColumnSeparator),
    ]
}
