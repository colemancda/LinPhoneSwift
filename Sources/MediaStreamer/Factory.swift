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
}
