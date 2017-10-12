//
//  Data.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 8/30/17.
//
//

import CBelledonneRTP.stringutils

internal final class DataBuffer {
    
    // MARK: - Properties
    
    @_versioned
    internal let managedPointer: ManagedPointer<UnmanagedPointer>
    
    // MARK: - Initialization
    
    internal init(_ managedPointer: ManagedPointer<UnmanagedPointer>) {
        
        self.managedPointer = managedPointer
    }
}

// MARK: - ManagedHandle

extension DataBuffer: ManagedHandle {
    
    typealias RawPointer = DataBuffer.UnmanagedPointer.RawPointer
}

extension DataBuffer {
    
    struct UnmanagedPointer: BelledonneRTP.UnmanagedPointer {
        
        let rawPointer: OpaquePointer
        
        @inline(__always)
        init(_ rawPointer: OpaquePointer) {
            self.rawPointer = rawPointer
        }
        
        @inline(__always)
        func retain() {
            
            dblk_ref(rawPointer)
        }
        
        @inline(__always)
        func release() {
            
            dblk_unref(rawPointer)
        }
        
        var referenceCount: Int {
            
            @inline(__always)
            get { return Int(dblk_ref_value(rawPointer)) }
        }
    }
}
