//
//  FilterCategory.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 9/5/17.
//
//

import struct CMediaStreamer2.MSFilterCategory

public extension Filter {
    
    /// Describes filter's category.
    public enum Category: UInt32, MediaStreamerEnumeration {
        
        public typealias MediaStreamerType = MSFilterCategory
        
        /// Other filters. 
        case other
        
        /// Used by encoders.
        case encoder
        
        /// Used by decoders.
        case decoder
        
        /// Used by capture filters that perform encoding.
        case encodingCapturer
        
        /// Used by filters that perform decoding and rendering.
        case decoderRenderer
    }
}
