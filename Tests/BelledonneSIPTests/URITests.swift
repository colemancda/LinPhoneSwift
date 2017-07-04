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
        
        do {
            
            let rawURI = "http://www.linphone.org/index.html"
            
            guard let sourceURI = URI(string: rawURI)
                else { XCTFail(); return }
            
            XCTAssert(sourceURI.stringValue == rawURI)
            
            guard let firstURI = URI(string: sourceURI.stringValue)
                else { XCTFail(); return }
            
            let uri = firstURI // no copy since we are using value types
            
            XCTAssert(uri.scheme == "http")
            XCTAssert(uri.host == "www.linphone.org")
            XCTAssert(uri.path == "/index.html")
        }
        
        do {
            
            let rawURI = "http://www.linphone.org/"
            
            guard let sourceURI = URI(string: rawURI)
                else { XCTFail(); return }
            
            XCTAssert(sourceURI.path == "/")
        }
        
        do {
            
            let rawURI = "http://www.linphone.org/a/b/c"
            
            guard let sourceURI = URI(string: rawURI)
                else { XCTFail(); return }
            
            XCTAssert(sourceURI.path == "/a/b/c")
            XCTAssert(sourceURI.stringValue == "http://www.linphone.org/a/b/c")
            XCTAssert(sourceURI.description == sourceURI.stringValue)
        }
    }
    
    func testValueSemantics() {
        
        let rawURI = "http://www.linphone.org/index.html"
        
        guard let sourceURI = URI(string: rawURI)
            else { XCTFail(); return }
        
        let unmutatedCopy = sourceURI
        let unmutatedCopy2 = unmutatedCopy
        XCTAssert(sourceURI.internalReference.reference === unmutatedCopy.internalReference.reference)
        XCTAssert(sourceURI.internalReference.reference.unmanagedPointer.rawPointer == unmutatedCopy.internalReference.reference.unmanagedPointer.rawPointer)
        XCTAssert(sourceURI.internalReference.reference === unmutatedCopy2.internalReference.reference)
        XCTAssert(unmutatedCopy.internalReference.reference === unmutatedCopy2.internalReference.reference)
        
        var mutableCopy = sourceURI
        XCTAssert(sourceURI.internalReference.reference === mutableCopy.internalReference.reference)
        mutableCopy.port = 8080
        XCTAssert(sourceURI.internalReference.reference !== mutableCopy.internalReference.reference)
        XCTAssert(sourceURI.internalReference.reference.unmanagedPointer.rawPointer != mutableCopy.internalReference.reference.unmanagedPointer.rawPointer)
        XCTAssert(unmutatedCopy.internalReference.reference !== mutableCopy.internalReference.reference)
        XCTAssert(unmutatedCopy2.internalReference.reference !== mutableCopy.internalReference.reference)
        XCTAssert(sourceURI.internalReference.reference === unmutatedCopy.internalReference.reference)
        XCTAssert(sourceURI.internalReference.reference === unmutatedCopy2.internalReference.reference)
        XCTAssert(unmutatedCopy.internalReference.reference === unmutatedCopy2.internalReference.reference)
    }
}
