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
        ("testBasicList", testBasicList),
        ]
    
    func testBasicList() {
        
        let items = (1 ... 10).map { "item\($0)" }
        guard let list = LinkedList(strings: items)
            else { XCTFail(); return }
        XCTAssert(list)
        
        
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
        XCTAssert(element2.previous == element1)
        XCTAssert(element2.next == nil)
        XCTAssert(element1.internalReference.reference === originalElement1Reference)
        XCTAssert(element2.internalReference.reference === originalElement2Reference)
        XCTAssert(element1.description == "\([element1String, element2String])")
        XCTAssert(element1.last == element2)
        XCTAssert(element2.last == element2)
        XCTAssert(element1.first == element1)
        XCTAssert(element2.first == element1)
        XCTAssert(element1.description == "\([element1String, element2String])", "\(element1.description)")
        
        var element1Copy = element1
        XCTAssert(element1Copy.internalReference.reference === originalElement1Reference)
        XCTAssert(element1Copy.next?.internalReference.reference === originalElement2Reference)
        
        element1Copy.append(&element1)
        XCTAssert(element1Copy.internalReference.reference !== originalElement1Reference)
        XCTAssert(element1Copy.next?.internalReference.reference !== originalElement2Reference)
        XCTAssert(element1Copy.description == "\([element1String, element2String, element1String, element2String])", "\(element1Copy.description)")
        
        var elementList = element1
        var newElement2 = LinkedList(string: element2String)
        elementList.append(&newElement2)
        XCTAssert(elementList.description == "\([element1String, element2String, element2String])", "\(elementList.description)")
        
        var elementList2 = element1
        var newElement2Copy = newElement2
        elementList2.append(&newElement2Copy)
        XCTAssert(elementList2.description == "\([element1String, element2String, element2String])", "\(elementList.description)")
        
    }
}
