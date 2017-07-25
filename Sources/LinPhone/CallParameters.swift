//
//  CallParameters.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/9/17.
//
//

import CLinPhone
import struct CMediaStreamer2.MSVideoSize

public extension Call {
    
    public struct Parameters {
        
        // MARK: - Properties
        
        @_versioned // private(set) in Swift 4
        internal fileprivate(set) var internalReference: CopyOnWrite<Reference>
        
        // MARK: - Initialization
        
        internal init(_ internalReference: CopyOnWrite<Reference>) {
            
            self.internalReference = internalReference
        }
        
        // MARK: - Accessors
        
        public var recievedVideoSize: MSVideoSize {
            
                get { return linphone_call_params_get_received_video_size(internalReference.reference.rawPointer) }
        }
    }
}

extension Call.Parameters: ReferenceConvertible {
    
    internal final class Reference: CopyableHandle {
        
        // MARK: - Properties
        
        @_versioned
        internal let managedPointer: ManagedPointer<UnmanagedPointer>
        
        // MARK: - Initialization
        
        internal init(_ managedPointer: ManagedPointer<UnmanagedPointer>) {
            
            self.managedPointer = managedPointer
        }
        
        internal var copy: Call.Parameters.Reference? {
            
            guard let rawPointer = linphone_call_params_copy(self.rawPointer)
                else { return nil }
            
            let copy = Call.Parameters.Reference(ManagedPointer(UnmanagedPointer(rawPointer)))
            
            return copy
        }
    }
}

extension Call.Parameters.Reference: ManagedHandle {
    
    typealias RawPointer = Call.Parameters.UnmanagedPointer.RawPointer
}

extension Call.Parameters {
    
    typealias RawPointer = UnmanagedPointer.RawPointer
    
    struct UnmanagedPointer: LinPhoneSwift.UnmanagedPointer {
        
        let rawPointer: OpaquePointer
        
        @inline(__always)
        init(_ rawPointer: UnmanagedPointer.RawPointer) {
            self.rawPointer = rawPointer
        }
        
        @inline(__always)
        func retain() {
            linphone_call_params_ref(rawPointer)
        }
        
        @inline(__always)
        func release() {
            linphone_call_params_unref(rawPointer)
        }
    }
}
