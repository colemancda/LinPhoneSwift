//
//  AddressTests.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/9/17.
//
//

import XCTest
@testable import LinPhone

final class AddressTests: XCTestCase {

    func testParsingNil() {
        
        let rawValues = ["sip:@sip.linphone.org",
                         "",
                         "google.com"]
        
        for rawValue in rawValues {
            
            XCTAssert(Address(rawValue: rawValue) == nil, rawValue)
        }
    }
    
    func testParsing() {
        
        let rawValues = ["sip:toto@titi",
                         "sips:toto@titi",
                         "sip:toto@titi;transport=tcp",
                         "sip:toto@titu",
                         "sip:toto@titi;transport=udp",
                         "sip:toto@titi?X-Create-Account=yes"]
        
        for rawValue in rawValues {
            
            guard let _ = Address(rawValue: rawValue)
                else { XCTFail("Could not create address \(rawValue)"); return }
            
            //XCTAssert(address.rawValue == rawValue, "\(address.rawValue) != \(rawValue)")
        }
    }
    
    func testValueSemantics() {
        
        let rawValue = "sip:toto@titi"
        
        guard let address = Address(rawValue: rawValue)
            else { XCTFail("Could not create address \(rawValue)"); return }
        
        let unmutatedCopy = address
        let unmutatedCopy2 = unmutatedCopy
        XCTAssert(address.internalReference.reference === unmutatedCopy.internalReference.reference)
        XCTAssert(address.internalReference.reference.unmanagedPointer.rawPointer == unmutatedCopy.internalReference.reference.unmanagedPointer.rawPointer)
        XCTAssert(address.internalReference.reference === unmutatedCopy2.internalReference.reference)
        XCTAssert(unmutatedCopy.internalReference.reference === unmutatedCopy2.internalReference.reference)
        
        var mutableCopy = address
        XCTAssert(address.internalReference.reference === mutableCopy.internalReference.reference)
        mutableCopy.port = 8080
        mutableCopy.clean()
        XCTAssert(address.internalReference.reference !== mutableCopy.internalReference.reference)
        XCTAssert(address.internalReference.reference.unmanagedPointer.rawPointer != mutableCopy.internalReference.reference.unmanagedPointer.rawPointer)
        XCTAssert(unmutatedCopy.internalReference.reference !== mutableCopy.internalReference.reference)
        XCTAssert(unmutatedCopy2.internalReference.reference !== mutableCopy.internalReference.reference)
        XCTAssert(address.internalReference.reference === unmutatedCopy.internalReference.reference)
        XCTAssert(address.internalReference.reference === unmutatedCopy2.internalReference.reference)
        XCTAssert(unmutatedCopy.internalReference.reference === unmutatedCopy2.internalReference.reference)
    }
}
