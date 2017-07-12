//
//  Core.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 6/30/17.
//
//

import CLinPhone.core
import CLinPhone.coreutils
import CBelledonneToolbox
import struct BelledonneToolbox.LinkedList
import class MediaStreamer.Factory
import struct BelledonneSIP.URI
import class Foundation.NSString

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
        
        // remove all callbacks
        callbacks.forEach { self.remove(callbacks: $0) }
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
    
    /// The state of the linphone core log collection.
    /// Tells whether the linphone core log collection is enabled.
    public var isLogCollectionEnabled: LinphoneLogCollectionState {
        
        @inline(__always)
        get { return linphone_core_log_collection_enabled() }
        
        @inline(__always)
        set { linphone_core_enable_log_collection(newValue) }
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
    
    /// The path where the log files will be written.
    public static var logCollectionPrefix: String {
        
        @inline(__always)
        get { return String(lpCString: linphone_core_get_log_collection_path())! }
        
        @inline(__always)
        set { linphone_core_set_log_collection_path(newValue) }
    }
    
    /// Define a log handler.
    public static var log: ((_ domain: String, _ message: String, _ level: OrtpLogLevel) -> ())? {
        
        didSet {
            
            if log != nil {
                
                linphone_core_set_log_handler { (domainCString, level, formatCString, arguments) in
                    
                    let domain = String(lpCString: domainCString) ?? ""
                    
                    let format = String(lpCString: formatCString) ?? ""
                    
                    let message = NSString(format: format, arguments: arguments) as String
                    
                    Core.log?(domain, message, level)
                }
                
            } else {
                
                linphone_core_set_log_handler(nil)
            }
        }
    }
    
    /// True if tunnel support was compiled.
    public static var tunnelAvailible: Bool {
        
        @inline(__always)
        get { return linphone_core_tunnel_available().boolValue }
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
                let call = self.getUserDataHandle(externalRetain: true, { _ in rawPointer }) as Call? // fake getter function
                else { fatalError("Nil pointer") }
            
            calls.append(call)
        }
        
        assert(calls.count == count)
        
        return calls
    }
    
    /// Gets the current call or `nil` if no call is running.
    public var currentCall: Call? {
        
        return getUserDataHandle(externalRetain: true, linphone_core_get_current_call)
    }
    
    /// Get tunnel instance if available.
    public var tunnel: Tunnel? {
        
        return getManagedHandle(externalRetain: true, linphone_core_get_tunnel)
    }
    
    internal func getPayloadTypes(_ function: (RawPointer?) -> UnsafeMutablePointer<bctbx_list_t>?) -> [PayloadType] {
        
        // A freshly allocated list of the available payload types.
        // The list must be destroyed with bctbx_list_free() after usage.
        // The elements of the list haven't to be unref.
        // (The payload objects are uniquely retained).
        guard let linkedList = function(self.rawPointer)
            else { return [] }
        
        defer { bctbx_list_free(linkedList) }
        
        let count = bctbx_list_size(linkedList)
        
        var values = [PayloadType]()
        values.reserveCapacity(count) // improves performance
        
        for index in 0 ..< count {
            
            guard let rawPointer = PayloadType.RawPointer(bctbx_list_nth_data(linkedList, Int32(index))),
                let payloadType = self.getManagedHandle(externalRetain: false, { _ in rawPointer }) as PayloadType?
                else { fatalError("Nil pointer") }
            
            values.append(payloadType)
        }
        
        assert(values.count == count)
        
        return values
    }
    
    internal func setPayloadTypes(_ function: (RawPointer?, UnsafePointer<bctbx_list_t>?) -> (), newValue: [PayloadType]) {
        
        // create temporary linked list and temporary payloads
        
        
        
        
        // _list{LinphonePayloadType} The new list of codecs. 
        // The core does not take ownership on it.
        
    }
    
    /// The list of the available video payload types.
    public var videoPayloadTypes: [PayloadType] {
        
        get { return getPayloadTypes(linphone_core_get_video_payload_types) }
        
        set { setPayloadTypes(linphone_core_set_video_payload_types, newValue: newValue) }
    }
    
    /// The list of the available audio payload types.
    public var audioPayloadTypes: [PayloadType] {
        
        get { return getPayloadTypes(linphone_core_get_audio_payload_types) }
        
        set { setPayloadTypes(linphone_core_set_audio_payload_types, newValue: newValue) }
    }
    
    /// The list of the available text payload types.
    public var textPayloadTypes: [PayloadType] {
        
        get { return getPayloadTypes(linphone_core_get_text_payload_types) }
        
        set { setPayloadTypes(linphone_core_set_text_payload_types, newValue: newValue) }
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
    
    /// Tells whether the microphone is enabled.
    public var isMicrophoneEnabled: Bool {
        
        @inline(__always)
        get { return linphone_core_mic_enabled(rawPointer).boolValue }
        
        @inline(__always)
        set { linphone_core_enable_mic(rawPointer, bool_t(newValue)) }
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
        
        // New values are always created from strings and stored internally as strings.
        get { return getReferenceConvertible(.uniqueReference, linphone_core_get_primary_contact_parsed) }
        
        // Set new address by parsing string.
        set { self.primaryContactString = newValue?.rawValue }
    }
    
    /// The local "from" identity, only set valid `LinPhone.Address` strings.
    internal var primaryContactString: String? {
        
        @inline(__always)
        get { return getString(linphone_core_get_primary_contact) }
        
        @inline(__always)
        set { setString(linphone_core_set_primary_contact, newValue).lpAssert() }
    }
    
    /// The nominal audio jitter buffer size in milliseconds.
    public var audioJitter: Int {
        
        @inline(__always)
        get { return Int(linphone_core_get_audio_jittcomp(rawPointer)) }
        
        @inline(__always)
        set { linphone_core_set_audio_jittcomp(rawPointer, Int32(newValue)) }
    }
    
    /// The nominal video jitter buffer size in milliseconds.
    public var videoJitter: Int {
        
        @inline(__always)
        get { return Int(linphone_core_get_video_jittcomp(rawPointer)) }
        
        @inline(__always)
        set { linphone_core_set_video_jittcomp(rawPointer, Int32(newValue)) }
    }
    
    /// Enable or disable the audio adaptive jitter compensation.
    public var isAudioAdaptiveJittCompensationEnabled: Bool {
        
        @inline(__always)
        get { return linphone_core_audio_adaptive_jittcomp_enabled(rawPointer).boolValue }
        
        @inline(__always)
        set { linphone_core_enable_audio_adaptive_jittcomp(rawPointer, bool_t(newValue)) }
    }
    
    /// Enable or disable the audio adaptive jitter compensation.
    public var isVideoAdaptiveJittCompensationEnabled: Bool {
        
        @inline(__always)
        get { return linphone_core_video_adaptive_jittcomp_enabled(rawPointer).boolValue }
        
        @inline(__always)
        set { linphone_core_enable_video_adaptive_jittcomp(rawPointer, bool_t(newValue)) }
    }
    
    public var noXmitOnAudioMute: Bool {
        
        @inline(__always)
        get { return linphone_core_get_rtp_no_xmit_on_audio_mute(rawPointer).boolValue }
        
        @inline(__always)
        set { linphone_core_set_rtp_no_xmit_on_audio_mute(rawPointer, bool_t(newValue)) }
    }
    
    /// The SIP transport timeout in milliseconds.
    public var sipTransportTimeout: Int {
        
        @inline(__always)
        get { return Int(linphone_core_get_sip_transport_timeout(rawPointer)) }
        
        @inline(__always)
        set { linphone_core_set_sip_transport_timeout(rawPointer, Int32(newValue)) }
    }
    
    /// The maximum transmission unit size in bytes.
    /// This information is useful for sending RTP packets.
    ///
    /// Default value is 1500.
    public var maximumTransmissionUnit: Int {
        
        @inline(__always)
        get { return Int(linphone_core_get_mtu(rawPointer)) }
        
        @inline(__always)
        set { linphone_core_set_mtu(rawPointer, Int32(newValue)) }
    }
    
    /// Used to notify the linphone core library when network is reachable.
    public var networkReachable: Bool {
        
        @inline(__always)
        get { return linphone_core_is_network_reachable(rawPointer).boolValue }
        
        @inline(__always)
        set { linphone_core_set_network_reachable(rawPointer, bool_t(newValue)) }
    }
    
    /// Indicates whether the local participant is part of a conference.
    public var inConference: Bool {
        
        @inline(__always)
        get { return linphone_core_is_in_conference(rawPointer).boolValue }
    }
    
    /// A boolean value telling whether echo cancellation is enabled or disabled
    public var isEchoCancellationEnabled: Bool {
        
        @inline(__always)
        get { return linphone_core_echo_cancellation_enabled(rawPointer).boolValue }
        
        @inline(__always)
        set { linphone_core_enable_echo_cancellation(rawPointer, bool_t(newValue)) }
    }
    
    /// Whether echo limiter is enabled.
    public var isEchoLimiterEnabled: Bool {
        
        @inline(__always)
        get { return linphone_core_echo_limiter_enabled(rawPointer).boolValue }
        
        @inline(__always)
        set { linphone_core_enable_echo_limiter(rawPointer, bool_t(newValue)) }
    }
    
    /// The name of the currently active video device.
    public var videoDevice: String? {
        
        @inline(__always)
        get { return String(lpCString: linphone_core_get_video_device(rawPointer)) }
        
        @inline(__always)
        set { linphone_core_set_video_device(rawPointer, newValue).lpAssert() }
    }
    
    /// The current preferred video size for sending.
    public var preferredVideoSize: MSVideoSize {
        
        @inline(__always)
        get { return linphone_core_get_preferred_video_size(rawPointer) }
        
        @inline(__always)
        set { linphone_core_set_preferred_video_size(rawPointer, newValue) }
    }
    
    /// Get the name of the current preferred video size for sending.
    public var preferredVideoSizeName: String? {
        
        @inline(__always)
        get { return getString(linphone_core_get_preferred_video_size_name) }
        
        @inline(__always)
        set { setString(linphone_core_set_preferred_video_size_by_name, newValue) }
    }
    
    /// Tells whether IPv6 is enabled or not.
    public var isIPv6Enabled: Bool {
        
        @inline(__always)
        get { return linphone_core_ipv6_enabled(rawPointer).boolValue }
        
        @inline(__always)
        set { linphone_core_enable_ipv6(rawPointer, bool_t(newValue)) }
    }
    
    /// The path to the image file streamed when "Static picture" is set as the video device.
    public var staticPicture: String? {
        
        @inline(__always)
        get { return getString(linphone_core_get_static_picture) }
        
        @inline(__always)
        set { setString(linphone_core_set_static_picture, newValue).lpAssert() }
    }
    
    /// The frame rate used for static picture.
    public var staticPictureFPS: Float {
        
        @inline(__always)
        get { return linphone_core_get_static_picture_fps(rawPointer) }
        
        @inline(__always)
        set { linphone_core_set_static_picture_fps(rawPointer, newValue) }
    }
    
    /// The UDP port range from which to randomly select the port used for text streaming.
    public var textPortRange: CountableClosedRange<Int> {
        
        get {
            
            var port: (min: Int32, max: Int32) = (0,0)
            
            linphone_core_get_text_port_range(rawPointer, &port.min, &port.max)
            
            return Int(port.min) ... Int(port.max)
        }
        
        set {
            
            linphone_core_set_text_port_range(rawPointer, Int32(newValue.lowerBound), Int32(newValue.upperBound))
            
            assert(newValue.lowerBound ... newValue.upperBound == newValue)
        }
    }
    
    /// Ask the core to stream audio from and to files, instead of using the soundcard.
    public var shouldUseFilesForAudioStreaming: Bool {
        
        @inline(__always)
        get { return linphone_core_get_use_files(rawPointer).boolValue }
        
        @inline(__always)
        set { linphone_core_set_use_files(rawPointer, bool_t(newValue)) }
    }
    
    /// The default policy for video.
    public var videoPolicy: VideoPolicy {
        
        @inline(__always)
        get { return VideoPolicy(linphone_core_get_video_policy(rawPointer).pointee) }
        
        @inline(__always)
        set {
            var value = newValue.linPhoneType
            linphone_core_set_video_policy(rawPointer, &value)
        }
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
    
    /// Force registration refresh to be initiated upon next iterate. 
    @inline(__always)
    public func refreshRegisters() {
        
        linphone_core_refresh_registers(rawPointer)
    }
    
    /// Initiates an outgoing call.
    /// - Parameter url: The destination of the call (sip address, or phone number).
    /// - Returns: A `LinPhone.Call` object or `nil` in case of failure.
    public func invite(_ url: String) -> Call? {
        
        // new Call object is created
        // Initiates an outgoing call 
        // The application doesn't own a reference to the returned LinphoneCall object.
        // Use linphone_call_ref() to safely keep the LinphoneCall pointer valid within your application.
        return getUserDataHandle(externalRetain: false) { linphone_core_invite($0, url) }
    }
    
    /// Initiates an outgoing call.
    /// - Parameter address: The sip address destination of the call.
    /// - Returns: A `LinPhone.Call` object or `nil` in case of failure.
    @inline(__always)
    public func invite(_ address: Address) -> Call? {
        
        return invite(address.rawValue)
    }
    
    /// Pause all currently running calls.
    @inline(__always)
    public func pauseAllCalls() {
        
        linphone_core_pause_all_calls(rawPointer)
    }
    
    /// Plays a dtmf sound to the local user.
    /// - Parameter dtmf: DTMF to play ['0'..'16'] | '#' | '#'
    /// - Parameter duration: Duration in ms, -1 means play until next further call to `stopDMTF()`.
    @inline(__always)
    public func play(dtmf: Int8, duration: Int) {
        
        linphone_core_play_dtmf(rawPointer, dtmf, Int32(duration))
    }
    
    /// Stops playing a dtmf.
    @inline(__always)
    public func stopPlayingDMTF() {
        
        linphone_core_stop_dtmf(rawPointer)
    }
    
    /// Plays an audio file to the local user. 
    /// This method works at any time, during calls, or when no calls are running.
    /// It doesn't request the underlying audio system to support multiple playback streams.
    /// - Parameter filePath: The path to an audio file in wav PCM 16 bit format.
    @discardableResult
    @inline(__always)
    public func play(audio filePath: String) -> Bool {
        
        return linphone_core_play_local(rawPointer, filePath) == .success
    }
    
    /// Get payload type from mime type and clock rate.
    public func payloadType(for mimeType: String,
                            rate: Int = Int(LINPHONE_FIND_PAYLOAD_IGNORE_RATE),
                            channels: Int = Int(LINPHONE_FIND_PAYLOAD_IGNORE_CHANNELS)) -> LinPhoneSwift.PayloadType? {
        
        // payload objects are new instances / uniquely retained
        return getManagedHandle(externalRetain: false) { linphone_core_get_payload_type($0, mimeType, Int32(rate), Int32(channels)) }
    }
    
    // MARK: - iOS Specific Methods
    
    #if os(iOS)
    
    /// Special function to warm up dtmf feeback stream. 
    /// `stopDTMFStream()` must be called before entering foreground mode.
    @inline(__always)
    public func startDTMFStream() {
        
        linphone_core_start_dtmf_stream(rawPointer)
    }
    
    /// Special function to stop dtmf feed back function.
    /// Must be called before entering background mode.
    @inline(__always)
    public func stopDTMFStream() {
        
        linphone_core_stop_dtmf_stream(rawPointer)
    }
    
    #endif
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
        
        /// Global state notification callback.
        public var globalStateChanged: ((_ core: Core, _ state: LinphoneGlobalState, _ message: String?) -> ())? {
            
            didSet {
            
                linphone_core_cbs_set_global_state_changed(rawPointer) {
                    
                    guard let (core, callbacks) = Core.callbacksFrom(rawPointer: $0.0)
                        else { return }
                    
                    let state = $0.1
                    
                    let message = String(lpCString: $0.2)
                    
                    callbacks.globalStateChanged?(core, state, message)
                }
            }
        }
        
        public var registrationStateChanged: ((_ core: Core, _ state: RegistrationState, _ message: String?) -> ())? {
            
            didSet {
                
                linphone_core_cbs_set_registration_state_changed(rawPointer) {
                    
                    guard let (core, callbacks) = Core.callbacksFrom(rawPointer: $0.0)
                        else { return }
                    
                    //let proxyConfig = $0.1
                    
                    let state = RegistrationState($0.2)
                    
                    let message = String(lpCString: $0.3)
                    
                    callbacks.registrationStateChanged?(core, state, message)
                }
            }
        }
        
        /// Callback notifying that a new `Linphone.Call` (either incoming or outgoing) has been created.
        public var callCreated: ((_ core: Core, _ call: Call) -> ())? {
            
            didSet {
                
                linphone_core_cbs_set_call_created(rawPointer) {
                    
                    guard let (core, callbacks) = Core.callbacksFrom(rawPointer: $0.0),
                        let callRawPointer = $0.1,
                        let call = Call.from(rawPointer: callRawPointer)
                        else { return }
                    
                    callbacks.callCreated?(core, call)
                }
            }
        }
        
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
    
    struct UnmanagedPointer: LinPhoneSwift.UnmanagedPointer {
        
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
    
    struct UnmanagedPointer: LinPhoneSwift.UnmanagedPointer {
        
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
    
    static var currentCallbacksFunction: (RawPointer?) -> (Callbacks.RawPointer?) {
        return linphone_core_get_current_callbacks
    }
}
