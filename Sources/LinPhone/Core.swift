//
//  Core.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 6/30/17.
//
//

import CLinPhone
import MediaStreamer

/// LinPhone Core class
public final class Core {
    
    // MARK: - Properties
    
    @_versioned
    internal let managedPointer: ManagedPointer<Core.InternalPointer>
    
    // MARK: - Initialization
    
    internal init(_ managedPointer: ManagedPointer<Core.InternalPointer>) {
        
        self.managedPointer = managedPointer
    }
    
    public convenience init?(factory: Factory = Factory.shared,
                callBacks: Callbacks,
                configurationPath: String? = nil,
                factoryConfigurationPath: String? = nil) {
        
        guard let rawPointer = linphone_factory_create_core(factory.rawPointer,
                                     callBacks.rawPointer,
                                     configurationPath,
                                     factoryConfigurationPath)
            else { return nil }
        
        self.init(ManagedPointer(InternalPointer(rawPointer)))
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
    
    /// Reset the log collection by removing the log files.
    @inline(__always)
    public static func resetLogCollection() {
        
        linphone_core_reset_log_collection()
    }
    
    /// Tells whether the linphone core log collection is enabled.
    public var isLogCollectionEnabled: LinphoneLogCollectionState {
        
        return linphone_core_log_collection_enabled()
    }
    
    /// Define the minimum level for logging.
    @inline(__always)
    public static func setLogLevel(_ logLevel: OrtpLogLevel) {
        
        linphone_core_set_log_level(logLevel)
    }
    
    /// Define the minimum level for logging.
    @inline(__always)
    public static func setLogLevel(_ logLevel: [OrtpLogLevel]) {
        
        let mask = logLevel.reduce(0, { $0 | $1.rawValue })
        
        linphone_core_set_log_level_mask(mask)
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
        
         linphone_core_set_user_agent(rawPointer, name, version)
    }
    
    /// Returns the `Configuration` object used to manage the storage (config) file.
    public lazy var configuration: Configuration? = {
        
        // get handle pointer
        guard let rawPointer = linphone_core_get_config(self.rawPointer)
            else { return nil }
        
        // retain handle because we will release it when swift object is released
        // this will prevent a crash if any other swift object shares the same internal handle,
        let internalPointer = Configuration.InternalPointer(rawPointer)
        internalPointer.retain()
        
        return Configuration(ManagedPointer(internalPointer))
    }()
    
    /// Returns the `MediaStreamer.Factory` used by the `Linphone.Core` to control mediastreamer2 library.
    ///
    /// - Note: The object is only guarenteed to be valid for the lifetime of the closure.
    public func withMediaStreamerFactory<Result>(_ closure: (MediaStreamer.Factory) throws -> Result) rethrows -> Result {
        
        guard let rawPointer = linphone_core_get_ms_factory(self.rawPointer)
            else { fatalError("Nil pointer") }
        
        let factory = MediaStreamer.Factory(rawPointer: rawPointer, isOwner: false)
        
        return try closure(factory)
    }
    
    /// Specify whether the tls server certificate common name must be verified when connecting to a SIP/TLS server.
    @inline(__always)
    public func shouldVerifyServerConnection(_ newValue: Bool) {
        
        linphone_core_verify_server_cn(rawPointer, bool_t(newValue))
    }
    
    /// Specify whether the tls server certificate must be verified when connecting to a SIP/TLS server.
    @inline(__always)
    public func shouldVerifyServerCertificates(_ newValue: Bool) {
        
        linphone_core_verify_server_certificates(rawPointer, bool_t(newValue))
    }
    
    /// Whether video capture is enabled.
    public var isVideoCaptureEnabled: Bool {
        
        @inline(__always)
        get { return linphone_core_video_capture_enabled(rawPointer).boolValue }
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
        
        linphone_core_set_ssl_config(rawPointer, config)
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
    ///
    /// - Parameter uri: The `http` or `https` URI to use in order to download the configuration.
    /// Passing `nil` will disable remote provisioning.
    @inline(__always)
    public func setProvisioningURI(_ uri: String?) -> Bool {
        
        return setString(linphone_core_set_provisioning_uri, uri) == Int32(0)
    }
    
    /// The maximum number of simultaneous calls Linphone core can manage at a time. 
    /// All new call above this limit are declined with a busy answer
    public var maxCalls: Int {
        
        @inline(__always)
        get { return Int(linphone_core_get_max_calls(rawPointer)) }
        
        @inline(__always)
        set { linphone_core_set_max_calls(rawPointer, Int32(newValue)) }
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
        
        linphone_core_iterate(rawPointer)
    }
    
    /// Upload the log collection to the configured server url.
    @inline(__always)
    public func uploadLogCollection() {
        
        linphone_core_upload_log_collection(rawPointer)
    }
    
    /// Whether a media encryption scheme is supported by the `Linphone.Core` engine.
    @inline(__always)
    public func isMediaEncryptionSupported(_ mediaEncryption: LinphoneMediaEncryption) -> Bool {
        
        return linphone_core_media_encryption_supported(rawPointer, mediaEncryption).boolValue
    }
    
    /// Reload `mediastreamer2` plugins from specified directory.
    @inline(__always)
    public func reloadMediaStreamerPlugins(from path: String? = nil) {
        
        linphone_core_reload_ms_plugins(rawPointer, path)
    }
    
    /// Add a listener in order to be notified of `Linphone.Core` events. 
    /// Once an event is received, registred `Linphone.Callbacks` are invoked sequencially.
    @inline(__always)
    public func add(callbacks: Callbacks) {
        
        linphone_core_add_callbacks(rawPointer, callbacks.rawPointer) // retains
    }
    
    /// Remove a listener from the `Linphone.Core` events.
    @inline(__always)
    public func remove(callbacks: Callbacks) {
        
        linphone_core_remove_callbacks(rawPointer, callbacks.rawPointer)  // releases
    }
    
    /// Add a supported tag.
    @inline(__always)
    public func add(supportedTag tag: String) {
        
        linphone_core_remove_supported_tag(rawPointer, tag)
    }
    
    /// Remove a supported tag.
    @inline(__always)
    public func remove(supportedTag tag: String) {
        
         linphone_core_remove_supported_tag(rawPointer, tag)
    }
}

// MARK: - Supporting Types

public extension Core {
    
    /// That class holds all the callbacks which are called by `Linphone.Core`.
    public final class Callbacks {
        
        // MARK: - Properties
        
        @_versioned
        internal let managedPointer: ManagedPointer<Core.Callbacks.InternalPointer>
        
        // MARK: - Initialization
        
        internal init(_ managedPointer: ManagedPointer<Core.Callbacks.InternalPointer>) {
            
            self.managedPointer = managedPointer
        }
        
        public convenience init?(factory: Factory = Factory.shared) {
            
            guard let rawPointer = linphone_factory_create_core_cbs(factory.rawPointer)
                else { return nil }
            
            self.init(ManagedPointer(InternalPointer(rawPointer)))
        }
        
        // MARK: - Methods
        
        
    }
}

public extension Core {
    
    public final class VTable {
        
        // MARK: - Properties
        
        internal var rawPointer: UnsafeMutablePointer<LinphoneCoreVTable> { return _rawPointer }
        
        private var _rawPointer: UnsafeMutablePointer<LinphoneCoreVTable>!
        
        // MARK: - Initialization
        
        deinit {
            
            linphone_core_v_table_destroy(rawPointer)
        }
        
        private init(dummy: ()) { /* Dummy */ }
        
        private convenience init(_ rawPointer: UnsafeMutablePointer<LinphoneCoreVTable>) {
            
            self.init(dummy: ())
            self._rawPointer = rawPointer
            self.setUserData()
        }
        
        /// Create an empty vTable. 
        public convenience init() {
            
            self.init(linphone_core_v_table_new())
        }
    }
}

// MARK: - Internal

extension Core: ManagedHandle {
    
    typealias RawPointer = InternalPointer.RawPointer
    
    struct InternalPointer: LinPhoneSwift.InternalPointer {
        
        let rawPointer: OpaquePointer
        
        @inline(__always)
        init(_ rawPointer: InternalPointer.RawPointer) {
            self.rawPointer = rawPointer
        }
        
        @inline(__always)
        func retain() {
            linphone_core_ref(rawPointer)
        }
        
        @inline(__always)
        func release() {
            linphone_core_unref(rawPointer)
        }
    }
}

extension Core.Callbacks: ManagedHandle {
    
    typealias RawPointer = InternalPointer.RawPointer
    
    struct InternalPointer: LinPhoneSwift.InternalPointer {
        
        let rawPointer: OpaquePointer
        
        @inline(__always)
        init(_ rawPointer: InternalPointer.RawPointer) {
            self.rawPointer = rawPointer
        }
        
        @inline(__always)
        func retain() {
            linphone_core_cbs_ref(rawPointer)
        }
        
        @inline(__always)
        func release() {
            linphone_core_cbs_unref(rawPointer)
        }
    }
}

extension Core: UserDataHandle {
    
    static var userDataGetFunction: (OpaquePointer?) -> UnsafeMutableRawPointer? {
        return linphone_core_get_user_data
    }
    
    static var userDataSetFunction: (_ internalPointer: OpaquePointer?, _ userdata: UnsafeMutableRawPointer?) -> () {
        return linphone_core_set_user_data
    }
}

extension Core.Callbacks: UserDataHandle {
    
    static var userDataGetFunction: (OpaquePointer?) -> UnsafeMutableRawPointer? {
        return linphone_core_cbs_get_user_data
    }
    
    static var userDataSetFunction: (_ internalPointer: OpaquePointer?, _ userdata: UnsafeMutableRawPointer?) -> () {
        return linphone_core_cbs_set_user_data
    }
}

extension Core.VTable: UserDataHandle {
    
    static var userDataGetFunction: (UnsafeMutablePointer<LinphoneCoreVTable>?) -> UnsafeMutableRawPointer? {
        
        return { linphone_core_v_table_get_user_data(UnsafePointer($0)) }
    }
    
    static var userDataSetFunction: (_ internalPointer: UnsafeMutablePointer<LinphoneCoreVTable>?, _ userdata: UnsafeMutableRawPointer?) -> () {
        return linphone_core_v_table_set_user_data
    }
}

