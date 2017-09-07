//
//  FilterFlag.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 9/6/17.
//
//

import CMediaStreamer2.filter

public extension Filter {
    
    public enum Flag {
        
        /// The filter must be called in process function every tick.
        case pump
        
        /// Flag to specify if a filter is enabled or not.
        case enabled
    }
}

extension Filter.Flag: BitMaskOption {
    
    public static var all: Set<Filter.Flag> { return [.pump, .enabled] }
}

extension Filter.Flag: MediaStreamerEnumeration {
    
    public typealias MediaStreamerType = MSFilterFlags
    
    public init?(_ mediaStreamerType: MediaStreamerType) {
        
        switch mediaStreamerType {
        case MS_FILTER_IS_PUMP: self = .pump
        case MS_FILTER_IS_ENABLED: self = .enabled
        default: return nil
        }
    }
    
    public var mediaStreamerType: MediaStreamerType {
        
        switch self {
        case .pump: return MS_FILTER_IS_PUMP
        case .enabled: return MS_FILTER_IS_ENABLED
        }
    }
}

extension Filter.Flag: RawRepresentable {
    
    public typealias RawValue = MediaStreamerType.RawValue
    
    public init?(rawValue: RawValue) {
        
        self.init(MediaStreamerType(rawValue))
    }
    
    public var rawValue: RawValue {
        
        return mediaStreamerType.rawValue
    }
}

extension Filter.Flag: Equatable {
    
    public static func == (lhs: Filter.Flag, rhs: Filter.Flag) -> Bool {
        
        return lhs.rawValue == rhs.rawValue
    }
}

extension Filter.Flag: Hashable {
    
    public var hashValue: Int {
        
        return Int(rawValue)
    }
}
