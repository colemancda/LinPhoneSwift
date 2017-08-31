//
//  Packet.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 8/30/17.
//
//

import CBelledonneRTP.stringutils

/// Linked List media packet / message that contains RTP data.
public final class Packet {
    
    public typealias RawPointer = UnsafeMutablePointer<mblk_t>
    
    // MARK: - Properties
    
    @_versioned
    internal private(set) var rawPointer: RawPointer
    
    // MARK: - Initialization
    
    deinit {
        
        freemsg(rawPointer)
    }
    
    public init(rawPointer: RawPointer) {
        
        self.rawPointer = rawPointer
    }
    
    public init(size: Int) {
        
        self.rawPointer = allocb(size, 0)
    }
    
    // MARK: - Accessors
    
    /// Make a copy of the internal raw pointer.
    internal var duplicateRawPointer: RawPointer {
        
        return dupmsg(rawPointer)
    }
}

public extension Packet {
    
    /// Access the underlying C structure instance.
    ///
    /// - Note: The pointer is only guarenteed to be valid for the lifetime of the closure.
    public func withUnsafeRawPointer <Result> (_ body: (RawPointer) throws -> Result) rethrows -> Result {
        
        return try body(rawPointer)
    }
}
