import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        return [
            testCase(BitArrayTests.allTests),
            testCase(HexDumpTests.allTests),
            testCase(BitmapAllocatorTests.allTests),
            testCase(BinaryIntegerExtrasTests.allTests),
            testCase(BoolExtrasTests.allTests),
            testCase(FixedWidthIntegerExtrasTests.allTests),
            testCase(NumberSetTests.allTests),
        ]
    }
#endif
