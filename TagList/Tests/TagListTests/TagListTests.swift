import XCTest
@testable import TagList

final class TagListTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(TagList().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
