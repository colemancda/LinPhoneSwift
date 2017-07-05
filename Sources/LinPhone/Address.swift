//
//  Address.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/4/17.
//
//

import CLinPhone

/// LinPhone Address class.
public struct Address: RawRepresentable {
    
    // MARK: - Properties
    
    @_versioned // private(set) in Swift 4
    internal fileprivate(set) var internalReference: CopyOnWrite<Reference>
    
    // MARK: - Initialization
    
    @inline(__always)
    internal init(_ internalReference: Reference, externalRetain: Bool = false) {
        
        self.internalReference = CopyOnWrite(internalReference, externalRetain: externalRetain)
    }
    
    /// Initialize an address from a string.
    public init?(rawValue: String) {
        
        guard let reference = Reference(string: rawValue)
            else { return nil }
        
        self.init(reference)
    }
    
    // MARK: - Accessors
    
    public var rawValue: String {
        
        @inline(__always)
        get { return internalReference.reference.stringValue }
    }
}

// MARK: - CustomStringConvertible

extension Address: CustomStringConvertible {
    
    public var description: String {
        
        @inline(__always)
        get { return rawValue }
    }
}

// MARK: - ReferenceConvertible

extension Address: ReferenceConvertible {
    
    internal final class Reference: CopyableHandle {
        
        // MARK: - Properties
        
        @_versioned
        internal let managedPointer: ManagedPointer<UnmanagedPointer>
        
        // MARK: - Initialization
        
        internal init(_ managedPointer: ManagedPointer<UnmanagedPointer>) {
            
            self.managedPointer = managedPointer
        }
        
        convenience init?(string: String) {
         
            guard let rawPointer = linphone_address_new(string)
                else { return nil }
            
            self.init(ManagedPointer(UnmanagedPointer(rawPointer)))
        }
        
        var copy: Address.Reference? {
            
            guard let rawPointer = linphone_address_clone(self.rawPointer)
                else { return nil }
            
            let copy = Address.Reference(ManagedPointer(UnmanagedPointer(rawPointer)))
            
            return copy
        }
        
        // MARK: - Accessors
        
        internal var stringValue: String {
            
            @inline(__always)
            get { return getString(linphone_address_as_string) ?? "" }
        }
    }
}

// MARK: - ManagedHandle

extension Address.Reference: ManagedHandle {
    
    typealias RawPointer = Address.UnmanagedPointer.RawPointer
}

extension Address {
    
    struct UnmanagedPointer: LinPhone.UnmanagedPointer {
        
        let rawPointer: OpaquePointer
        
        @inline(__always)
        init(_ rawPointer: UnmanagedPointer.RawPointer) {
            self.rawPointer = rawPointer
        }
        
        @inline(__always)
        func retain() {
            linphone_address_ref(rawPointer)
        }
        
        @inline(__always)
        func release() {
            linphone_address_unref(rawPointer)
        }
    }
}
