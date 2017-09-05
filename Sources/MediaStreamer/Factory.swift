//
//  Factory.swift
//  MediaStreamer
//
//  Created by Alsey Coleman Miller on 7/1/17.
//
//

import CMediaStreamer2.factory
import CBelledonneToolbox.port
import struct BelledonneToolbox.LinkedList

public final class Factory {
    
    public typealias RawPointer = UnsafeMutablePointer<MSFactory>
    
    // MARK: - Properties
    
    @_versioned
    internal let rawPointer: RawPointer
    
    @_versioned
    internal let isOwner: Bool
    
    // MARK: - Initialization
    
    deinit {
        
        if isOwner {
            
            ms_factory_destroy(rawPointer)
        }
    }
    
    /// Instantiate from raw C pointer and specify whether the object will own (manage) the raw pointer.
    public init(rawPointer: RawPointer, isOwner: Bool = true) {
        
        self.rawPointer = rawPointer
        self.isOwner = isOwner
    }
    
    /// Create a mediastreamer2 `Factory`.
    /// This is the root object that will create everything else from mediastreamer2.
    public convenience init() {
        
        guard let rawPointer = ms_factory_new()
            else { fatalError("Nil pointer") }
        
        self.init(rawPointer: rawPointer)
    }
    
    /// Create a mediastreamer2 `Factory` and initialize all voip related filter, card and webcam managers.
    public static var voip: Factory {
        
        guard let rawPointer = ms_factory_new_with_voip()
            else { fatalError("Nil pointer") }
        
        return Factory(rawPointer: rawPointer)
    }
    
    /// Create a mediastreamer2 `Factory`, initialize all voip related filters, 
    /// cards and webcam managers and load the plugins from the specified directory.
    public convenience init(voip directory: (plugins: String, images: String)) {
        
        guard let rawPointer = ms_factory_new_with_voip_and_directories(directory.plugins, directory.images)
            else { fatalError("Nil pointer") }
        
        self.init(rawPointer: rawPointer)
    }
    
    // MARK: - Accessors
    
    /// Get number of available cpus for processing.
    /// The factory initializes this value to the number of logicial processors available on the machine where it runs.
    public var cpuCount: UInt {
        
        @inline(__always)
        get { return UInt(ms_factory_get_cpu_count(rawPointer)) }
        
        @inline(__always)
        set { ms_factory_set_cpu_count(rawPointer, UInt32(newValue)) }
    }
    
    public var maximumTransmissionUnit: UInt {
        
        @inline(__always)
        get { return UInt(ms_factory_get_mtu(rawPointer)) }
        
        @inline(__always)
        set { ms_factory_set_mtu(rawPointer, Int32(newValue)) }
    }
    
    public var platformTags: [String] {
        
        guard let listRawPointer = ms_factory_get_platform_tags(rawPointer)
            else { return [] }
        
        return LinkedList.strings(from: listRawPointer)
    }
    
    public var payloadMaxSize: Int {
        
        get { return Int(ms_factory_get_payload_max_size(rawPointer)) }
        
        set { ms_factory_set_payload_max_size(rawPointer, Int32(newValue)) }
    }
    
    /// The name of the echo canceller filter to use.
    public var echoCancellerFilterName: String {
        
        get { return String(cString: ms_factory_get_echo_canceller_filter_name(rawPointer)) }
        
        set { ms_factory_set_echo_canceller_filter_name(rawPointer, newValue) }
    }
    
    // MARK: - Methods
    
    @inline(__always)
    public func initializePlugins() {
        
        ms_factory_init_plugins(rawPointer)
    }
    
    @inline(__always)
    public func uninitializePlugins() {
        
        ms_factory_uninit_plugins(rawPointer)
    }
    
    @inline(__always)
    public func loadPlugins(from directory: String? = nil) {
        
        ms_factory_load_plugins(rawPointer, directory)
    }
    
    /// Specify if a filter is enabled or not.
    @discardableResult
    public func enableFilter(_ enable: Bool, for name: String) -> Bool {
        
        return ms_factory_enable_filter_from_name(rawPointer, name, bool_t(enable)) == 0
    }
    
    /// Register a filter description.
    public func register(filter description: Filter.Description) {
        
        var filter = description.internalData
        
        ms_factory_register_filter(rawPointer, &filter)
    }
    
    /// Add platform tag.
    @inline(__always)
    public func add(platform tag: String) {
        
        ms_factory_add_platform_tag(rawPointer, tag)
    }
    
    /// Initialize VOIP features (registration of codecs, sound card and webcam managers).
    @inline(__always)
    public func initializeVoip() {
        
        ms_factory_init_voip(rawPointer)
    }
    
    /// Uninitialize VOIP features (registration of codecs, sound card and webcam managers).
    @inline(__always)
    public func uninitializeVoip() {
        
        ms_factory_uninit_voip(rawPointer)
    }
}

// MARK: - Supporting Types

/// Libraries used with `MediaStreamer2`
public enum MediaLibrary {
    
    case amr
    case x264
    case openh264
    case silk
    case webrtc
    
    /// All media libraries availible for `MediaStreamer`.
    public static let all: Set<MediaLibrary> = [amr, x264, openh264, silk, webrtc]
}

// MARK: - Loading Plugins on iOS

#if os(iOS)

public extension Factory {
    
    func load(_ mediaLibraries: Set<MediaLibrary>) {
        
        for library in mediaLibraries {
            
            switch library {
            case .amr:      libmsamr_init(rawPointer)
            case .x264:     libmsx264_init(rawPointer)
            case .openh264: libmsopenh264_init(rawPointer)
            case .silk:     libmssilk_init(rawPointer)
            case .webrtc:   libmswebrtc_init(rawPointer)
            }
        }
    }
}

// On iOS, plugins are built as static libraries so Liblinphone will not be able to load them at runtime dynamically.
// Instead, you should declare their prototypes

/// extern void libmsamr_init(MSFactory *factory);
@_silgen_name("libmsamr_init")
fileprivate func libmsamr_init(_ factory: UnsafeMutablePointer<MSFactory>)

/// extern void libmsx264_init(MSFactory *factory);
@_silgen_name("libmsx264_init")
fileprivate func libmsx264_init(_ factory: UnsafeMutablePointer<MSFactory>)

/// extern void libmsopenh264_init(MSFactory *factory);
@_silgen_name("libmsopenh264_init")
fileprivate func libmsopenh264_init(_ factory: UnsafeMutablePointer<MSFactory>)

/// extern void libmssilk_init(MSFactory *factory);
@_silgen_name("libmssilk_init")
fileprivate func libmssilk_init(_ factory: UnsafeMutablePointer<MSFactory>)

/// extern void libmswebrtc_init(MSFactory *factory);
@_silgen_name("libmswebrtc_init")
fileprivate func libmswebrtc_init(_ factory: UnsafeMutablePointer<MSFactory>)

#endif
