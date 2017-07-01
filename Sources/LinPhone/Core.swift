//
//  Core.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 6/30/17.
//
//

import CLinPhone
import struct Foundation.Data

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
    
    /// Tells whether the linphone core log collection is enabled.
    public var isLogCollectionEnabled: LinphoneLogCollectionState {
        
        return linphone_core_log_collection_enabled()
    }
    
    // MARK: - Accessors
    
    /// The path to a file or folder containing the trusted root CAs (PEM format)
    public var rootCA: String? {
        
        @inline(__always)
        get { return getString(linphone_core_get_root_ca) }
        
        @inline(__always)
        set { setString(linphone_core_set_root_ca, newValue) }
    }
    
    /// liblinphone's user agent as a string.
    public var userAgent: String? {
        
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
        
        // get handle pointer
        guard let configInternalPointer = linphone_core_get_config(internalPointer)
            else { return nil }
        
        // get associated swift object
        
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
    
    /// The path to the file storing the zrtp secrets cache.
    public var zrtpSecretsFile: String? {
        
        @inline(__always)
        get { return getString(linphone_core_get_zrtp_secrets_file) }
        
        @inline(__always)
        set { setString(linphone_core_set_zrtp_secrets_file, newValue) }
    }
    
    ///  Set the path to the directory storing the user's x509 certificates (used by dtls).
    public var userCertificatesPath: String? {
        
        @inline(__always)
        get { return getString(linphone_core_get_user_certificates_path) }
        
        @inline(__always)
        set { setString(linphone_core_set_user_certificates_path, newValue) }
    }
    
    /// Externally provided SSL configuration for the crypto library.
    /// 
    /// - Returns: A pointer to an opaque structure which will be provided directly to the crypto library used in `bctoolbox`.
    /// - Warning: Use with extra care. 
    /// This `ssl_config` structure is responsibility of the caller and will not be freed at the connection's end.
    @inline(__always)
    public func configureSSL(_ config: UnsafeMutableRawPointer?) {
        
        linphone_core_set_ssl_config(internalPointer, config)
    }
    
    /// URI where to download xml configuration file at startup.
    /// This can also be set from configuration file or factory config file, from [misc] section, item "config-uri". 
    /// Calling this function does not load the configuration. 
    /// It will write the value into configuration so that configuration from remote URI 
    /// will take place at next LinphoneCore start.
    public var provisioningURI: String? {
        
        @inline(__always)
        get { return getString(linphone_core_get_provisioning_uri) }
    }
    
    /// URI where to download xml configuration file at startup.
    /// This can also be set from configuration file or factory config file, from [misc] section, item "config-uri".
    /// Calling this function does not load the configuration.
    /// It will write the value into configuration so that configuration from remote URI
    /// will take place at next LinphoneCore start.
    @inline(__always)
    public func setProvisioningURI(_ newValue: String?) -> Bool {
        
        return setString(linphone_core_set_provisioning_uri, newValue) == Int32(0)
    }
    
    /// The maximum number of simultaneous calls Linphone core can manage at a time. 
    /// All new call above this limit are declined with a busy answer
    public var maxCalls: Int {
        
        @inline(__always)
        get { return Int(linphone_core_get_max_calls(internalPointer)) }
        
        @inline(__always)
        set { linphone_core_set_max_calls(internalPointer, Int32(newValue)) }
    }
    
    // MARK: - Methods
    
    /// Main loop function. It is crucial that your application call it periodically.
    ///
    /// `iterate()` performs various backgrounds tasks:
    ///
    /// - receiving of SIP messages
    /// - handles timers and timeout
    /// - performs registration to proxies
    /// - authentication retries
    ///
    /// The application MUST call this function periodically, in its main loop.
    /// Be careful that this function must be called from the same thread as other liblinphone methods.
    /// If it is not the case make sure all liblinphone calls are serialized with a mutex. 
    /// For ICE to work properly it should be called every 20ms.
    @inline(__always)
    public func iterate() {
        
        linphone_core_iterate(internalPointer)
    }
    
    /// Upload the log collection to the configured server url.
    @inline(__always)
    public func uploadLogCollection() {
        
        linphone_core_upload_log_collection(internalPointer)
    }
    
    /// Whether a media encryption scheme is supported by the `Linphone.Core` engine.
    @inline(__always)
    public func isMediaEncryptionSupported(_ mediaEncryption: LinphoneMediaEncryption) -> Bool {
        
        return linphone_core_media_encryption_supported(internalPointer, mediaEncryption).boolValue
    }
}

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
    
    public final class VTable {
        
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

// MARK: - Internal

extension Core: Handle { }

extension Core.Callback: Handle { }

extension Core.VTable: Handle { }
