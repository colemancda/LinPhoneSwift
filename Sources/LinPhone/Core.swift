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
    
    // MARK: - Properties
    
    @_versioned
    internal let internalPointer: OpaquePointer
    
    // MARK: - Initialization
    
    deinit {
        
        linphone_core_unref(internalPointer)
    }
    
    public init?(factory: Factory = Factory.shared,
                callBack: Callback,
                configurationPath: String? = nil,
                factoryConfigurationPath: String? = nil) {
        
        guard let internalPointer = linphone_factory_create_core(factory.internalPointer,
                                     callBack.internalPointer,
                                     configurationPath,
                                     factoryConfigurationPath)
            else { return nil }
        
        self.internalPointer = internalPointer
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
        
        @inline(__always)
        get { return String(cString: linphone_core_get_root_ca(internalPointer)) }
        
        @inline(__always)
        set { linphone_core_set_root_ca(internalPointer, newValue) }
    }
    
    /// liblinphone's user agent as a string.
    public var userAgent: String {
        
        @inline(__always)
        get { return getString(linphone_core_get_user_agent) }
    }
    
    /// Sets the user agent string used in SIP messages.
    @inline(__always)
    public func setUserAgent(name: String, version: String) {
        
         linphone_core_set_user_agent(internalPointer, name, version)
    }
    
    /// Returns the `Configuration` object used to manage the storage (config) file.
    public var configuration: Configuration? {
        
        guard let reference = linphone_core_get_config(internalPointer)
            else { return nil }
        
        // increment reference count (since wrapper class will decrement when dealloc)
        linphone_config_ref(reference)
        
        return Configuration(reference)
    }
    
    /// Specify whether the tls server certificate common name must be verified when connecting to a SIP/TLS server.
    @inline(__always)
    public func shouldVerifyServerConnection(_ newValue: Bool) {
        
        linphone_core_verify_server_cn(internalPointer, bool_t(newValue))
    }
    
    /// Specify whether the tls server certificate must be verified when connecting to a SIP/TLS server.
    @inline(__always)
    public func shouldVerifyServerCertificates(_ newValue: Bool) {
        
        linphone_core_verify_server_certificates(internalPointer, bool_t(newValue))
    }
    
    public var zrtpSecretsFile: String? {
        
        @inline(__always)
        get { return getString(linphone_core_get_zrtp_secrets_file) }
        
        @inline(__always)
        set { setString(linphone_core_set_zrtp_secrets_file, newValue) }
    }
    
    // MARK: - Methods
    
    /// Upload the log collection to the configured server url.
    @inline(__always)
    public func uploadLogCollection() {
        
        linphone_core_upload_log_collection(internalPointer)
    }
}

extension Core: Handle { }

// MARK: - Supporting Types

public extension Core {
    
    /// That class holds all the callbacks which are called by `Linphone.Core`.
    public final class Callback {
        
        // MARK: - Properties
        
        internal let internalPointer: OpaquePointer
        
        // MARK: - Initialization
        
        public init(factory: Factory = Factory.shared) {
            
            self.internalPointer = linphone_factory_create_core_cbs(factory.internalPointer)
        }
        
        // MARK: - Methods
        
        
    }
}

public extension Core {
    
    public final class vTable {
        
        // MARK: - Properties
        
        internal let internalPointer: UnsafeMutablePointer<LinphoneCoreVTable>
        
        // MARK: - Initialization
        
        deinit {
            
            linphone_core_v_table_destroy(internalPointer)
        }
        
        public init() {
            
            self.internalPointer = linphone_core_v_table_new()
        }
    }
}
