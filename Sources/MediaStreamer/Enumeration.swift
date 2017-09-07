//
//  Enumeration.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 8/12/17.
//
//

public protocol MediaStreamerEnumeration {
    
    associatedtype MediaStreamerType: RawRepresentable
    
    init?(_ mediaStreamerType: MediaStreamerType)
    
    var mediaStreamerType: MediaStreamerType { get }
}

public extension MediaStreamerEnumeration where Self: RawRepresentable, Self.RawValue == MediaStreamerType.RawValue {
    
    @inline(__always)
    init(_ mediaStreamerType: MediaStreamerType) {
        
        self.init(rawValue: mediaStreamerType.rawValue)!
    }
    
    var mediaStreamerType: MediaStreamerType {
        
        @inline(__always)
        get { return MediaStreamerType(rawValue: self.rawValue)! }
    }
}
