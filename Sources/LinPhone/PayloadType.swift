//
//  PayloadType.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/12/17.
//
//

import CLinPhone

public final class PayloadType {
    
    // MARK: - Properties
    
    @_versioned
    internal let managedPointer: ManagedPointer<BelledonneUnmanagedObject>
    
    // MARK: - Initialization
    
    internal init(_ managedPointer: ManagedPointer<BelledonneUnmanagedObject>) {
        
        self.managedPointer = managedPointer
    }
    
    // MARK: - Accessors
    
    /// Get the type of a payload type.
    public var category: Category {
        
        @inline(__always)
        get { return Category(rawValue: linphone_payload_type_get_type(rawPointer))! }
    }
    
    /// Whether a payload type is enabled.
    public var isEnabled: Bool {
        
        @inline(__always)
        get { return linphone_payload_type_enabled(rawPointer).boolValue }
        
        @inline(__always)
        set { linphone_payload_type_enable(rawPointer, bool_t(newValue)) }
    }
}

// MARK: - Supporting Types

public extension PayloadType {
    
    public enum Category: Int32 {
        
        case continuousAudio
        
        case packetizedAudio
        
        case video
        
        case other
    }
}

// MARK: - BelledonneObjectHandle

extension PayloadType: BelledonneObjectHandle {
    
    internal typealias UnmanagedPointer = BelledonneUnmanagedObject
    
    internal typealias RawPointer = UnmanagedPointer.RawPointer
}
