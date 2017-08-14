//
//  FilterInterface.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 8/12/17.
//
//

import struct CMediaStreamer2.MSFilterInterfaceId

public extension Filter {
    
    /// Interface IDs, used to generate method names.
    public enum Interface: UInt32, MediaStreamerEnumeration {
        
        public typealias MediaStreamerType = MSFilterInterfaceId
        
        case begin = 16384
        
        /// Player interface, used to control playing of files.
        case player
        
        /// Recorder interface, used to control recording of stream into files.
        case recorder
        
        /// Video display interface, used to control the rendering of raw pictures onscreen
        case videoDisplay
        
        /// Echo canceller interface, used to control echo canceller implementations.
        case echoCanceller
        
        /// Video decoder interface
        case videoDecoder
        
        /// Video capture interface
        case videoCapture
        
        /// Audio Decoder interface
        case audioDecoder
        
        /// Video encoder interface
        case videoEncoder
        
        /// Interface for audio capture filters
        case audioCapture
        
        /// Interface for audio playback filters.
        case audioPlayback
        
        /// Video encoder interface
        case audioEncoder
        
        /// Void source/sink interface
        case void
    }
}
