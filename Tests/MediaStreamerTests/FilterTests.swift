//
//  FilterTests.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 9/6/17.
//
//

import XCTest
@testable import MediaStreamer

final class FilterTests: XCTestCase {
    
    func testCustomFilter() {
        
        let factory = Factory()
        
        var description = Filter.Description()
        
        let filterDescriptionReference = description.internalReference.reference
        
        // set new values
        description.name = "TestFilter"
        description.encodingFormat = "H264"
        description.text = "A test filter"
        description.category = .decoder
        description.inputCount = 1
        description.outputCount = 1
        XCTAssert(description.internalReference.reference === filterDescriptionReference)
        
        let initExpectation = self.expectation(description: "Filter initialized")
        
        description.initialization = { (filter) in
            
            // assert values
            XCTAssert(filter.name == description.name)
            
            // assert backing references
            XCTAssert(filter.description?.internalReference.reference === filterDescriptionReference)
            XCTAssert(filter.description?.internalReference.reference === description.internalReference.reference)
            
            initExpectation.fulfill()
        }
        
        guard let filter = Filter(description: description, factory: factory)
            else { XCTFail("Could not create filter"); return }
        
        XCTAssert(filter.name == description.name)
        
        waitForExpectations(timeout: 2)
    }
    
    func testNewFilterDescription() {
        
        var description = Filter.Description()
        
        // validate new filter description
        XCTAssert(description.name == nil)
        XCTAssert(description.encodingFormat == nil)
        XCTAssert(description.text == nil)
        XCTAssert(description.category == .other)
        XCTAssert(description.inputCount == 0)
        XCTAssert(description.outputCount == 0)
        XCTAssert(description.implements(interface: .begin) == false)
    }
    
    func testFilterDescriptionValueSemantics() {
        
        var description = Filter.Description()
        
        let filterDescriptionReference = description.internalReference.reference
        
        // set new values
        description.name = "TestFilter"
        description.encodingFormat = "H264"
        description.text = "A test filter"
        description.category = .decoder
        description.inputCount = 1
        description.outputCount = 1
        
        XCTAssert(description.internalReference.reference === filterDescriptionReference)
        
        let unmutatedCopy = description
        let unmutatedCopy2 = unmutatedCopy
        XCTAssert(description.internalReference.reference === unmutatedCopy.internalReference.reference)
        XCTAssert(description.internalReference.reference.rawPointer == unmutatedCopy.internalReference.reference.rawPointer)
        XCTAssert(description.internalReference.reference === unmutatedCopy2.internalReference.reference)
        XCTAssert(unmutatedCopy.internalReference.reference === unmutatedCopy2.internalReference.reference)
        
        var mutableCopy = description
        XCTAssert(description.internalReference.reference === mutableCopy.internalReference.reference)
        mutableCopy.name = "New value"
        XCTAssert(description.internalReference.reference !== mutableCopy.internalReference.reference)
        XCTAssert(description.internalReference.reference.rawPointer != mutableCopy.internalReference.reference.rawPointer)
        XCTAssert(unmutatedCopy.internalReference.reference !== mutableCopy.internalReference.reference)
        XCTAssert(unmutatedCopy2.internalReference.reference !== mutableCopy.internalReference.reference)
        XCTAssert(description.internalReference.reference === unmutatedCopy.internalReference.reference)
        XCTAssert(description.internalReference.reference === unmutatedCopy2.internalReference.reference)
        XCTAssert(unmutatedCopy.internalReference.reference === unmutatedCopy2.internalReference.reference)
    }
}
