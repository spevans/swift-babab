import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        return [
            testCase(BitArrayTests.allTests),
            testCase(HexDumpTests.allTests),
            testCase(BitmapAllocatorTests.allTests),
        ]
    }
#endif
