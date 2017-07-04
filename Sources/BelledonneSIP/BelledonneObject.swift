//
//  Object.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/4/17.
//
//

import CBelledonneSIP

/// It is the base protocol for all BelleSIP non-trivial objects
public protocol BelledonneObject {
    
    associatedtype RawPointer
    
    /// Access the underlying C structure instance.
    ///
    /// - Note: The pointer is only guarenteed to be valid for the lifetime of the closure.
    mutating func withUnsafeMutableRawPointer <Result> (_ body: (RawPointer) throws -> Result) rethrows -> Result
    
    /// Access the underlying C structure instance.
    ///
    /// - Note: The pointer is only guarenteed to be valid for the lifetime of the closure.
    func withUnsafeRawPointer <Result> (_ body: (RawPointer) throws -> Result) rethrows -> Result
}

/// Belledonne Object manual reference count type.
internal struct BelledonneUnmanagedObject: UnmanagedPointer {
    
    let rawPointer: OpaquePointer
    
    @inline(__always)
    init(_ rawPointer: OpaquePointer) {
        self.rawPointer = rawPointer
    }
    
    @inline(__always)
    func retain() {
        belle_sip_object_ref(UnsafeMutableRawPointer(rawPointer))
    }
    
    @inline(__always)
    func release() {
        belle_sip_object_unref(UnsafeMutableRawPointer(rawPointer))
    }
    
    var objectTypeDescription: String {
        
        let cString = belle_sip_object_describe(UnsafeMutableRawPointer(rawPointer))!
        
        // defer { free(cString) }
        
        return String(cString: cString)
    }
}

extension BelledonneUnmanagedObject: CustomStringConvertible {
    
    public var description: String {
        
        guard let cString = belle_sip_object_to_string(UnsafeMutableRawPointer(rawPointer))
            else { return "" }
        
        //defer { free(cString) }
        
        return String(cString: cString)
    }
}


/*
internal extension BelledonneObject where Self: ReferenceConvertible {
    
    /// Access the underlying C structure instance.
    ///
    /// - Note: The pointer is only guarenteed to be valid for the lifetime of the closure.
    @inline(__always)
    mutating func _withUnsafeMutableRawPointer <Result> (_ body: (Reference.RawPointer) throws -> Result) rethrows -> Result {
        
        let rawPointer = internalReference.mutatingReference.rawPointer
        
        return try body(rawPointer)
    }
    
    /// Access the underlying C structure instance.
    ///
    /// - Note: The pointer is only guarenteed to be valid for the lifetime of the closure.
    @inline(__always)
    func _withUnsafeRawPointer <Result> (_ body: (Reference.RawPointer) throws -> Result) rethrows -> Result {
        
        let rawPointer = internalReference.reference.rawPointer
        
        return try body(rawPointer)
    }
}*/
