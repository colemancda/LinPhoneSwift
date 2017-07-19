//
//  Factory.swift
//  MediaStreamer
//
//  Created by Alsey Coleman Miller on 7/1/17.
//
//

import CMediaStreamer2

public final class Factory {
    
    // MARK: - Properties
    
    internal let rawPointer: UnsafeMutablePointer<MSFactory>
    
    internal let isOwner: Bool
    
    // MARK: - Initialization
    
    deinit {
        
        if isOwner {
            
            ms_factory_destroy(rawPointer)
        }
    }
    
    /// Instantiate from raw C pointer and specify whether the object will own (manage) the raw pointer.
    public init(rawPointer: UnsafeMutablePointer<MSFactory>, isOwner: Bool = true) {
        
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
    public var cpuCount: Int {
        
        @inline(__always)
        get { return Int(ms_factory_get_cpu_count(rawPointer)) }
    }
    
    // MARK: - Methods
    
    @inline(__always)
    public func initializePlugins() {
        
        ms_factory_init_plugins(rawPointer)
    }
    
    @inline(__always)
    public func loadPlugins(from directory: String? = nil) {
        
        ms_factory_load_plugins(rawPointer, directory)
    }
    
    public func load(_ mediaLibraries: Set<MediaLibrary>) {
        
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
    
    /// Specify if a filter is enabled or not.
    @discardableResult
    @inline(__always)
    public func enableFilter(_ enable: Bool, for name: String) -> Bool {
        
        return ms_factory_enable_filter_from_name(rawPointer, name, bool_t(enable)) == 0
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

/// On iOS, plugins are built as static libraries so Liblinphone will not be able to load them at runtime dynamically. 
/// Instead, you should declare their prototypes

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

