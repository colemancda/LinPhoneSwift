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
    
    public init(factory: Factory = Factory.shared) {
        
        self.init(referencing: Reference(factory: factory))
    }
    
    // MARK: - Accessors
    
    public var detailedErrorInfo: ErrorInfo? {
     
        get { return internalReference.reference.getReferenceConvertible(.copy, linphone_error_info_get_sub_error_info) }
     
        mutating set { internalReference.mutatingReference.setReferenceConvertible(copy: false, linphone_error_info_set_sub_error_info, newValue) }
     }
    
    /// Get reason code from the error info.
    public var reason: Reason {
        
        @inline(__always)
        get { return Reason(linphone_error_info_get_reason(internalReference.reference.rawPointer)) }
        
        @inline(__always)
        mutating set { linphone_error_info_set_reason(internalReference.reference.rawPointer, newValue.linPhoneType) }
    }
    
    /// The protocol name.
    public var `protocol`: String? {
        
        @inline(__always)
        get { return internalReference.reference.getString(linphone_error_info_get_protocol) }
        
        @inline(__always)
        mutating set { internalReference.mutatingReference.setString(linphone_error_info_set_protocol, newValue) }
    }
    
    /// The status code from the low level protocol (e.g. a SIP status code).
    public var protocolCode: Int32 {
        
        @inline(__always)
        get { return linphone_error_info_get_protocol_code(internalReference.reference.rawPointer) }
        
        @inline(__always)
        mutating set { linphone_error_info_set_protocol_code(internalReference.reference.rawPointer, newValue) }
    }
    
    /// The textual phrase from the error info. 
    /// This is the text that is provided by the peer in the protocol (SIP).
    public var phrase: String? {
        
        @inline(__always)
        get { return internalReference.reference.getString(linphone_error_info_get_phrase) }
        
        @inline(__always)
        mutating set { internalReference.mutatingReference.setString(linphone_error_info_set_phrase, newValue) }
    }
    
    /// Provides additional information regarding the failure. 
    /// With SIP protocol, the content of "Warning" headers are returned.
    public var warnings: String? {
        
        @inline(__always)
        get { return internalReference.reference.getString(linphone_error_info_get_warnings) }
        
        @inline(__always)
        mutating set { internalReference.mutatingReference.setString(linphone_error_info_set_warnings, newValue) }
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
        
        convenience init() {
            
            guard let rawPointer = linphone_error_info_new()
                else { fatalError("Could not allocate instance") }
            
            self.init(ManagedPointer(BelledonneUnmanagedObject(rawPointer)))
        }
        
        convenience init(factory: Factory) {
                        
            guard let rawPointer = linphone_factory_create_error_info(factory.rawPointer)
                else { fatalError("Could not allocate instance") }
            
            self.init(ManagedPointer(BelledonneUnmanagedObject(rawPointer)))
        }
    }
}
