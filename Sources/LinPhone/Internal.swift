//
//  Internal.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/1/17.
//
//

import CLinPhone

// MARK: - Classes

/// Generic class for using C objects with manual reference count.
internal final class ManagedPointer <Pointer: InternalPointer> {
    
    let internalPointer: Pointer
    
    deinit {
        
        internalPointer.release()
    }
    
    init(_ internalPointer: Pointer) {
        
        self.internalPointer = internalPointer
    }
}

// MARK: - Protocols

/// Struct that holds static information for how to manage a pointer.
internal protocol InternalPointer {
    
    associatedtype RawPointer
    
    init(_ rawPointer: RawPointer)
    
    var rawPointer: RawPointer { get }
    
    func retain()
    
    func release()
}

internal protocol Handle: class {
    
    associatedtype RawPointer
    
    var rawPointer: RawPointer { get }
}

// For Swift 4
// internal protocol ManagedHandle: Handle where RawPointer == InternalPointer.RawPointer {

internal protocol ManagedHandle: Handle {
    
    associatedtype InternalPointer: LinPhoneSwift.InternalPointer
    
    var managedPointer: ManagedPointer<InternalPointer> { get }
    
    init(_ managedPointer: ManagedPointer<InternalPointer>)
}

internal extension ManagedHandle where RawPointer == InternalPointer.RawPointer  {
    
    var internalPointer: InternalPointer {
        
        @inline(__always)
        get { return managedPointer.internalPointer }
    }
    
    var rawPointer: RawPointer {
        
        @inline(__always)
        get { return internalPointer.rawPointer }
    }
    
    @inline(__always)
    func getString(_ function: (_ internalPointer: InternalPointer.RawPointer?) -> (UnsafePointer<Int8>?)) -> String? {
        
        guard let cString = function(self.rawPointer)
            else { return nil }
        
        return String(cString: cString)
    }
    
    @inline(__always)
    func setString<Result>(_ function: (_ internalPointer: InternalPointer.RawPointer?, _ cString: UnsafePointer<Int8>?) -> Result, _ newValue: String?) -> Result {
        
        return function(self.rawPointer, newValue)
    }
}

internal protocol UserDataHandle: Handle {
    
    static var userDataGetFunction: (_ internalPointer: RawPointer?) -> UnsafeMutableRawPointer? { get }
    
    static var userDataSetFunction: (_ internalPointer: RawPointer?, _ userdata: UnsafeMutableRawPointer?) -> () { get }
}

internal extension UserDataHandle {
    
    static func from(rawPointer: RawPointer) -> Self? {
        
        guard let userData = Self.userDataGetFunction(rawPointer)
            else { return nil }
        
        return from(userData: userData)
    }
    
    static func from(userData: UnsafeMutableRawPointer) -> Self {
        
        let unmanaged = Unmanaged<Self>.fromOpaque(userData)
        
        let context = unmanaged.takeUnretainedValue()
        
        return context
    }
    
    func setUserData() {
        
        Self.userDataSetFunction(rawPointer, userData)
    }
    
    var userData: UnsafeMutableRawPointer {
        
        let unmanaged = Unmanaged<Self>.passUnretained(self)
        
        let objectPointer = unmanaged.toOpaque()
        
        return objectPointer
    }
}

/// A handle object that can be duplicated.
internal protocol CopyableHandle: Handle {
    
    var copy: Self? { get }
}

/// Swift struct wrapper for copyable object.
internal protocol ReferenceConvertible {
    
    associatedtype Reference: CopyableHandle
    
    var internalReference: CopyOnWrite<Reference> { get }
    
    init(_ internalReference: Reference)
}

/// Encapsulates behavior surrounding value semantics and copy-on-write behavior
/// Modified version of https://github.com/klundberg/CopyOnWrite
internal struct CopyOnWrite<Reference: CopyableHandle> {
    
    /// Needed for `isKnownUniquelyReferenced`
    final class Box {
        
        let unbox: Reference
        
        @inline(__always)
        init(_ value: Reference) {
            unbox = value
        }
    }
    
    var _reference: Box
    
    /// Constructs the copy-on-write wrapper around the given reference and copy function
    ///
    /// - Parameters:
    ///   - reference: The object that is to be given value semantics
    ///   - copier: The function that is responsible for copying the reference if the
    /// consumer of this API needs it to be copied. This function should create a new
    /// instance of the referenced type; it should not return the original reference given to it.
    @inline(__always)
    init(_ reference: Reference) {
        self._reference = Box(reference)
    }
    
    /// Returns the reference meant for read-only operations.
    var reference: Reference {
        @inline(__always)
        get {
            return _reference.unbox
        }
    }
    
    /// Returns the reference meant for mutable operations.
    ///
    /// If necessary, the reference is copied using the `copier` function
    /// or closure provided to the initializer before returning, in order to preserve value semantics.
    var mutatingReference: Reference {
        
        mutating get {
            
            // copy the reference only if necessary
            if !isUniquelyReferenced {
                
                guard let copy = _reference.unbox.copy
                    else { fatalError("Coult not duplicate internal reference type") }
                
                _reference = Box(copy)
            }
            
            return _reference.unbox
        }
    }
    
    /// Helper property to determine whether the reference is uniquely held. Used in tests as a sanity check.
    internal var isUniquelyReferenced: Bool {
        @inline(__always)
        mutating get {
            return isKnownUniquelyReferenced(&_reference)
        }
    }
}

// MARK: - Value Types

internal extension CLinPhone.bool_t {
    
    @inline(__always)
    init(_ bool: Bool) {
        
        self = bool ? 1 : 0
    }
    
    var boolValue: Bool {
        
        @inline(__always)
        get { return self > 0 }
    }
}
