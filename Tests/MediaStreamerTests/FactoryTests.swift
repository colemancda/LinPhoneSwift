//
//  FactoryTests.swift
//  LinPhoneTests
//
//  Created by Alsey Coleman Miller on 6/30/17.
//
//

import XCTest
@testable import MediaStreamer

final class FactoryTests: XCTestCase {
    
    static var allTests = [
        ("testLibraries", testLibraries),
        ]
    
    func testLibraries() {
        
        let factory = MediaStreamer.Factory()
        
        factory.loadPlugins()
        
        #if os(iOS)
        factory.load(MediaLibrary.all)
        #endif
    }
}
