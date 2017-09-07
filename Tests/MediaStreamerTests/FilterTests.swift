//
//  FilterTests.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 9/6/17.
//
//

import XCTest
import CMediaStreamer2.filter
@testable import MediaStreamer

final class FilterTests: XCTestCase {
    
    func testCustomFilter() {
        
        let factory = Factory()
        
        var description = Filter.Description()
        
        let filterDescriptionReference = description.internalReference.reference
        
        // set new values
        description.identifier = MS_VT_H264_DEC_ID
        description.name = "TestFilter Decoder"
        description.encodingFormat = "H264"
        description.text = "A test filter"
        description.category = .decoder
        description.inputCount = 1
        description.outputCount = 1
        description.flags = [.pump, .enabled]
        description.methods = []
        
        XCTAssert(description.flags == [.pump, .enabled])
        XCTAssert(description.internalReference.reference === filterDescriptionReference)
        
        description.initialization = { _ in print("Filter created") }
        
        let uninitExpectation = self.expectation(description: "Filter uninitialized")
        
        description.uninitialization = { (filter) in
            
            print("\(filter.name) destroyed")
            
            // assert values
            XCTAssert(filter.name == description.name)
            
            // assert backing references
            XCTAssert(filter.description?.internalReference.reference === filterDescriptionReference)
            XCTAssert(filter.description?.internalReference.reference === description.internalReference.reference)
            
            uninitExpectation.fulfill()
        }
        
        // create custom filter
        var filter = Filter(description: description, factory: factory)
        XCTAssertNotNil(filter, "Could not create filter")
        XCTAssert(filter?.name == description.name)
        XCTAssert(filter?.description?.internalReference.reference === filterDescriptionReference)
        XCTAssert(filter?.description?.internalReference.reference === description.internalReference.reference)
        
        // release
        filter = nil
        
        waitForExpectations(timeout: 2)
    }
    
    func testNewFilterDescription() {
        
        var description = Filter.Description()
        
        // validate new filter description
        XCTAssert(description.name == nil)
        XCTAssert(description.encodingFormat == nil)
        XCTAssert(description.text == nil)
        XCTAssert(description.category == .other)
        XCTAssert(description.category.rawValue == 0)
        XCTAssert(description.inputCount == 0)
        XCTAssert(description.outputCount == 0)
        XCTAssert(description.implements(interface: .begin) == false)
    }
    
    func testFilterDescriptionValueSemantics() {
        
        var description = Filter.Description()
        
        let filterDescriptionReference = description.internalReference.reference
        
        // set new values
        description.identifier = MS_VT_H264_DEC_ID
        description.name = "TestFilter Decoder"
        description.text = "A test filter"
        description.category = .decoder
        description.inputCount = 1
        description.outputCount = 1
        description.flags = [.pump, .enabled]
        description.methods = []
        
        XCTAssert(description.internalReference.reference === filterDescriptionReference)
        
        let unmutatedCopy = description
        let unmutatedCopy2 = unmutatedCopy
        XCTAssert(description.internalReference.reference === unmutatedCopy.internalReference.reference)
        XCTAssert(description.internalReference.reference.rawPointer == unmutatedCopy.internalReference.reference.rawPointer)
        XCTAssert(description.internalReference.reference === unmutatedCopy2.internalReference.reference)
        XCTAssert(unmutatedCopy.internalReference.reference === unmutatedCopy2.internalReference.reference)
        
        var mutableCopy = description
        XCTAssert(description.internalReference.reference === mutableCopy.internalReference.reference)
        XCTAssert(mutableCopy.name == description.name)
        let newValue = "New value"
        mutableCopy.name = newValue
        XCTAssert(mutableCopy.name != description.name)
        XCTAssert(description.name != newValue)
        XCTAssert(mutableCopy.name == newValue)
        XCTAssert(description.internalReference.reference !== mutableCopy.internalReference.reference)
        XCTAssert(description.internalReference.reference.rawPointer != mutableCopy.internalReference.reference.rawPointer)
        XCTAssert(unmutatedCopy.internalReference.reference !== mutableCopy.internalReference.reference)
        XCTAssert(unmutatedCopy2.internalReference.reference !== mutableCopy.internalReference.reference)
        XCTAssert(description.internalReference.reference === unmutatedCopy.internalReference.reference)
        XCTAssert(description.internalReference.reference === unmutatedCopy2.internalReference.reference)
        XCTAssert(unmutatedCopy.internalReference.reference === unmutatedCopy2.internalReference.reference)
    }
}
