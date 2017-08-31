//
//  Queue.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 8/30/17.
//
//

import CBelledonneRTP.stringutils

/// Linked list queue.
public final class Queue {
    
    // MARK: - Properties
    
    @_versioned
    internal private(set) var internalData = queue_t()
    
    // MARK: - Initialization
    
    deinit {
        
        flush()
    }
    
    public init() {
        
        qinit(&internalData)
    }
    
    // MARK: - Accessors
    
    public var count: Int {
        
        return Int(internalData.q_mcount)
    }
    
    public var isEmpty: Bool {
        
        return count == 0
    }
    
    // MARK: - Methods
    
    /// Remove and free all messages in the queue.
    public func flush() {
        
        flushq(&internalData, 0)
    }
    
    /// Push an item to the queue.
    public func push(_ packet: Packet) {
        
        // copy packet
        
        let copy = packet.duplicateRawPointer
        
        putq(&internalData, copy)
    }
}


