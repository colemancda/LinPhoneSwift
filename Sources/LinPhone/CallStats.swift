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
        
        @_versioned
        internal let internalReference: Reference
        
        // MARK: - Initialization
        
        internal init(referencing reference: Reference) {
            
            self.internalReference = reference
        }
        
        // MARK: - Accessors
        
        internal var rawPointer: UnmanagedPointer.RawPointer {
            
                get { return internalReference.managedPointer.unmanagedPointer.rawPointer }
        }
        
        /// The type of the stream the stats refer to.
        public var type: StreamType {
            
                get { return StreamType(linphone_call_stats_get_type(rawPointer)) }
        }
        
        /// The bandwidth measurement of the received stream, expressed in kbit/s, including IP/UDP/RTP headers.
        public var downloadBandwidth: Float {
            
                get { return linphone_call_stats_get_download_bandwidth(rawPointer) }
        }
        
        /// The bandwidth measurement of the sent stream, expressed in kbit/s, including IP/UDP/RTP headers.
        public var uploadBandwidth: Float {
            
                get { return linphone_call_stats_get_upload_bandwidth(rawPointer) }
        }
    }
}

extension Call.Stats {
    
    internal final class Reference: BelledonneObjectHandle {
        
        typealias RawPointer = BelledonneUnmanagedObject.RawPointer
        
        // MARK: - Properties
        
        @_versioned
        internal let managedPointer: ManagedPointer<BelledonneUnmanagedObject>
        
        // MARK: - Initialization
        
        internal init(_ managedPointer: ManagedPointer<BelledonneUnmanagedObject>) {
            
            self.managedPointer = managedPointer
        }
    }
}
