//
//  Core.swift
//  LinPhoneTests
//
//  Created by Alsey Coleman Miller on 6/30/17.
//
//

#if os(macOS) || os(iOS)
    import Darwin.C.stdlib
#elseif os(Linux)
    import Glibc
#endif

import Foundation
import XCTest
@testable import LinPhoneSwift
import MediaStreamer
import CLinPhone

final class CoreTests: XCTestCase {
    
    static var allTests = [
        ("testVersion", testVersion),
        ("testOutgoingCallToFakeServer", testOutgoingCallToFakeServer),
        ("testDirectCall", testDirectCall),
        ]
    
    func testVersion() {
        
        let version = LinPhoneSwift.Core.version
        
        print("Linphone version:", version)
        
        XCTAssert(version.isEmpty == false)
    }
    
    func testOutgoingCallToFakeServer() {
        
        enableCoreLogging()
        
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
        
        let core = Core(callbacks: callbacks)
        
        guard core.configureForFakeServer()
            else { XCTFail(); return }
        
        let serverIP = "127.0.0.1"
        
        let sipFrom = Address(rawValue: "sip:1-2@" + serverIP + ":8081")!
        core.primaryContact = sipFrom
        
        let sipTo = Address(rawValue: "sip:1-2@" + serverIP + ":8081;transport=tcp")!
        
        // parse address and create new call
        guard let call = core.invite(sipTo)
            else { XCTFail(); return }
        
        defer { call.terminate() }
        
        #if os(iOS)
        let view = UIView()
        call.nativeWindow = view
        #endif
        
        call.nextVideoFrameDecoded = { _ in videoFrameDecodedExpectation.fulfill() }
        
        // run main loop
        let timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in core.iterate() }
        
        defer { timer.invalidate() }
        
        waitForExpectations(timeout: 15, handler: nil)
    }
    
    func testDirectCall() {
        
        // Based on https://github.com/BelledonneCommunications/linphone/blob/e4149d19a8c2f85ebe5933cda34c3bf8dbbd9320/tester/call_single_tester.c#L675
        
        enableCoreLogging()
        
        /// Object for making and receiving calls on localhost (.e.g 127.0.0.1)
        class Caller {
            
            let name: String
            
            let core: Core
            
            private var timer: Timer?
            
            let streamsRunningExpectation: XCTestExpectation
            
            let outgoingRingingExpectation: XCTestExpectation?
            
            let incomingRecievedExpectation: XCTestExpectation?
            
            deinit {
                
                timer?.invalidate()
            }
            
            init(name: String, expectOutgoingCall: Bool, test: XCTestCase) {
                
                // create expectations
                
                self.streamsRunningExpectation = test.expectation(description: "\(name) Streams running")
                
                if expectOutgoingCall {
                    
                    self.outgoingRingingExpectation = test.expectation(description: "\(name) Outgoing call")
                    self.incomingRecievedExpectation = nil
                    
                } else {
                    
                    self.incomingRecievedExpectation = test.expectation(description: "\(name) incoming call received")
                    self.outgoingRingingExpectation = nil
                }
                
                // set properties
                
                self.name = name
                
                let callbacks = Core.Callbacks()
                
                self.core = Core(callbacks: callbacks)
                
                self.core.sipTransports.tcp = SipTransports.random
                
                callbacks.callStateChanged = { [weak self] in self?.call($0.1, stateChanged: $0.2, message: $0.3) }
                
                self.timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] _ in self?.iterate() }
            }
            
            func call(_ other: Caller) -> Call? {
                
                // localhost address
                var address = Address(rawValue: "sip:127.0.0.1;transport=tcp")!
                
                address.port = other.core.usedSipTransports.tcp
                
                print("Calling \(other.name) \(address)")
                
                return core.invite(address)
            }
            
            private func iterate() {
                
                core.iterate()
            }
            
            private func call(_ call: Call?, stateChanged state: Call.State, message: String?) {
                
                print("\(name): Call state changed to \(state)")
                
                switch state {
                    
                case .incomingReceived:
                    
                    incomingRecievedExpectation?.fulfill()
                    
                    let call = core.currentCall!
                    
                    guard call.accept()
                        else { XCTFail("Could not accept incoming call"); return }
                    
                case .outgoingRinging, .outgoingProgress:
                    
                    outgoingRingingExpectation?.fulfill()
                    
                case .streamsRunning:
                    
                    streamsRunningExpectation.fulfill()
                    
                default: break
                }
            }
        }
        
        // create caller and reciever, and make call on local device
        
        let caller = Caller(name: "TestCaller",
                            expectOutgoingCall: true,
                            test: self)
        
        let receiver = Caller(name: "TestReceiver",
                              expectOutgoingCall: false,
                              test: self)
        
        // parse address and create new call
        guard let call = caller.call(receiver)
            else { XCTFail(); return }
        
        defer { call.terminate() }
        
        waitForExpectations(timeout: 15, handler: nil)
    }
}

// MARK: - Helpers

private extension XCTestCase {
    
    func enableCoreLogging() {
        
        Core.log = { print("\(self): LinPhone.Core:", $0.1) }
        
        LinPhoneSwift.Core.setLogLevel([ORTP_DEBUG, ORTP_MESSAGE, ORTP_WARNING, ORTP_ERROR, ORTP_FATAL])
    }
}

extension pid_t {
    
    static func execute(launchPath: String, arguments: String = "") -> pid_t {
        
        var args = [launchPath, arguments]
        
        let argv : UnsafeMutablePointer<UnsafeMutablePointer<Int8>?> = args.withUnsafeBufferPointer {
            let array : UnsafeBufferPointer<String> = $0
            let buffer = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: array.count + 1)
            buffer.initialize(from: array.map { $0.withCString(strdup) })
            buffer[array.count] = nil
            return buffer
        }
        
        defer {
            for arg in argv ..< argv + args.count {
                free(UnsafeMutableRawPointer(arg.pointee))
            }
            
            argv.deallocate(capacity: args.count + 1)
        }
        
        var pid = pid_t()
        
        guard posix_spawnp(&pid, launchPath, nil, nil, argv, nil) == 0
            else { fatalError("Could not execute \(launchPath): \(errno)") }
        
        return pid
    }
    
    func terminate() {
        
        kill(self, SIGKILL)
    }
}

extension LinPhoneSwift.Core {
    
    func configureForFakeServer() -> Bool {
        
        self.audioPort = -1
        self.videoPort = -1
        self.mediaEncryption = .none
        self.audioJitter = 0
        self.videoJitter = 0
        self.isAudioAdaptiveJittCompensationEnabled = true
        self.isVideoAdaptiveJittCompensationEnabled = true
        self.noXmitOnAudioMute = false
        
        self.withMediaStreamerFactory { $0.load(MediaLibrary.all) }
        
        guard self.withMediaStreamerFactory({ $0.enableFilter(true, for: "MSOpenH264Dec") })
            else { return false }
        
        self.reloadMediaStreamerPlugins()
        
        // "accept_video_preference", "start_video_preference"
        self.videoPolicy = VideoPolicy(automaticallyAccept: true,
                                       automaticallyStart: true)
        
        // "h264_preference"
        if let h264Payload = self.videoPayloadTypes.first(where: { $0.mimeType == "H264" }) {
            
            h264Payload.isEnabled = true
        }
        
        // "sipinfo_dtmf_preference"
        self.sipInfoDTMF = true
        
        // "rfc_dtmf_preference"
        self.rfc2833DTMF = false
        
        // "nowebcam_uses_normal_fps"
        self.configuration.set(true, for: "nowebcam_uses_normal_fps", in: "video")
        
        self.isEchoCancellationEnabled = false
        self.isEchoLimiterEnabled = false
        
        self.shouldVerifyServerCertificates(false)
        self.sipTransportTimeout = 20000
        self.videoPort = -1
        self.audioPort = -1
        self.videoDevice = "StaticImage: Static picture"
        self.preferredVideoSize = MSVideoSize(width: MS_VIDEO_SIZE_QCIF_W,
                                              height: MS_VIDEO_SIZE_QCIF_H)
        self.preferredFramerate = 5
        self.isIPv6Enabled = true
        
        self.setUserAgent(name: "iOS", version: "1.3")
        
        return true
    }
}
