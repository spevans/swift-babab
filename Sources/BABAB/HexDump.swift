//
//  HexDump.swift
//  BABAB
//
//  Created by Simon Evans on 26/03/2021.
//  Copyright © 2021 Simon Evans. All rights reserved.
//
//  Functions for hexDumps of collections and memory buffers.
//

private let bytesPerLine = 16

public func hexDump<S: Sequence & Collection, A: FixedWidthInteger & UnsignedInteger>(
    _ buffer: S, startAddress: A, showASCII: Bool = false
) -> String
where S.Element == UInt8 {

    guard buffer.count > 0 else { return "" }
    let offset = Int(startAddress % A(bytesPerLine))
    var address = startAddress - A(offset)
    var iterator = buffer.makeIterator()

    var output = "\(startAddress.hex()): "
    let firstLineCount = min(buffer.count, bytesPerLine - offset)
    dumpMemoryLine(&iterator, offset: offset, count: firstLineCount, into: &output, showASCII: showASCII)
    var totalBytes = buffer.count - firstLineCount
    output += "\n"
    address += A(bytesPerLine)

    while totalBytes > 0 {
        output += "\(address.hex()): "
        let count = min(totalBytes, bytesPerLine)
        dumpMemoryLine(&iterator, offset: 0, count: count, into: &output, showASCII: showASCII)
        totalBytes -= count
        output += "\n"
        address += A(bytesPerLine)
    }
    output.removeLast()  // Remove trailing "\n"
    return output
}

public func hexDump<S: Sequence & Collection>(_ buffer: S, showASCII: Bool = false) -> String
where S.Element == UInt8 {

    guard buffer.count > 0 else { return "" }
    var iterator = buffer.makeIterator()
    var totalBytes = buffer.count
    var output = ""

    while totalBytes > 0 {
        let count = min(totalBytes, bytesPerLine)
        dumpMemoryLine(&iterator, offset: 0, count: count, into: &output, showASCII: showASCII)
        output += "\n"
        totalBytes -= count
    }
    output.removeLast()  // Remove trailing "\n"
    return output
}

private func dumpMemoryLine<I: IteratorProtocol>(
    _ buffer: inout I, offset: Int, count: Int, into line: inout String, showASCII: Bool
)
where I.Element == UInt8 {

    precondition(1...bytesPerLine ~= count)
    var ascii = ""
    if offset > 0 {
        if showASCII { ascii = String(repeating: " ", count: offset) }
        line += String(repeating: "   ", count: offset)
    }

    for position in offset..<(offset + count) {
        guard let byte = buffer.next() else { break }

        line += byte.hex()
        // Show '-' separator between columns 8 & 9 instead of a space
        if position == 7 && count > 1 {
            line += "-"
        } else {
            line += " "
        }

        if showASCII {
            let character = (byte >= 32 && byte < 127) ? Character(UnicodeScalar(byte)) : "."
            ascii.append(character)
        }
    }
    if showASCII {
        let remaining = bytesPerLine - (count + offset)
        if remaining > 0 { line += String(repeating: "   ", count: remaining) }
        line.append(ascii)
    } else {
        line.removeLast()  // Remove trailing " "
    }
}
