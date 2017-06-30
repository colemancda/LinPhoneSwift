import XCTest
@testable import LinPhoneSwift

class LinPhoneSwiftTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(LinPhoneSwift().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
