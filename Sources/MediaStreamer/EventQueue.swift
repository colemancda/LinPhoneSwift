//
//  EventQueue.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 8/16/17.
//
//

import CMediaStreamer2.eventqueue

public final class EventQueue {
    
    public typealias RawPointer = OpaquePointer
    
    // MARK: - Properties
    
    @_versioned
    internal let rawPointer: RawPointer
    
    @_versioned
    internal let factory: Factory
    
    // MARK: - Initialization
    
    deinit {
        
        ms_factory_destroy_event_queue(factory.rawPointer)
    }
    
    /// Creates an event queue. 
    ///
    /// Only one can exist so if it has already been created the same one will be returned.
    public init?(factory: Factory) {
        
        guard let rawPointer = ms_factory_create_event_queue(factory.rawPointer)
            else { return nil }
        
        self.rawPointer = rawPointer
        self.factory = factory
    }
    
    // MARK: - Methods
    
    /// Run callbacks associated to the events received.
    public func pump() {
        
        ms_event_queue_pump(rawPointer)
    }
}
