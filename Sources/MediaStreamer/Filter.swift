//
//  Filter.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 8/10/17.
//
//

#if os(macOS) || os(iOS)
    import Darwin.C.stdlib
#elseif os(Linux)
    import Glibc
#endif

import CMediaStreamer2.filter

public final class Filter {
    
    public typealias RawPointer = UnsafeMutablePointer<MSFilter>
    
    // MARK: - Properties
    
    @_versioned
    internal let rawPointer: RawPointer
    
    /// The `Filter.Description` this filter was created from.
    public let description: Filter.Description?
    
    // MARK: - Initialization
    
    deinit {
        
        // no need to clear user data
        
        ms_filter_destroy(rawPointer)
    }
    
    /// Instantiate from raw C pointer and specify whether the object will own (manage) the raw pointer.
    private init(rawPointer: RawPointer) {
        
        self.rawPointer = rawPointer
        self.description = nil
        setUserData()
    }
    
    /// Create decoder filter according to a filter's description.
    public init?(description: Description, factory: Factory) {
        
        guard let rawPointer = ms_factory_create_filter_from_desc(factory.rawPointer, description.internalReference.reference.rawPointer)
            else { return nil }
        
        self.rawPointer = rawPointer
        self.description = description
        setUserData()
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
    
    /// Create encoder filter according to codec name.
    public convenience init?(encoder name: String, factory: Factory) {
        
        guard let rawPointer = ms_factory_create_encoder(factory.rawPointer, name)
            else { return nil }
        
        self.init(rawPointer: rawPointer)
    }
    
    /// Create decoder filter according to codec name.
    public convenience init?(decoder name: String, factory: Factory) {
        
        guard let rawPointer = ms_factory_create_decoder(factory.rawPointer, name)
            else { return nil }
        
        self.init(rawPointer: rawPointer)
    }
    
    // MARK: - Accessors
    
    /// The identifier of the filter.
    public var identifier: Identifier {
        
        return ms_filter_get_id(rawPointer)
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
    public func implements(method: UInt) -> Bool {
        
        return ms_filter_has_method(rawPointer, CUnsignedInt(method)).boolValue
    }
}

// MARK: - BelledonneObject

public extension Filter /* : BelledonneObject */ {
    
    public func withUnsafeMutableRawPointer <Result> (_ body: (UnsafeMutablePointer<MSFilter>) throws -> Result) rethrows -> Result {
        
        rawPointer.pointee.lock()
        
        defer { rawPointer.pointee.unlock() }
        
        return try body(rawPointer)
    }
}

// MARK: - UserDataHandle

extension Filter {
    
    /// Attempt to get the Swift object associated with the raw C instance.
    static func from(rawPointer: RawPointer) -> Filter? {
        
        // lock to access data
        rawPointer.pointee.lock()
        
        defer { rawPointer.pointee.unlock() }
        
        guard let userData = rawPointer.pointee.data
            else { return nil }
        
        let unmanaged = Unmanaged<Filter>.fromOpaque(userData)
        
        let object = unmanaged.takeUnretainedValue()
        
        return object
    }
}

private extension Filter {
    
    func setUserData() {
        
        let userData = createUserData()
        
        withUnsafeMutableRawPointer { $0.pointee.data = userData }
    }
    
    @inline(__always)
    private func createUserData() -> UnsafeMutableRawPointer {
        
        let unmanaged = Unmanaged<Filter>.passUnretained(self)
        
        let objectPointer = unmanaged.toOpaque()
        
        return objectPointer
    }
}

// MARK: - RawPointer

public extension MSFilter {
    
    @inline(__always)
    mutating func lock() {
        
        pthread_mutex_lock(&lock)
    }
    
    @inline(__always)
    mutating func unlock() {
        
        pthread_mutex_unlock(&lock)
    }
}

// MARK: - Supporting Types

public extension Filter {
    
    public typealias Identifier = MSFilterId
}
