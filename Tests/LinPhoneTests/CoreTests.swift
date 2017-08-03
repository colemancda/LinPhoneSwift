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
import func CMediaStreamer2.ms_video_set_scaler_impl

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
        #elseif os(macOS)
        let view = NSView()
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
                
                #if os(iOS)
                    
                    self.core.withMediaStreamerFactory { $0.load(MediaLibrary.all) }
                    
                    self.core.withMediaStreamerFactory { $0.enableHardwareH264(false) }
                    
                #else
                    
                    self.core.withMediaStreamerFactory { $0.enableHardwareH264() }
                    
                #endif
                
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
        
        #if os(iOS)
            
        self.withMediaStreamerFactory { $0.load(MediaLibrary.all) }
        
        self.withMediaStreamerFactory { $0.enableHardwareH264(false) }
            
        self.reloadMediaStreamerPlugins()
            
        #else
            
        self.withMediaStreamerFactory { $0.enableHardwareH264() }
            
        #endif
        
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
        
        /// Set fake media streamer scaler implementation
        ms_video_set_scaler_impl(&FakeMediaStreamerScaler)
        
        return true
    }
}

extension MediaStreamer.Factory {
    
    func enableHardwareH264(_ hardwareOn: Bool = true) {
        
        func forceFilter(_ filterName: String, _ isEnabled: Bool) {
            
            guard enableFilter(isEnabled, for: filterName) else {
                
                // only crash if trying to enable
                if isEnabled {
                    
                    fatalError("Could not enable filter \(filterName)")
                }
                
                return
            }
        }
        
        forceFilter("VideoToolboxH264Decoder", hardwareOn)
        forceFilter("VideoToolboxH264Encoder", hardwareOn)
        forceFilter("MSOpenH264Dec", hardwareOn == false)
        forceFilter("MSOpenH264Enc", hardwareOn == false)
    }
}

private var FakeMediaStreamerScaler = MSScalerDesc(create_context: FakeMediaStreamerScalerContextCreate,
                                                          context_process: FakeMediaStreamerScalerContextProcess,
                                                          context_free: FakeMediaStreamerScalerContextFree)

/// MSScalerContext * ms_fake_scaler_create_context(int src_w, int src_h, MSPixFmt src_fmt,
/// int dst_w, int dst_h, MSPixFmt dst_fmt, int flags) { return NULL; }
@_silgen_name("ms_fake_scaler_create_context")
private func FakeMediaStreamerScalerContextCreate(src_w: CInt , src_h: CInt , src_fmt: MSPixFmt,
                   dst_w: CInt , dst_h: CInt , dst_fmt: MSPixFmt, flags: CInt) -> OpaquePointer? { return nil }

/// int ms_fake_scaler_context_process(MSScalerContext *ctx, uint8_t *src[], int src_strides[],
/// uint8_t *dst[], int dst_strides[]) { return 0; }
@_silgen_name("ms_fake_scaler_context_process")
private func FakeMediaStreamerScalerContextProcess(_: OpaquePointer?, _: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>?, _: UnsafeMutablePointer<Int32>?, _: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>?, _: UnsafeMutablePointer<Int32>?) -> Int32 { return 0 }

/// void ms_fake_scaler_context_free(MSScalerContext *ctx) {}
@_silgen_name("ms_fake_scaler_context_free")
private func FakeMediaStreamerScalerContextFree(_: OpaquePointer?) { }
