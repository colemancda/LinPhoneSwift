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
    
    @_versioned
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
    
    // Documentation is unclear on memory and value semantics.
    // Does `Core` own the config? Or are its values just populated from it?
     
     /// Instantiates a `Linphone.Configuration` object from a user config file.
     public convenience init?(filename: String, core: Core) {
        
        guard let rawPointer = linphone_core_create_config(core.rawPointer, filename)
            else { return nil }
        
        self.init(ManagedPointer(InternalPointer(rawPointer)))
     }
    
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
    
    // MARK: - Methods
    
    /// Reads a user configuration file and fills the reciever with the read configuration values.
    @inline(__always)
    public func read(file filename: String) -> Bool {
        
        return linphone_config_read_file(rawPointer, filename) == 0
    }
    
    /*
    /// Reads a user configuration file and fills the reciever with the read configuration values.
    @inline(__always)
    public func readRelative(file filename: String) -> Bool {
        
        return linphone_config_read_relative_file(rawPointer, filename) == 0
    }*/
    
    /// Whether file exists relative to the to the current location.
    @inline(__always)
    public func relativeFileExists(_ filename: String) -> Bool {
        
        return linphone_config_relative_file_exists(rawPointer, filename).boolValue
    }
    
    // MARK: - Setters
    
    /// Set the value for the specified key and section in the configuration file.
    @inline(__always)
    public func setValue(_ value: Float, for key: String, in section: String) {
        
        linphone_config_set_float(rawPointer, section, key, value)
    }
    
    /// Set the value for the specified key and section in the configuration file.
    @inline(__always)
    public func setValue(_ value: Int64, for key: String, in section: String) {
        
        linphone_config_set_int64(rawPointer, section, key, value)
    }
    
    /// Set the value for the specified key and section in the configuration file.
    /// 
    /// - Note: Sets an integer config item, but stores it as hexadecimal
    @inline(__always)
    public func setHexadecimalValue(_ value: Int32, for key: String, in section: String) {
        
        linphone_config_set_int_hex(rawPointer, section, key, value)
    }
    
    /// Sets the overwrite flag for a config item (used when dumping config as xml).
    @inline(__always)
    public func setOverwriteFlag(_ flag: Bool, for key: String, in section: String) {
        
        linphone_config_set_overwrite_flag_for_entry(rawPointer, section, key, bool_t(flag))
    }
    
    /// Sets the overwrite flag for a config section (used when dumping config as xml).
    @inline(__always)
    public func setOverwriteFlag(_ flag: Bool, for section: String) {
        
        linphone_config_set_overwrite_flag_for_section(rawPointer, section, bool_t(flag))
    }
    
    /// Sets a range config item.
    @inline(__always)
    public func setValue(_ range: ClosedRange<Int32>, for key: String, in section: String) {
        
        linphone_config_set_range(rawPointer, section, key, range.lowerBound, range.upperBound)
    }
    
    /// Sets the skip flag for a config item (used when dumping config as xml).
    @inline(__always)
    public func setSkipFlag(_ flag: Bool, for key: String, in section: String) {
        
        linphone_config_set_skip_flag_for_entry(rawPointer, section, key, bool_t(flag))
    }
    
    /// Sets the skip flag for a config item (used when dumping config as xml).
    @inline(__always)
    public func setSkipFlag(_ flag: Bool, for section: String) {
        
        linphone_config_set_skip_flag_for_section(rawPointer, section, bool_t(flag))
    }
    
    /// Set the string value for the specified key and section in the configuration file.
    @inline(__always)
    public func setValue(_ value: String, for key: String, in section: String) {
        
        linphone_config_set_string(rawPointer, section, key, value)
    }
    
    /// Set the string list value for the specified key and section in the configuration file.
    @inline(__always)
    public func setValue(_ value: StringList, for key: String, in section: String) {
        
        linphone_config_set_string(rawPointer, section, key, value)
    }
    
    // MARK: - Getters
    
    
    
    // MARK: - Subcripting
    
    
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
