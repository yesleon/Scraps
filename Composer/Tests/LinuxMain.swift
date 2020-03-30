import XCTest

import ComposerTests

var tests = [XCTestCaseEntry]()
tests += ComposerTests.allTests()
XCTMain(tests)
