//
//  Manager.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/6/17.
//
//

import Foundation
import AVFoundation
import CallKit
import UIKit

/// Integrates LinPhone with iOS services (e.g. AVFoundation, CallKit).
public final class LinPhoneManager {
    
    // MARK: - Properties
    
    public var log: ((String) -> ())?
    
    public let configurationPath: String?
    
    public let factoryConfigurationPath: String?
    
    public private(set) var state = State()
    
    private var core: Core?
    
    private var coreCallbacks: Core.Callbacks?
    
    private lazy var audioSession = AVAudioSession.sharedInstance()
    
    // MARK: - Initialization
    
    public init?(configurationPath: String? = nil, factoryConfigurationPath: String? = nil) {
        
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
        
        try createLinphoneCore()
    }
    
    // MARK: - Private Methods
    
    private func createLinphoneCore() throws {
        
        let coreCallbacks = Core.Callbacks()
        
        guard let core = Core(callbacks: coreCallbacks, configurationPath: configurationPath, factoryConfigurationPath: factoryConfigurationPath)
            else { throw Error.coreInitializationFailed }
        
        self.coreCallbacks = coreCallbacks
        self.core = core
        
        configureCoreCallbacks()
    }
    
    private func enterBackgroundMode() {
        
        
    }
    
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
