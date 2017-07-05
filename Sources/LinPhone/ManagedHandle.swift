//
//  ManagedHandle.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/2/17.
//
//

// For Swift 4
// internal protocol ManagedHandle: Handle where RawPointer == InternalPointer.RawPointer {

/// A Swift class wrapper for a C object that uses manual reference counting for memory management.
internal protocol ManagedHandle: Handle {
    
    associatedtype Unmanaged: UnmanagedPointer
    
    var managedPointer: ManagedPointer<Unmanaged> { get }
    
    init(_ managedPointer: ManagedPointer<Unmanaged>)
}

internal extension ManagedHandle where RawPointer == Unmanaged.RawPointer  {
    
    var unmanagedPointer: Unmanaged {
        
        @inline(__always)
        get { return managedPointer.unmanagedPointer }
    }
    
    var rawPointer: RawPointer {
        
        @inline(__always)
        get { return unmanagedPointer.rawPointer }
    }
}

internal extension ManagedHandle {
    
    @inline(__always)
    func getReferenceConvertible <Value: ReferenceConvertible> (isRetained: Bool = true, _ function: ((RawPointer?) -> Value.Reference.Unmanaged.RawPointer?)) -> Value? where Value.Reference: ManagedHandle {
        
        // get handle pointer
        guard let rawPointer = function(self.rawPointer)
            else { return nil }
        
        // create swift object for reference convertible struct
        let reference = Value.Reference(ManagedPointer(Value.Reference.Unmanaged(rawPointer)))
        
        // Object is already retained externally by the reciever,
        // so we must copy / clone the reference object on next mutation regardless of ARC uniqueness / retain count,
        // this is more efficient than unnecesarily copying right now, since the object may never be mutated.
        //
        // If we dont copy or set this flag, and the struct is modified with its reference object
        // uniquely retained (at least according to ARC), we will be mutating  the internal handle
        // shared by the reciever and possibly other C objects, which would lead to bugs
        // and violate value semantics for reference-backed value types.
        let value = Value(reference, externalRetain: isRetained)
        
        return value
    }
}
