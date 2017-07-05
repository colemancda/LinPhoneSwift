//
//  Error.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/5/17.
//
//

import CLinPhone

/// Object representing full details about a signaling error or status.
/// All LinphoneErrorInfo object returned by the liblinphone API are readonly and transcients. 
/// For safety they must be used immediately after obtaining them.
/// Any other function call to the liblinphone may change their content or invalidate the pointer.
public struct ErrorInfo {
    
    // MARK: - Properties
    
    @_versioned // private(set) in Swift 4
    internal fileprivate(set) var internalReference: CopyOnWrite<Reference>
    
    // MARK: - Initialization
    
    @inline(__always)
    internal init(_ internalReference: Reference, externalRetain: Bool = false) {
        
        self.internalReference = CopyOnWrite(internalReference, externalRetain: externalRetain)
    }
    
    public init() {
        
        self.init(Reference())
    }
    
    // MARK: - Accessors
    
    
}

// MARK: - ReferenceConvertible

extension ErrorInfo: ReferenceConvertible {
    
    internal final class Reference: BelledonneObjectHandle {
        
        typealias RawPointer = BelledonneUnmanagedObject.RawPointer
        
        // MARK: - Properties
        
        @_versioned
        internal let managedPointer: ManagedPointer<BelledonneUnmanagedObject>
        
        // MARK: - Initialization
        
        @inline(__always)
        internal init(_ managedPointer: ManagedPointer<BelledonneUnmanagedObject>) {
            
            self.managedPointer = managedPointer
        }
        
        convenience init() {
            
            guard let rawPointer = linphone_error_info_new()
                else { fatalError("Could not allocate instance") }
            
            self.init(ManagedPointer(BelledonneUnmanagedObject(rawPointer)))
        }
    }
}
