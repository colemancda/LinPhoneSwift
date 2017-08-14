//
//  FilterDescription.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 8/12/17.
//
//

import CMediaStreamer2

public extension Filter {
    
    public final class Description {
        
        public typealias RawPointer = UnsafeMutablePointer<MSFilterDesc>
        
        // MARK: - Properties
        
        @_versioned
        internal let rawPointer: RawPointer
        
        @_versioned
        internal let isOwner: Bool
        
        // MARK: - Initialization
        
        deinit {
            
            if isOwner {
                
                // FIXME: memory leak
                
            }
        }
        
        /// Instantiate from raw C pointer and specify whether the object will own (manage) the raw pointer.
        public init(rawPointer: RawPointer, isOwner: Bool = true) {
            
            self.rawPointer = rawPointer
            self.isOwner = isOwner
        }
        
        // MARK: - Methods
        
        /// Whether a filter implements a given interface, based on the filter's descriptor.
        public func implements(interface: Filter.Interface) -> Bool {
            
            return ms_filter_desc_implements_interface(rawPointer, interface.mediaStreamerType).boolValue
        }
    }
}
