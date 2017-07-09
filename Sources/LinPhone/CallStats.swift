//
//  CallStats.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/9/17.
//
//

import CLinPhone

public extension Call {
    
    public struct Stats {
        
        // MARK: - Properties
        
        @_versioned // private(set) in Swift 4
        internal let internalReference: Reference
        
        // MARK: - Initialization
        
        @inline(__always)
        internal init(referencing reference: Reference) {
            
            self.internalReference = reference
        }
        
        // MARK: - Accessors
        
        internal var rawPointer: UnmanagedPointer.RawPointer {
            
            @inline(__always)
            get { return internalReference.managedPointer.unmanagedPointer.rawPointer }
        }
        
        /// The type of the stream the stats refer to.
        public var type: StreamType {
            
            @inline(__always)
            get { return StreamType(linphone_call_stats_get_type(rawPointer)) }
        }
        
        /// The bandwidth measurement of the received stream, expressed in kbit/s, including IP/UDP/RTP headers.
        public var downloadBandwith: Float {
            
            @inline(__always)
            get { return linphone_call_stats_get_download_bandwidth(rawPointer)  }
        }
        
        /// The bandwidth measurement of the sent stream, expressed in kbit/s, including IP/UDP/RTP headers.
        public var uploadBandwith: Float {
            
            @inline(__always)
            get { return linphone_call_stats_get_upload_bandwidth(rawPointer)  }
        }
    }
}

extension Call.Stats {
    
    internal final class Reference: ManagedHandle {
        
        typealias RawPointer = Call.Stats.UnmanagedPointer.RawPointer
        
        // MARK: - Properties
        
        @_versioned
        internal let managedPointer: ManagedPointer<UnmanagedPointer>
        
        // MARK: - Initialization
        
        internal init(_ managedPointer: ManagedPointer<UnmanagedPointer>) {
            
            self.managedPointer = managedPointer
        }
    }
}

extension Call.Stats {
    
    typealias RawPointer = UnmanagedPointer.RawPointer
    
    struct UnmanagedPointer: LinPhone.UnmanagedPointer {
        
        let rawPointer: OpaquePointer
        
        @inline(__always)
        init(_ rawPointer: UnmanagedPointer.RawPointer) {
            self.rawPointer = rawPointer
        }
        
        @inline(__always)
        func retain() {
            linphone_call_stats_ref(rawPointer)
        }
        
        @inline(__always)
        func release() {
            linphone_call_stats_unref(rawPointer)
        }
    }
}
