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
        ("testStringList", testStringList),
        ("testStringList", testDataList),
        ("testStringList", testEmptyList)
        ]
    
    func testStringList() {
        
        let items = (1 ... 10).map { "item\($0)" }
        
        let list = LinkedList(strings: items)
        XCTAssert(list.strings == items)
        XCTAssert(list.data.count == items.count)
        XCTAssert(list.isEmpty == false)
        XCTAssert(list.description == "\(items)")
        list.withUnsafeRawPointer { XCTAssert($0 != nil) }
    }
    
    func testDataList() {
        
        let items = (1 ... 10).map { "item\($0)".data(using: String.Encoding.utf8)! }
        
        let list = LinkedList(data: items)
        XCTAssert(list.data == items)
        XCTAssert(list.strings.count == items.count)
        XCTAssert(list.isEmpty == false)
        XCTAssert(list.description.isEmpty == false)
        list.withUnsafeRawPointer { XCTAssert($0 != nil) }
    }
    
    func testEmptyList() {
        
        let items = [Data]()
        
        let list = LinkedList(data: items)
        XCTAssert(list.isEmpty)
        XCTAssert(list.strings.isEmpty)
        XCTAssert(list.data.isEmpty)
        XCTAssert(list.description == "\(items)")
        list.withUnsafeRawPointer { XCTAssert($0 == nil) }
    }
}
