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
    
    // MARK: - Initialization
    
    deinit {
        
        ms_event_queue_destroy(rawPointer)
    }
    
    /// Creates an event queue to receive notifications from MSFilters.
    public init?() {
        
        guard let rawPointer = ms_event_queue_new()
            else { return nil }
        
        self.rawPointer = rawPointer
    }
    
    // MARK: - Methods
    
    /// Run callbacks associated to the events received.
    public func pump() {
        
        ms_event_queue_pump(rawPointer)
    }
}
