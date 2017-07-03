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
public struct Configuration {
    
    // MARK: - Properties
    
    internal private(set) var internalReference: CopyOnWrite<Reference>
    
    // MARK: - Initialization
    
    internal init(_ internalReference: Reference) {
        
        self.internalReference = CopyOnWrite(internalReference)
    }
    
    /// Instantiates a `Linphone.Configuration` object from a user provided string.
    public init?(string: String) {
        
        guard let reference = Reference(string: string)
            else { return nil }
        
        self.init(reference)
    }
    
    /// Instantiates a `Linphone.Configuration` object from a user config file.
    public init?(filename: String) {
        
        guard let reference = Reference(filename: filename)
            else { return nil }
        
        self.init(reference)
    }
    
    /// Instantiates a `Linphone.Configuration` object from a user config file and a factory config file.
    ///
    /// The user config file is read first to fill the `Linphone.Configuration` and then the factory config file is read.
    /// Therefore the configuration parameters defined in the user config file will be overwritten
    /// by the parameters defined in the factory config file.
    public init?(filename: String, factoryFilename: String) {
        
        guard let reference = Reference(filename: filename, factoryFilename: factoryFilename)
            else { return nil }
        
        self.init(reference)
    }
    
    
    
    
}

// MARK: - Internal

extension Configuration: ReferenceConvertible {
    
    public final class Reference {
        
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
        
        /* Documentation is unclear on memory and value semantics. 
         Does `Core` own the config? Or are its values just populated from it?
         
        /// Instantiates a `Linphone.Configuration` object from a user config file.
        public convenience init?(filename: String, core: Core) {
            
            guard let rawPointer = linphone_core_create_config(core.rawPointer, filename)
                else { return nil }
            
            self.init(ManagedPointer(InternalPointer(rawPointer)))
        }
        */
        
        /// Instantiates a `Linphone.Configuration` object from a user provided string.
        public convenience init?(string: String) {
            
            guard let rawPointer = linphone_config_new_from_buffer(string)
                else { return nil }
            
            self.init(ManagedPointer(InternalPointer(rawPointer)))
        }
        
        /// Instantiates a `Linphone.Configuration` object from a user config file and a factory config file.
        ///
        /// The user config file is read first to fill the `Linphone.Configuration` and then the factory config file is read. 
        /// Therefore the configuration parameters defined in the user config file will be overwritten 
        /// by the parameters defined in the factory config file.
        public convenience init?(filename: String, factoryFilename: String) {
            
            guard let rawPointer = linphone_config_new_with_factory(filename, factoryFilename)
                else { return nil }
            
            self.init(ManagedPointer(InternalPointer(rawPointer)))
        }
        
        // MARK: - Accessors
        
        
    }
}

extension Configuration.Reference: ManagedHandle {
    
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

extension Configuration.Reference: CopyableHandle {
    
    var copy: Configuration.Reference? {
        
        
    }
}
