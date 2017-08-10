//
//  Filter.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 8/10/17.
//
//

import CMediaStreamer2

public final class Filter {
    
    // MARK: - Properties
    
    @_versioned
    internal let rawPointer: UnsafeMutablePointer<MSFilter>
    
    @_versioned
    internal let isOwner: Bool
    
    // MARK: - Initialization
    
    deinit {
        
        if isOwner {
            
            ms_filter_destroy(rawPointer)
        }
    }
    
    /// Instantiate from raw C pointer and specify whether the object will own (manage) the raw pointer.
    public init(rawPointer: UnsafeMutablePointer<MSFactory>, isOwner: Bool = true) {
        
        self.rawPointer = rawPointer
        self.isOwner = isOwner
    }
    
    /// Create decoder filter according to a filter's identifier.
    public convenience init?(identifier: Identifier, factory: Factory) {
        
        guard let rawPointer = ms_factory_create_filter(factory.rawPointer, identifier)
            else { return nil }
        
        self.init(rawPointer: rawPointer)
    }
    
    /// Create decoder filter according to a filter's name.
    public convenience init?(name: String, factory: Factory) {
        
        guard let rawPointer = ms_factory_create_filter_from_name(factory.rawPointer, name)
            else { return nil }
        
        self.init(rawPointer: rawPointer)
    }
    
    // MARK: - Accessors
    
    /// The identifier of the filter.
    public var identifier: Identifier? {
        
        let identifier = ms_filter_get_id(rawPointer)
        
        guard identifier.rawValue != -1
            else { return nil }
        
        return identifier as Identifier
    }
    
    /// The name of the filter.
    public var name: String {
        
        return String(cString: ms_filter_get_name(rawPointer))
    }
    
    // MARK: - Methods
    
    /// Link one OUTPUT pin from a filter to an INPUT pin of another filter.
    /// 
    /// All data coming from the OUTPUT pin of one filter will be distributed
    /// to the INPUT pin of the second filter.
    public func link(pin: CInt, to filter: Filter, pin pin2: CInt) -> Bool {
        
        return ms_filter_link(rawPointer, pin, filter.rawPointer, pin2) == 0
    }
    
    /// Unlink one OUTPUT pin from a filter to an INPUT pin of another filter. 
    public func unlink(pin: CInt, to filter: Filter, pin pin2: CInt) -> Bool {
        
        return ms_filter_unlink(rawPointer, pin, filter.rawPointer, pin2) == 0
    }
    
    /// Returns whether the filter implements a given method.
    public func hasMethod(_ method: CUnsignedInt) {
        
        return ms_filter_has_method(rawPointer, method).boolValue
    }
}

// MARK: - Supporting Types

public extension Filter {
    
    public typealias Identifier = MSFilterId
}
