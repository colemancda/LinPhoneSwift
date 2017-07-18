//
//  Core.swift
//  LinPhoneTests
//
//  Created by Alsey Coleman Miller on 6/30/17.
//
//

import XCTest
@testable import LinPhoneSwift
import CLinPhone

final class CoreTests: XCTestCase {
    
    static var allTests = [
        ("testVersion", testVersion),
        ]
    
    func testVersion() {
        
        let version = LinPhoneSwift.Core.version
        
        print("Linphone version:", version)
        
        XCTAssert(version.isEmpty == false)
    }
    
    func testFakeServer() {
        
        let streamsRunningExpectation = self.expectation(description: "Call streams running")
        
        let videoFrameDecodedExpectation = self.expectation(description: "Video frame decoded")
        
        Core.log = { print("\(self): LinPhoneSwift.Core:", $0.1) }
        
        LinPhoneSwift.Core.setLogLevel([ORTP_DEBUG, ORTP_MESSAGE, ORTP_WARNING, ORTP_ERROR, ORTP_FATAL])
        
        let callbacks = Core.Callbacks()
        
        callbacks.callStateChanged = {
            
            let state = $0.2
            
            print("Call state changed to \(state)")
            
            let call = $0.1
            
            switch state {
                
            case .incomingReceived:
                
                call?.accept()
                
            case .streamsRunning:
                
                streamsRunningExpectation.fulfill()
                
            default: break
            }
        }
        
        let core = Core(callbacks: callbacks)!
        
        let destinationURI = "sip:test1@127.0.0.1:8081;transport=tcp"
        
        // parse address and create new call
        guard let address = Address(rawValue: destinationURI),
            let call = core.invite(address)
            else { XCTFail(); return }
        
        call.nextVideoFrameDecoded = { _ in videoFrameDecodedExpectation.fulfill() }
        
        // run main loop
        let timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in core.iterate() }
        
        defer { timer.invalidate() }
        
        waitForExpectations(timeout: 15, handler: nil)
    }
}
