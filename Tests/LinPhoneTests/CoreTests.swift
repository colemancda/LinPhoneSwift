//
//  Core.swift
//  LinPhoneTests
//
//  Created by Alsey Coleman Miller on 6/30/17.
//
//

import Foundation
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
    
    func testOutgoingCallToFakeServer() {
        
        enableCoreLogging(for: self)
        
        let streamsRunningExpectation = self.expectation(description: "Call streams running")
        
        let videoFrameDecodedExpectation = self.expectation(description: "Video frame decoded")
        
        let callbacks = Core.Callbacks()
        
        callbacks.callStateChanged = {
            
            let state = $0.2
            
            print("Call state changed to \(state)")
            
            let call = $0.1
            
            switch state {
                
            case .streamsRunning:
                
                streamsRunningExpectation.fulfill()
                
            default: break
            }
        }
        
        let core = Core(callbacks: callbacks)!
        
        let destinationURI = "sip:testOutgoingCallToFakeServer@127.0.0.1:8081;transport=tcp"
        
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
    
    func testCaller() {
        
        // Based on https://github.com/BelledonneCommunications/linphone/blob/e4149d19a8c2f85ebe5933cda34c3bf8dbbd9320/tester/call_single_tester.c#L675
        
        enableCoreLogging(for: self)
        
        /// Test core wrapper for making and receiving calls
        class Caller {
            
            let name: String
            
            let core: Core
            
            private var timer: Timer?
            
            let streamsRunningExpectation: XCTestExpectation
            
            deinit {
                
                timer?.invalidate()
            }
            
            init(name: String,
                 streamsRunningExpectation: XCTestExpectation) {
                
                self.name = name
                self.streamsRunningExpectation = streamsRunningExpectation
                
                let callbacks = Core.Callbacks()
                
                self.core = Core(callbacks: callbacks)!
                self.core.isIPv6Enabled = true
                
                callbacks.callStateChanged = { [weak self] in self?.call($0.1, stateChanged: $0.2, message: $0.3) }
                
                self.timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] _ in self?.iterate() }
            }
            
            func callLocalhost() -> Call? {
                
                let address = Address(rawValue: "sip:[::1];transport=tcp")!
                
                return core.invite(address)
            }
            
            private func iterate() {
                
                core.iterate()
                
                
            }
            
            private func call(_ call: Call?, stateChanged state: Call.State, message: String?) {
                
                print("\(name): Call state changed to \(state)")
                
                switch state {
                    
                case .incomingReceived:
                    
                    call?.accept()
                    
                case .streamsRunning:
                    
                    streamsRunningExpectation.fulfill()
                    
                default: break
                }
            }
        }
        
        let caller = Caller(name: "TestCaller",
                            streamsRunningExpectation: self.expectation(description: "Streams running"))
        
        let receiver = Caller(name: "TestReciever",
                              streamsRunningExpectation: self.expectation(description: "Streams running"))
        
        // parse address and create new call
        guard let call = caller.callLocalhost()
            else { XCTFail(); return }
        
        let videoFrameDecodedExpectation = self.expectation(description: "Video frame decoded")
        
        call.nextVideoFrameDecoded = { _ in videoFrameDecodedExpectation.fulfill() }
        
        waitForExpectations(timeout: 15, handler: nil)
    }
}

// MARK: - Helpers

private extension CoreTests {
    
    func enableCoreLogging(for testCase: XCTestCase) {
        
        Core.log = { print("\(testCase): LinPhone.Core:", $0.1) }
        
        LinPhoneSwift.Core.setLogLevel([ORTP_DEBUG, ORTP_MESSAGE, ORTP_WARNING, ORTP_ERROR, ORTP_FATAL])
    }
}
