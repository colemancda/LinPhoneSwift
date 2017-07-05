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
}

// MARK: - ReferenceConvertible

extension ErrorInfo: ReferenceConvertible {
    
    internal final class Reference: CopyableHandle {
        
        // MARK: - Properties
        
        @_versioned
        internal let managedPointer: ManagedPointer<UnmanagedPointer>
        
        // MARK: - Initialization
        
        @inline(__always)
        internal init(_ managedPointer: ManagedPointer<UnmanagedPointer>) {
            
            self.managedPointer = managedPointer
        }
        
        convenience init() {
            
            guard let rawPointer = linphone_error_info_new()
                else { fatalError("Could not allocate instance") }
            
            self.init(ManagedPointer(UnmanagedPointer(rawPointer)))
        }
    }
}

// MARK: - ManagedHandle

extension ErrorInfo.Reference: ManagedHandle {
    
    typealias RawPointer = ErrorInfo.UnmanagedPointer.RawPointer
}

extension ErrorInfo {
    
    struct UnmanagedPointer: LinPhone.UnmanagedPointer {
        
        let rawPointer: OpaquePointer
        
        @inline(__always)
        init(_ rawPointer: UnmanagedPointer.RawPointer) {
            self.rawPointer = rawPointer
        }
        
        @inline(__always)
        func retain() {
            linphone_error_info_ref(rawPointer)
        }
        
        @inline(__always)
        func release() {
            linphone_error_info_unref(rawPointer)
        }
    }
}
