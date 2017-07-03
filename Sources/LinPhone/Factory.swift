//
//  Factory.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/1/17.
//
//

import CLinPhone

/// `LinPhone.Factory` is a singleton object devoted to the creation of all the objects of
/// LinPhone that cannot created by `Linphone.Core` itself.
public final class Factory {
    
    // MARK: - Singleton
    
    public static let shared = Factory()
    
    // MARK: - Properties
    
    internal let rawPointer: OpaquePointer
    
    // MARK: - Initialization
    
    deinit {
        
        // Clean the factory. 
        /// This function is generally useless as the factory is unique per process,
        /// however calling this function at the end avoid getting reports from belle-sip leak detector'
        /// about memory leaked in `linphone_factory_get()`.
        linphone_factory_clean()
    }
    
    /// Create the singleton factory.
    private init() {
        
        self.rawPointer = linphone_factory_get()
    }
}

// MARK: - Internal

extension Factory: Handle { }
