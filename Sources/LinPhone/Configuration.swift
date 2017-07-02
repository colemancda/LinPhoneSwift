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
    
    internal let managedPointer: ManagedPointer<InternalPointer>
    
    // MARK: - Initialization
    
    internal init(_ managedPointer: ManagedPointer<InternalPointer>) {
        
        self.managedPointer = managedPointer
    }
    
    /// Instantiates a `Linphone.Configuration` object from a user config file.
    public convenience init?(filename: String) {
        
        guard let rawPointer = linphone_config_new(filename)
            else { return nil }
        
        self.init(ManagedPointer(InternalPointer(rawPointer)))
    }
    
    /// Instantiates a `Linphone.Configuration` object from a user config file.
    public convenience init?(filename: String, core: Core) {
        
        guard let rawPointer = linphone_core_create_config(core.rawPointer, filename)
            else { return nil }
        
        self.init(ManagedPointer(InternalPointer(rawPointer)))
    }
}

// MARK: - Internal

extension Configuration: ManagedHandle {
    
    typealias RawPointer = InternalPointer.RawPointer
    
    struct InternalPointer: LinPhoneSwift.InternalPointer {
        
        let rawPointer: OpaquePointer
        
        @inline(__always)
        init(_ rawPointer: InternalPointer.RawPointer) {
            
            self.rawPointer = rawPointer
        }
        
        @inline(__always)
        func retain() {
            linphone_config_ref(rawPointer)
        }
        
        @inline(__always)
        func release() {
            linphone_config_unref(rawPointer)
        }
    }
}
