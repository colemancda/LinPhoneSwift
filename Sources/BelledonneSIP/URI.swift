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

extension URI: ReferenceConvertible {
    
    internal final class Reference {
        
        typealias RawPointer = OpaquePointer
        
        // MARK: - Properties
        
        @_versioned
        internal let rawPointer: OpaquePointer
        
        // MARK: - Initialization
        
        internal init(_ rawPointer: RawPointer) {
            
            self.rawPointer = rawPointer
        }
        
        convenience init() {
            
            guard let rawPointer = belle_generic_uri_new()
                else { fatalError("Could not allocate instance") }
            
            self.init(rawPointer)
        }
        
        convenience init?(string: String) {
            
            guard let rawPointer = belle_generic_uri_parse(string)
                else { return nil }
            
            self.init(rawPointer)
        }
        
        
        
        // MARK: - Accessors
        
        var stringValue: String {
            
            @inline(__always)
            get { return getString(belle_sdp_uri_get_value) ?? "" }
        }
    }
}

extension URI.Reference: CopyableHandle {
    
    internal var copy: URI.Reference? {
        
        return URI.Reference(string: self.stringValue)
    }
}

extension URI: CustomStringConvertible {
    
    public var description: String {
        
        return stringValue
    }
}

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
