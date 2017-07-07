//
//  Manager.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/6/17.
//
//

import Foundation
import AVFoundation
import CoreTelephony
import UIKit
import MediaStreamer

/// Integrates LinPhone with iOS services (e.g. AVFoundation, CallKit).
public final class LinPhoneManager {
    
    // MARK: - Properties
    
    public var log: ((String) -> ())?
    
    public let configurationPath: String?
    
    public let factoryConfigurationPath: String?
    
    public let rootCAPath: String
    
    public let userCertificatesPath: String
    
    public var iterateTimeInterval: TimeInterval = 0.02 // set timer for 200 ms
    
    public private(set) var state = State()
    
    private lazy var audioSession = AVAudioSession.sharedInstance()
    
    private var callCenter: CTCallCenter?
    
    private var core: Core?
    
    private var coreCallbacks: Core.Callbacks?
    
    private var iterateTimer: Timer?
    
    // MARK: - Initialization
    
    public init?(rootCAPath: String,
                 userCertificatesPath: String,
                 configurationPath: String? = nil,
                 factoryConfigurationPath: String? = nil) {
        
        self.rootCAPath = rootCAPath
        self.userCertificatesPath = userCertificatesPath
        self.configurationPath = configurationPath
        self.factoryConfigurationPath = factoryConfigurationPath
    }
    
    // MARK: - Methods
    
    public func start() throws {
        
        guard state != .started
            else { return }
        
        //connectivity = .none
        
        signal(SIGPIPE, SIG_IGN)
        
        try createLinphoneCore()
        
        do { try audioSession.setActive(false) }
            
        catch { throw Error.audioSessionActive(false, error) }
        
        guard audioSession.isInputAvailable
            else { throw Error.missingAudioInput }
        
        if UIApplication.shared.applicationState == .background {
            
            enterBackgroundMode()
        }
        
        // set new state
        state = .started
    }
    
    public func reset() throws {
        
        self.core = nil
        self.coreCallbacks = nil
        
        destroyLinphoneCore()
        try createLinphoneCore()
    }
    
    // MARK: - Private Methods
    
    private func createLinphoneCore() throws {
        
        // Initialize Core and its callbacks.
        // Must keep a reference to the callbacks object.
        let coreCallbacks = Core.Callbacks()
        
        guard let core = Core(callbacks: coreCallbacks,
                              configurationPath: configurationPath,
                              factoryConfigurationPath: factoryConfigurationPath)
            else { throw Error.coreInitializationFailed }
        
        self.coreCallbacks = coreCallbacks
        self.core = core
        
        configureCoreCallbacks()
        
        /// Load plugins if available in the linphone SDK - otherwise these calls will do nothing
        core.withMediaStreamerFactory { $0.load([.amr, .x264, .openh264, .silk, .bcg729, .webrtc]) }
        core.reloadMediaStreamerPlugins()
        
        // Call iterate once immediately in order to initiate background connections with sip server or remote provisioning.
        core.iterate()
        
        let timer: Timer
        if #available(iOS 10, *) {
            
            timer = Timer.scheduledTimer(withTimeInterval: iterateTimeInterval, repeats: true) { [weak self] _ in self?.iterate() }
            
        } else {
            
            timer = Timer.scheduledTimer(timeInterval: iterateTimeInterval,
                                         target: self,
                                         selector: #selector(iterate),
                                         userInfo: nil,
                                         repeats: true)
        }
        
        self.iterateTimer = timer
    }
    
    private func destroyLinphoneCore() {
        
        self.iterateTimer?.invalidate()
        self.state = State()
        
        guard let core = self.core
            else { return }
        
        self.core = nil
        self.coreCallbacks = nil
        self.callCenter?.callEventHandler = nil
        self.callCenter = nil
    }
    
    private func enterBackgroundMode() {
        
        
    }
    
    @objc private func iterate() {
        
        self.core?.iterate()
    }
    
    // MARK: Callbacks
    
    private func configureCoreCallbacks() {
        
        coreCallbacks?.callStateChanged = { [weak self] in self?.call($0.1, stateChanged: $0.2, message: $0.3) }
    }
    
    private func call(_ call: Call, stateChanged state: Call.State, message: String?) {
        
        let address = call.remoteAddress
        
        
    }
}

public extension LinPhoneManager {
    
    public enum State {
        
        case ready
        case started
        
        public init() { self = .ready }
    }
    
    public enum Error: Swift.Error {
        
        /// Could not initialize the `LinPhone.Core` object.
        case coreInitializationFailed
        
        /// Could not activate / disable audio session.
        case audioSessionActive(Bool, Swift.Error)
        
        /// No audio input availible on system.
        case missingAudioInput
    }
}
