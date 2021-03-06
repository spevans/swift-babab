import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        return [
            testCase(BitFieldTests.allTests),
            testCase(HexDumpTests.allTests),
            testCase(BitmapAllocatorTests.allTests),
            testCase(BinaryIntegerExtrasTests.allTests),
            testCase(BoolExtrasTests.allTests),
            testCase(FixedWidthIntegerExtrasTests.allTests),
            testCase(NumberSetTests.allTests),
            testCase(ByteArrayTests.allTests),
        ]
    }
#endif
