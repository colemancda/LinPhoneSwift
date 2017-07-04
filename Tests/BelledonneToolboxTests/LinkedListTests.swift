//
//  Core.swift
//  LinPhoneTests
//
//  Created by Alsey Coleman Miller on 6/30/17.
//
//

import XCTest
@testable import BelledonneToolbox

final class LinkedListTests: XCTestCase {
    
    static var allTests = [
        ("testValueSemantics", testValueSemantics),
        ]
    
    func testValueSemantics() {
        
        let element1String = "item1"
        var element1 = LinkedList(string: element1String)
        XCTAssert(element1.string == element1String)
        let originalElement1Reference = element1.internalReference.reference
        
        let element2String = "item2"
        var element2 = LinkedList(string: element2String)
        XCTAssert(element2.string == element2String)
        let originalElement2Reference = element2.internalReference.reference
        
        element1.append(&element2)
        XCTAssert(element1.previous == nil)
        XCTAssert(element1.next == element2)
        XCTAssert(element2.previous == element1, "\(element2.previous)")
        XCTAssert(element2.next == nil)
        XCTAssert(element1.internalReference.reference === originalElement1Reference)
        XCTAssert(element2.internalReference.reference === originalElement2Reference)
    }
}
