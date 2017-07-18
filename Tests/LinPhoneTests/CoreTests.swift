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
    
    func testSession() {
        
        let expectation = self.expectation(description: "Call success")
        
        let uri = "sip:test1@127.0.0.1;transport=tcp"
        
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
                
                print("Accepted call")
                
            default: break
            }
        }
        
        let core = Core(callbacks: callbacks)!
        
        core.mediaEncryption = .none
        
        // parse address and create new call
        guard let address = Address(rawValue: uri),
            let call = core.invite(address)
            else { XCTFail(); return }
        
        call.nextVideoFrameDecoded = { _ in expectation.fulfill() }
        
        // run main loop
        let timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in core.iterate() }
        
        defer { timer.invalidate() }
        
        wait(for: [expectation], timeout: 15)
    }
}
