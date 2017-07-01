//
//  Configuration.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/1/17.
//
//

import CLinPhone

/// The `LinPhone.Configuration` object is used to manipulate a configuration file.
///
/// The format of the configuration file is a `.ini` like format:
///
/// sections are defined in `[]`
/// each section contains a sequence of `key=value` pairs.
/// Example:
///
/// ```
/// [sound]
/// echocanceler=1
/// playback_dev=ALSA: Default device
/// [video]
/// enabled=1
/// ```
public final class Configuration {
    
    // MARK: - Properties
    
    internal let internalPointer: OpaquePointer
    
    // MARK: - Initialization
    
    deinit {
        
        linphone_config_unref(internalPointer)
    }
    
    internal init(_ internalPointer: OpaquePointer) {
        
        self.internalPointer = internalPointer
    }
    
    /// Instantiates a `Linphone.Configuration` object from a user config file.
    public init?(filename: String) {
        
        guard let internalPointer = linphone_config_new(filename)
            else { return nil }
        
        self.internalPointer = internalPointer
    }
    
    /// Instantiates a `Linphone.Configuration` object from a user config file.
    public init?(filename: String, core: Core) {
        
        guard let internalPointer = linphone_core_create_config(core.internalPointer, filename)
            else { return nil }
        
        self.internalPointer = internalPointer
    }
}
