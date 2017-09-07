//
//  FilterFlag.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 9/6/17.
//
//

import CMediaStreamer2.filter

public extension Filter {
    
    public enum Flag: Int32, MediaStreamerEnumeration, BitMaskOption {
        
        public typealias MediaStreamerType = MSFilterFlags
        
        /// The filter must be called in process function every tick.
        case pump
        
        /// Flag to specify if a filter is enabled or not.
        case enabled
        
        public static let all: Set<Filter.Flag> = [.pump, .enabled]
    }
}
