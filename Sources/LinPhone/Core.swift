//
//  Core.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 6/30/17.
//
//

import CLinPhone
import CBelledonneToolbox
import struct BelledonneToolbox.LinkedList
import class MediaStreamer.Factory
import struct BelledonneSIP.URI

/// LinPhone Core class
public final class Core {
    
    // MARK: - Properties
    
    @_versioned
    internal let managedPointer: ManagedPointer<Core.UnmanagedPointer>
    
    /// The retained callbacks.
    public private(set) var callbacks = [Callbacks]()
    
    // MARK: - Initialization
    
    deinit {
        
        clearUserData()
    }
    
    internal init(_ managedPointer: ManagedPointer<Core.UnmanagedPointer>) {
        
        self.managedPointer = managedPointer
    }
    
    public convenience init?(factory: Factory = Factory.shared,
                             callbacks: Callbacks,
                             configurationPath: String? = nil,
                             factoryConfigurationPath: String? = nil) {
        
        guard let rawPointer = linphone_factory_create_core(factory.rawPointer,
                                     callbacks.rawPointer,
                                     configurationPath,
                                     factoryConfigurationPath)
            else { return nil }
        
        
        self.init(ManagedPointer(UnmanagedPointer(rawPointer)))
        self.setUserData()
        self.callbacks.append(callbacks)
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
        
        @inline(__always)
        get { return linphone_core_log_collection_enabled() }
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
    
    /// The max file size in bytes of the files used for log collection.
    public static var logCollectionMaxFileSize: Int {
        
        @inline(__always)
        get { return linphone_core_get_log_collection_max_file_size() }
        
        @inline(__always)
        set { linphone_core_set_log_collection_max_file_size(newValue) }
    }
    
    /// The path where the log files will be written.
    public static var logCollectionPath: String? {
        
        @inline(__always)
        get { return String(lpCString: linphone_core_get_log_collection_path()) }
        
        @inline(__always)
        set { linphone_core_set_log_collection_path(newValue) }
    }
    
    public static var logCollectionPrefix: String {
        
        @inline(__always)
        get { return String(lpCString: linphone_core_get_log_collection_path())! }
        
        @inline(__always)
        set { linphone_core_set_log_collection_path(newValue) }
    }
    
    // MARK: - Accessors
    
    /// Returns the `Configuration` object used to manage the storage (config) file.
    public lazy var configuration: Configuration = self.getManagedHandle(externalRetain: true, linphone_core_get_config)! // should never be nil
    
    /// Returns the `MediaStreamer.Factory` used by the `Linphone.Core` to control mediastreamer2 library.
    ///
    /// - Note: The object is only guarenteed to be valid for the lifetime of the closure.
    public func withMediaStreamerFactory<Result>(_ body: (MediaStreamer.Factory) throws -> Result) rethrows -> Result {
        
        guard let rawPointer = linphone_core_get_ms_factory(self.rawPointer)
            else { fatalError("Nil pointer") }
        
        let factory = MediaStreamer.Factory(rawPointer: rawPointer, isOwner: false)
        
        return try body(factory)
    }
    
    /// Gets the current list of calls.
    public var calls: [Call] {
        
        let count = self.callsCount
        
        /// Gets the current list of calls. 
        /// Note that this list is read-only and might be changed by the core after a function call to `iterate()`.
        /// Similarly the LinphoneCall objects inside it might be destroyed without prior notice. 
        /// To hold references to LinphoneCall object into your program, you must use linphone_call_ref().
        
        guard count > 0,
            let callsLinkedList = linphone_core_get_calls(self.rawPointer)
            else { return [] }
        
        var calls: [Call] = []
        calls.reserveCapacity(count) // improves performance
        
        for index in 0 ..< count {
            
            guard let rawPointer = Call.RawPointer(bctbx_list_nth_data(callsLinkedList, Int32(index))),
                let call = self.getUserDataHandle({ _ in return rawPointer }) as Call? // fake getter function
                else { fatalError("Nil pointer") }
            
            calls.append(call)
        }
        
        assert(calls.count == count)
        
        return calls
    }
    
    /// Gets the current call or `nil` if no call is running.
    public var currentCall: Call? {
        
        return getUserDataHandle(linphone_core_get_current_call)
    }
    
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
    ///
    /// - Parameter uri: The `http` or `https` URI to use in order to download the configuration.
    /// Passing `nil` will disable remote provisioning.
    public var provisioning: URI? {
        
        @inline(__always)
        get { return URI(rawValue: provisioningURIString ?? "") }
        
        @inline(__always)
        set { guard setProvisioningURI(newValue?.rawValue)
            else { fatalError("Invalid URI: \(newValue?.description ?? "nil")") } }
    }
    
    internal var provisioningURIString: String? {
        
        @inline(__always)
        get { return getString(linphone_core_get_provisioning_uri) }
    }
    
    @inline(__always)
    internal func setProvisioningURI(_ uri: String?) -> Bool {
        
        return setString(linphone_core_set_provisioning_uri, uri) == .success
    }
    
    /// The maximum number of simultaneous calls Linphone core can manage at a time. 
    /// All new calls above this limit are declined with a busy answer
    public var maxCalls: Int {
        
        @inline(__always)
        get { return Int(linphone_core_get_max_calls(rawPointer)) }
        
        @inline(__always)
        set { linphone_core_set_max_calls(rawPointer, Int32(newValue)) }
    }
    
    /// Get the number of missed calls. 
    ///
    /// Once checked, this counter can be reset with `resetMissedCalls()`.
    public var missedCalls: Int {
        
        @inline(__always)
        get { return Int(linphone_core_get_missed_calls_count(rawPointer)) }
    }
    
    /// Tells whether there is a call running.
    public var activeCall: Bool {
        
        @inline(__always)
        get { return linphone_core_in_call(rawPointer).boolValue }
    }
    
    /// The current number of calls
    public var callsCount: Int {
        
        @inline(__always)
        get { return Int(linphone_core_get_calls_nb(rawPointer)) }
    }
    
    /// Tells whether there is an incoming invite pending.
    public var isIncomingInvitePending: Bool {
        
        @inline(__always)
        get { return linphone_core_is_incoming_invite_pending(rawPointer).boolValue }
    }
    
    /// The microphone gain in db.
    public var microphoneGain: Float {
        
        @inline(__always)
        get { return linphone_core_get_mic_gain_db(rawPointer) }
        
        @inline(__always)
        set { linphone_core_set_mic_gain_db(rawPointer, newValue) }
    }
    
    /// The current playback gain in db before entering sound card.
    public var playbackGain: Float {
        
        @inline(__always)
        get { return linphone_core_get_playback_gain_db(rawPointer) }
        
        @inline(__always)
        set { linphone_core_set_playback_gain_db(rawPointer, newValue) }
    }
    
    /// The UDP port used for audio streaming
    public var audioPort: Int {
        
        @inline(__always)
        get { return Int(linphone_core_get_audio_port(rawPointer)) }
        
        @inline(__always)
        set { linphone_core_set_audio_port(rawPointer, Int32(newValue)) }
    }
    
    /// The UDP port used for video streaming
    public var videoPort: Int {
        
        @inline(__always)
        get { return Int(linphone_core_get_video_port(rawPointer)) }
        
        @inline(__always)
        set { linphone_core_set_video_port(rawPointer, Int32(newValue)) }
    }
    
    /// The media encryption policy being used for RTP packets.
    public var mediaEncryption: MediaEncryption {
        
        @inline(__always)
        get { return MediaEncryption(linphone_core_get_media_encryption(rawPointer)) }
        
        @inline(__always)
        set { linphone_core_set_media_encryption(rawPointer, newValue.linPhoneType) }
    }
    
    /// The local "from" identity.
    public var primaryContact: Address? {
        
        // Is this address ever mutated internally? Seems that new values are always created from strings,
        // so we'll assume that the new values are new instances and the same instance is never mutated.
        get { return getReferenceConvertible(.externallyRetainedImmutable, linphone_core_get_primary_contact_parsed) }
        
        // Set new address by parsing string.
        set { self.primaryContactString = newValue?.internalReference.reference.stringValue }
    }
    
    /// The local "from" identity.
    internal var primaryContactString: String? {
        
        @inline(__always)
        get { return getString(linphone_core_get_primary_contact) }
        
        @inline(__always)
        set { setString(linphone_core_set_primary_contact, newValue).lpAssert() }
    }
    
    /// Set the local "from" identity.
    @inline(__always)
    public func setPrimaryContact(_ contact: String) {
        
        linphone_core_set_primary_contact(rawPointer, contact)
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
        
        self.callbacks.append(callbacks)
    }
    
    /// Remove a listener from the `Linphone.Core` events.
    @inline(__always)
    public func remove(callbacks: Callbacks) {
        
        linphone_core_remove_callbacks(rawPointer, callbacks.rawPointer)  // releases
        
        guard let index = self.callbacks.index(where: { $0 === callbacks })
            else { return }
        
        self.callbacks.remove(at: index)
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
    
    /// Reset the counter of missed calls.
    @inline(__always)
    public func resetMissedCalls() {
        
        linphone_core_reset_missed_calls_count(rawPointer)
    }
    
    /// Forces `LinPhone` to use the supplied list of DNS servers, instead of system's ones.
    ///
    /// - Parameter servers: A list of strings containing the IP addresses of DNS servers to be used.
    /// Setting to an empty list restores default behaviour, which is to use the DNS server list provided by the system.
    public func setDNS(_ servers: [String]) {
        
        let linkedList = LinkedList(strings: servers)
        
        let rawPointer = self.rawPointer
        
        /// The list is copied internally.
        linkedList.withUnsafeRawPointer { linphone_core_set_dns_servers(rawPointer, $0) }
    }
    
    /// Forces `LinPhone` to use the system's supplied list of DNS servers.
    @inline(__always)
    public func resetDNS() {
        
        setDNS([])
    }
}

// MARK: - Supporting Types

public extension Core {
    
    /// That class holds all the callbacks which are called by `Linphone.Core`.
    public final class Callbacks {
        
        // MARK: - Properties
        
        @_versioned
        internal let managedPointer: ManagedPointer<UnmanagedPointer>
        
        // MARK: - Initialization
        
        deinit {
            
            clearUserData()
        }
        
        internal init(_ managedPointer: ManagedPointer<UnmanagedPointer>) {
            
            self.managedPointer = managedPointer
        }
        
        public convenience init(factory: Factory = Factory.shared) {
            
            guard let rawPointer = linphone_factory_create_core_cbs(factory.rawPointer)
                else { fatalError("Could not allocate instance") }
            
            self.init(ManagedPointer(UnmanagedPointer(rawPointer)))
            self.setUserData()
        }
        
        // MARK: - Callbacks
        
        /*
        /// Global state notification callback.
        public var globalStateChanged: ((_ core: Core, _ state: LinphoneGlobalState, _ message: String?) -> ())? {
            
            didSet {
            
                linphone_core_cbs_set_global_state_changed(rawPointer) {
                    
                    guard let (core, callbacks) = Callbacks.from(coreRawPointer: $0.0)
                        else { return }
                    
                    let state = $0.1
                    
                    let message = String(lpCString: $0.2)
                    
                    callbacks.globalStateChanged?(core, state, message)
                }
            }
        }*/
        
        /*
        public var registrationStateChanged: ((_ core: Core, _ state: RegistrationState, _ message: String?) -> ())? {
            
            didSet {
                
                linphone_core_cbs_set_registration_state_changed(rawPointer) {
                    
                    guard let (core, callbacks) = Callbacks.from(coreRawPointer: $0.0)
                        else { return }
                    
                    let proxyConfig = $0.1
                    
                    let state = RegistrationState($0.2)
                    
                    let message = String(lpCString: $0.3)
                    
                    callbacks.registrationStateChanged?(core, state, message)
                }
            }
        }*/
        /*
        /// Callback notifying that a new `Linphone.Call` (either incoming or outgoing) has been created.
        public var callCreated: ((_ core: Core, _ call: Call) -> ())? {
            
            didSet {
                
                linphone_core_cbs_set_call_created(rawPointer) {
                    
                    guard let (core, callbacks) = Callbacks.from(coreRawPointer: $0.0),
                        let callRawPointer = $0.1,
                        let call = Call.from(rawPointer: callRawPointer)
                        else { return }
                    
                    callbacks.callCreated?(core, call)
                }
            }
        }
        */
        /// Call state notification callback.
        public var callStateChanged: ((_ core: Core, _ call: Call, _ state: Call.State, _ message: String?) -> ())? {
            
            didSet {
                
                linphone_core_cbs_set_call_state_changed(rawPointer) {
                    
                    guard let (core, callbacks) = Core.callbacksFrom(rawPointer: $0.0),
                        let callRawPointer = $0.1,
                        let call = Call.from(rawPointer: callRawPointer)
                        else { return }
                    
                    let state = Call.State($0.2)
                    
                    let message = String(lpCString: $0.3)
                    
                    callbacks.callStateChanged?(core, call, state, message)
                }
            }
        }
    }
}

// MARK: - Internal

extension Core: ManagedHandle {
    
    typealias RawPointer = UnmanagedPointer.RawPointer
    
    struct UnmanagedPointer: LinPhone.UnmanagedPointer {
        
        let rawPointer: OpaquePointer
        
        @inline(__always)
        init(_ rawPointer: UnmanagedPointer.RawPointer) {
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
    
    typealias RawPointer = UnmanagedPointer.RawPointer
    
    struct UnmanagedPointer: LinPhone.UnmanagedPointer {
        
        let rawPointer: OpaquePointer
        
        @inline(__always)
        init(_ rawPointer: UnmanagedPointer.RawPointer) {
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
    
    static var userDataSetFunction: (_ UnmanagedPointer: OpaquePointer?, _ userdata: UnsafeMutableRawPointer?) -> () {
        return linphone_core_set_user_data
    }
}

extension Core.Callbacks: UserDataHandle {
    
    static var userDataGetFunction: (OpaquePointer?) -> UnsafeMutableRawPointer? {
        return linphone_core_cbs_get_user_data
    }
    
    static var userDataSetFunction: (_ UnmanagedPointer: OpaquePointer?, _ userdata: UnsafeMutableRawPointer?) -> () {
        return linphone_core_cbs_set_user_data
    }
}

extension Core: CallBacksHandle {
    
    static var currentCallbacksFunction: (RawPointer?) -> (Callbacks.RawPointer?) { return linphone_core_get_current_callbacks }
}
