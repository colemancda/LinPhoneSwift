//
//  Handle.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/2/17.
//
//

#if os(macOS) || os(iOS)
    import Darwin.C.stdlib
#elseif os(Linux)
    import Glibc
#endif

// MARK: - Handle

/// A Swift class wrapper for a C object.
internal protocol Handle: class {
    
    associatedtype RawPointer
    
    var rawPointer: RawPointer { get }
}

extension Handle {
    
    /// Get a constant string.
    @inline(__always)
    func getString(_ function: (_ internalPointer: RawPointer?) -> (UnsafePointer<Int8>?)) -> String? {
        
        guard let cString = function(self.rawPointer)
            else { return nil }
        
        return String(cString: cString)
    }
    
    /// Get a string from a function that returns a C string `CChar` buffer that needs to be freed.
    @inline(__always)
    func getString(_ function: (_ internalPointer: RawPointer?) -> (UnsafeMutablePointer<Int8>?)) -> String? {
        
        guard let cString = function(self.rawPointer)
            else { return nil }
        
        defer { free(cString) }
        
        return String(cString: cString)
    }
    
    @inline(__always)
    func setString<Result>(_ function: (_ internalPointer: RawPointer?, _ cString: UnsafePointer<Int8>?) -> Result, _ newValue: String?) -> Result {
        
        return function(self.rawPointer, newValue)
    }
}

// MARK: - CopyableHandle

/// A handle object that can be duplicated.
internal protocol CopyableHandle: Handle {
    
    /// Clone the handle object.
    var copy: Self? { get }
}

// MARK: - UserDataHandle

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

// MARK: - ManagedHandle

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

internal extension Handle {
    
    @inline(__always)
    func getManagedHandle <Handle: ManagedHandle> (_ function: ((RawPointer?) -> Handle.Unmanaged.RawPointer?)) -> Handle? {
        
        // get handle pointer
        guard let rawPointer = function(self.rawPointer)
            else { return nil }
        
        // increment reference count since it will be decremented when swift object is released
        let unmanagedPointer = Handle.Unmanaged(rawPointer)
        unmanagedPointer.retain()
        
        return Handle(ManagedPointer(unmanagedPointer))
    }
}

// MARK: - Managed / Unmanaged Pointer

/// A type for propagating an unmanaged C object reference.
/// When you use this type, you become partially responsible for keeping the object alive.
internal protocol UnmanagedPointer {
    
    associatedtype RawPointer
    
    init(_ rawPointer: RawPointer)
    
    var rawPointer: RawPointer { get }
    
    func retain()
    
    func release()
}

/// Generic class for using C objects with manual reference count.
internal final class ManagedPointer <Unmanaged: UnmanagedPointer> {
    
    let unmanagedPointer: Unmanaged
    
    deinit {
        
        unmanagedPointer.release()
    }
    
    init(_ unmanagedPointer: Unmanaged) {
        
        self.unmanagedPointer = unmanagedPointer
    }
}

// MARK: - ReferenceConvertible

/// Swift struct wrapper for copyable object.
internal protocol ReferenceConvertible {
    
    associatedtype Reference: CopyableHandle
    
    var internalReference: CopyOnWrite<Reference> { get }
    
    init(_ internalReference: CopyOnWrite<Reference>)
}

/// Memory management rules for creating a value type (e.g. structs) backed by a C object pointer.
internal enum ReferenceConvertibleMemoryManagement {
    
    /// Object is new or uniquely retained (e.g. C manual reference count is 1).
    ///
    /// A new reference convertible struct can point to this reference directly.
    case uniqueReference
    
    /// Object is already retained externally but is immutable (e.g. C manual reference count > 1).
    ///
    /// A new reference convertible struct can point to this reference, but any subsequent mutations
    /// must copy the internal reference regardless of the current Swift ARC reference count.
    case externallyRetainedImmutable
    
    /// Object is already retained externally and could be mutated (e.g. C manual reference count > 1).
    /// 
    /// A new reference convertible struct cannot point to this reference directly,
    /// and must be immediately copied to avoid invalid shared state and unforeseen mutations.
    case externallyRetainedMutable
    
    /// Alias for `.externallyRetainedMutable`
    static let copy: ReferenceConvertibleMemoryManagement = .copy
    
    /// Whether the C manual reference count should be incremented
    /// when creating the a new reference object with a `ManagedPointer`.
    var newReferenceShouldRetain: Bool {
        
        switch self {
        case .uniqueReference: return false
        case .externallyRetainedImmutable,
             .externallyRetainedMutable: return true
        }
    }
}

internal extension ReferenceConvertible where Reference: ManagedHandle {
    
    /// Create reference convertible value type from reference.
    ///
    /// - Precondition: Reference's C object must be uniquely referenced (e.g. newly created).
    @inline(__always)
    init(referencing reference: Reference) {
        
        self.init(CopyOnWrite(reference, externalRetain: false))
    }
    
    /// Initialize from C object pointer according to the specified memory management rule.
    init(_ rawPointer: Reference.Unmanaged.RawPointer, _ memoryManagement: ReferenceConvertibleMemoryManagement) {
        
        let unmanagedPointer = Reference.Unmanaged(rawPointer)
        
        // increment reference count if externally retained.
        switch memoryManagement {
        case .uniqueReference: break
        case .externallyRetainedImmutable, .externallyRetainedImmutable:
            unmanagedPointer.retain()
        }
        
        // create swift object for reference convertible struct
        let reference = Reference(ManagedPointer(unmanagedPointer))
        
        let internalReference: CopyOnWrite<Reference>
        
        switch memoryManagement {
            
        case .uniqueReference:
            
            // Object is new and is not already retained externally (non-ARC) by the reciever.
            internalReference = CopyOnWrite(reference, externalRetain: false)
            
        case .externallyRetainedImmutable:
            
            // Object is already retained externally (non-ARC) by the reciever,
            // so we must copy / clone the reference object on next mutation regardless of ARC uniqueness / retain count,
            // this is more efficient than unnecesarily copying right now, since the object may never be mutated.
            //
            // If we dont copy or set this flag, and the struct is modified with its reference object
            // uniquely retained (at least according to ARC), we will be mutating  the internal handle
            // shared by the reciever and possibly other C objects, which would lead to bugs
            // and violate value semantics for reference-backed value types.
            internalReference = CopyOnWrite(reference, externalRetain: true)
            
        case .externallyRetainedMutable:
            
            // Object is already retained externally (non-ARC) by the reciever,
            // so we must copy / clone the reference object immediately
            // to avoid unforeseen mutations
            let originalInternalReference = CopyOnWrite(reference, externalRetain: true)
            let referenceCopy = referenceCopy.mutatingReference // copy
            assert(originalInternalReference.reference !== referenceCopy.reference, "Reference was not copied / cloned")
            
            internalReference = referenceCopy
        }
        
        self.init(internalReference)
    }
}

internal extension Handle {
    
    @inline(__always)
    func getReferenceConvertible <Value: ReferenceConvertible> (_ memoryManagement: ReferenceConvertibleMemoryManagement, _ function: ((RawPointer?) -> Value.Reference.Unmanaged.RawPointer?)) -> Value? where Value.Reference: ManagedHandle {
        
        // get handle pointer
        guard let rawPointer = function(self.rawPointer)
            else { return nil }
        
        let value = Value.init(rawPointer, memoryManagement)
        
        return value
    }
    
    @inline(__always)
    func setReferenceConvertible <Value: ReferenceConvertible, Result> (copy: Bool, _ function: ((RawPointer?, Value.Reference.RawPointer?) -> Result), _ value: Value?) -> Result where Value.Reference: ManagedHandle {
        
        let newValueRawPointer: Value.Reference.RawPointer?
        
        if copy {
            
            newValueRawPointer = value?.internalReference.reference.copy
            
        } else {
            
            newValueRawPointer = nil
        }
    }
}

/// Encapsulates behavior surrounding value semantics and copy-on-write behavior
/// Modified version of https://github.com/klundberg/CopyOnWrite
internal struct CopyOnWrite <Reference: CopyableHandle> {
    
    /// Needed for `isKnownUniquelyReferenced`
    final class Box {
        
        let unbox: Reference
        
        @inline(__always)
        init(_ value: Reference) {
            unbox = value
        }
    }
    
    var _reference: Box
    
    /// The reference is already retained externally (e.g. C manual reference count)
    /// and should be copied on first mutation regardless of Swift ARC uniqueness.
    private(set) var externalRetain: Bool
    
    /// Constructs the copy-on-write wrapper around the given reference and copy function
    ///
    /// - Parameters:
    ///   - reference: The object that is to be given value semantics
    ///   - copier: The function that is responsible for copying the reference if the
    /// consumer of this API needs it to be copied. This function should create a new
    /// instance of the referenced type; it should not return the original reference given to it.
    @inline(__always)
    init(_ reference: Reference, externalRetain: Bool = false) {
        self._reference = Box(reference)
        self.externalRetain = externalRetain
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
            
            // copy the reference if multiple structs are backed by the reference
            if isUniquelyReferenced == false {
                
                guard let copy = _reference.unbox.copy
                    else { fatalError("Coult not duplicate internal reference type") }
                
                _reference = Box(copy)
                externalRetain = false // reset
            }
            
            return _reference.unbox
        }
    }
    
    /// Helper property to determine whether the reference is uniquely held.
    /// Checks both Swift ARC and the external C manual reference count. 
    internal var isUniquelyReferenced: Bool {
        @inline(__always)
        mutating get {
            return isKnownUniquelyReferenced(&_reference) || externalRetain
        }
    }
}
