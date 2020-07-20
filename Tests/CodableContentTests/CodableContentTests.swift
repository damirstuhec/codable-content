import XCTest
@testable import CodableContent

final class CodableContentTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(CodableContent().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
