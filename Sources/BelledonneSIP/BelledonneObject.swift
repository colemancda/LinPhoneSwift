//
//  Object.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/4/17.
//
//

import CBelledonneSIP

/// It is the base protocol for all BelleSIP non-trivial objects. Can be class or struct.
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
}

internal protocol BelledonneObjectHandle: ManagedHandle, CopyableHandle, CustomStringConvertible {
    
    typealias RawPointer = OpaquePointer
    
    var rawPointer: OpaquePointer { get }
    
    var managedPointer: ManagedPointer<BelledonneUnmanagedObject> { get }
    
    init(_ managedPointer: ManagedPointer<BelledonneUnmanagedObject>)
}

internal extension BelledonneObjectHandle {
    
    var objectTypeDescription: String {
        
        return getString { UnsafePointer(belle_sip_object_describe(📦($0))) } ?? ""
    }
    
    var description: String {
        
        return getString { UnsafePointer(belle_sip_object_to_string(📦($0))) } ?? ""
    }
    
    var copy: Self? {
        
        guard let copyRawPointer = belle_sip_object_clone(self.rawPointer)
            else {  }
    }
}

/// Cast any type to unsafe raw pointer.
@inline(__always)
private func 📦 <RawPointer> (_ rawPointer: RawPointer) -> UnsafeMutableRawPointer {
    
    let opaquePointer = unsafeBitCast(rawPointer, to: OpaquePointer.self)
    
    return UnsafeMutableRawPointer(opaquePointer)
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
