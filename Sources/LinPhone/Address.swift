//
//  Address.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/4/17.
//
//

import CLinPhone

/// LinPhone Address class.
public struct Address {
    
    // MARK: - Properties
    
    @_versioned // private(set) in Swift 4
    internal fileprivate(set) var internalReference: CopyOnWrite<Reference>
    
    // MARK: - Initialization
    
    @inline(__always)
    internal init(_ internalReference: Reference, externalRetain: Bool = false) {
        
        self.internalReference = CopyOnWrite(internalReference, externalRetain: externalRetain)
    }
    
    /// Initialize an address from a string.
    public init?(string: String) {
        
        guard let reference = Reference(string: string)
            else { return nil }
        
        self.init(reference)
    }
    
    // MARK: - Accessors
    
    
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
