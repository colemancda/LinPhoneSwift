//
//  Error.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/5/17.
//
//

import CLinPhone

/// Struct representing full details about a signaling error or status.
public struct ErrorInfo {
    
    // MARK: - Properties
    
    @_versioned // private(set) in Swift 4
    internal fileprivate(set) var internalReference: CopyOnWrite<Reference>
    
    // MARK: - Initialization
    
    @inline(__always)
    internal init(_ internalReference: CopyOnWrite<Reference>) {
        
        self.internalReference = internalReference
    }
    /*
    public init() {
        
        self.init(Reference())
    }*/
    
    // MARK: - Accessors
    
    /// Get reason code from the error info.
    public var reason: Reason {
        
        @inline(__always)
        get { return Reason(linphone_error_info_get_reason(internalReference.reference.rawPointer)) }
    }
    
    public var detailedErrorInfo: ErrorInfo? {
        
        get { return internalReference.reference.getReferenceConvertible(.copy, linphone_error_info_get_sub_error_info) }
        
        mutating set { internalReference.mutatingReference.setReferenceConvertible(.copy, linphone_error_info_set_sub_error_info, newValue) }
    }
}

// MARK: - ReferenceConvertible

extension ErrorInfo: ReferenceConvertible {
    
    /// Object representing full details about a signaling error or status.
    /// All LinphoneErrorInfo object returned by the liblinphone API are readonly and transcients.
    /// For safety they must be used immediately after obtaining them.
    /// Any other function call to the liblinphone may change their content or invalidate the pointer.
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
        
        /*
        convenience init() {
            
            guard let rawPointer = linphone_error_info_new()
                else { fatalError("Could not allocate instance") }
            
            self.init(ManagedPointer(BelledonneUnmanagedObject(rawPointer)))
        }*/
    }
}
