//
//  URI.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/3/17.
//
//

import CBelledonneSIP

/// Generic URI used with Belledonne libraries (e.g. Linphone).
public struct URI {
    
    // MARK: - Properties
    
    @_versioned // private(set) in Swift 4
    internal fileprivate(set) var internalReference: CopyOnWrite<Reference>
    
    // MARK: - Initialization
    
    internal init(_ internalReference: Reference) {
        
        self.internalReference = CopyOnWrite(internalReference)
    }
    
    /// Initialize an empty URI.
    public init() {
        
        self.init(Reference())
    }
    
    /// Initialize an URI from a string.
    public init?(string: String) {
        
        guard let reference = Reference(string: string)
            else { return nil }
        
        self.init(reference)
    }
    
    // MARK: - Methods
    
    
    
    // MARK: - Accessors
    
    public var stringValue: String {
        
        @inline(__always)
        get { return internalReference.reference.stringValue }
    }
    
    
}

// MARK: - ReferenceConvertible

extension URI: ReferenceConvertible {
    
    internal final class Reference {
        
        internal typealias RawPointer = UnmanagedPointer.RawPointer
        
        internal typealias UnmanagedPointer = BelledonneUnmanagedObject
        
        // MARK: - Properties
        
        @_versioned
        internal let managedPointer: ManagedPointer<UnmanagedPointer>
        
        // MARK: - Initialization
        
        internal init(_ managedPointer: ManagedPointer<UnmanagedPointer>) {
            
            self.managedPointer = managedPointer
        }
        
        convenience init() {
            
            guard let rawPointer = belle_generic_uri_new()
                else { fatalError("Could not allocate instance") }
            
            self.init(ManagedPointer(UnmanagedPointer(rawPointer)))
        }
        
        convenience init?(string: String) {
            
            guard let rawPointer = belle_generic_uri_parse(string)
                else { return nil }
            
            self.init(ManagedPointer(UnmanagedPointer(rawPointer)))
        }
        
        // MARK: - Accessors
        
        var stringValue: String {
            
            @inline(__always)
            get { return getString(belle_sdp_uri_get_value) ?? "" }
        }
    }
}

extension URI.Reference: ManagedHandle { }

extension URI.Reference: CopyableHandle {
    
    internal var copy: URI.Reference? {
        
        return URI.Reference(string: self.stringValue)
    }
}

// MARK: - CustomStringConvertible

extension URI: CustomStringConvertible {
    
    public var description: String {
        
        return stringValue
    }
}

// MARK: - BelledonneObject

extension URI: BelledonneObject {
    
    public typealias RawPointer = OpaquePointer
    
    @inline(__always)
    public mutating func withUnsafeMutableRawPointer <Result> (_ body: (OpaquePointer) throws -> Result) rethrows -> Result {
        
        let rawPointer = internalReference.mutatingReference.rawPointer
        
        return try body(rawPointer)
    }
    
    @inline(__always)
    public func withUnsafeRawPointer <Result> (_ body: (OpaquePointer) throws -> Result) rethrows -> Result {
        
        let rawPointer = internalReference.reference.rawPointer
        
        return try body(rawPointer)
    }
}
