//
//  Core.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 6/30/17.
//
//

import CLinPhone

/// LinPhone Core class
public final class Core {
    
    // MARK: - Initialization
    
    internal private(set) var internalPointer: OpaquePointer!
    
    public init(factory: Factory = Factory.shared, callBack: ) {
        
        linphone_factory_create_core(factory.internalPointer,
                                     <#T##cbs: OpaquePointer!##OpaquePointer!#>,
                                     <#T##config_path: UnsafePointer<Int8>!##UnsafePointer<Int8>!#>,
                                     <#T##factory_config_path: UnsafePointer<Int8>!##UnsafePointer<Int8>!#>)
    }
    
    // MARK: - Static Properties / Methods
    
    /// Returns liblinphone's version as a string.
    public static var version: String {
        
        @inline(__always)
        get { return String(cString: linphone_core_get_version()) }
    }
    
    /// Enable logs serialization (output logs from either the thread that creates the 
    /// linphone core or the thread that calls linphone_core_iterate()).
    ///
    /// - Note: Must be called before creating the linphone core.
    @inline(__always)
    public static func serializeLogs() {
        
        linphone_core_serialize_logs()
    }
    
    // MARK: - Accessors
    
    /// The path to a file or folder containing the trusted root CAs (PEM format)
    public var rootCA: String {
        
        get { return String(cString: linphone_core_get_root_ca(internalPointer)) }
        
        set { linphone_core_set_root_ca(internalPointer, newValue) }
    }
    
    /// liblinphone's user agent as a string.
    public var userAgent: String {
        
        get { return String(cString: linphone_core_get_user_agent(internalPointer)) }
        
        set { linphone_core_set_user_agent(<#T##lc: OpaquePointer!##OpaquePointer!#>, <#T##ua_name: UnsafePointer<Int8>!##UnsafePointer<Int8>!#>, <#T##version: UnsafePointer<Int8>!##UnsafePointer<Int8>!#>) }
    }
}

// MARK: - Supporting Types

public extension Core {
    
    public final class Callback {
        
        
    }
}
