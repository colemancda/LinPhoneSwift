//
//  URITests.swift
//  BelledonneSIPTests
//
//  Created by Alsey Coleman Miller on 6/30/17.
//
//

import XCTest
@testable import BelledonneSIP

final class URITests: XCTestCase {
    
    static var allTests = [
        ("testBasicURI", testBasicURI),
        ]
    
    func testBasicURI() {
        
        let rawURI = "http://www.linphone.org/index.html"
        
        guard let sourceURI = URI(string: rawURI)
            else { XCTFail(); return }
        
        XCTAssert(sourceURI.stringValue == rawURI)
        
        guard let firstURI = URI(string: sourceURI.stringValue)
            else { XCTFail(); return }
        
        let uri = firstURI // no copy since we are using value types
        
        
    }
}
