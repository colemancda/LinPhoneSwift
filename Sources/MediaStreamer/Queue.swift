//
//  Queue.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 8/18/17.
//
//

import CMediaStreamer2.queue

public final class Queue {
    
    public typealias RawPointer = UnsafeMutablePointer<MSQueue>
    
    // MARK: - Properties
    
    @_versioned
    internal let rawPointer: RawPointer
    
    public let previous: ConnectionPoint
    
    public let next: ConnectionPoint
    
    // MARK: - Initialization
    
    deinit {
        
        ms_queue_destroy(rawPointer)
    }
    
    public init(previous: ConnectionPoint, next: ConnectionPoint) {
        
        self.rawPointer = ms_queue_new(previous.filter.rawPointer, Int32(previous.pin),
                                       next.filter.rawPointer, Int32(next.pin))
        
        self.previous = previous
        self.next = next
    }
    
    // MARK: - Accessors
    
    public var isEmpty: Bool {
        
        return ms_queue_empty(rawPointer).boolValue
    }
    
    // MARK: - Methods
    
    @inline(__always)
    public func flush() {
        
        ms_queue_flush(rawPointer)
    }
}

// MARK: - Supporting Types

public extension Queue {
    
    public final class ConnectionPoint {
        
        public let filter: Filter
        
        public let pin: Int
        
        public init(filter: Filter, pin: Int) {
            
            self.filter = filter
            self.pin = pin
        }
    }
}
