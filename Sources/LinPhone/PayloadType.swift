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
        
        get { return Category(rawValue: linphone_payload_type_get_type(rawPointer))! }
    }
    
    /// Whether a payload type is enabled.
    public var isEnabled: Bool {
        
        get { return linphone_payload_type_enabled(rawPointer).boolValue }
        
        set { linphone_payload_type_enable(rawPointer, bool_t(newValue)) }
    }
    
    /// Return a string describing a payload type. The format of the string is <mime_type>/<clock_rate>/<channels>.
    public var description: String {
        
        return getString(linphone_payload_type_get_description)!
    }
    
    /// The description of the encoder used to provide a payload type.
    /// Can be `nil` if the payload type is not supported by `Mediastreamer2`.
    public var encoderDescription: String? {
        
        return getString(linphone_payload_type_get_encoder_description)
    }
    
    /// Get the normal bitrate in bits/s.
    public var normalBitrate: Int {
        
        get { return Int(linphone_payload_type_get_normal_bitrate(rawPointer)) }
        
        set { linphone_payload_type_set_normal_bitrate(rawPointer, Int32(newValue)) }
    }
    
    /// The mime type.
    public var mimeType: String {
        
        return getString(linphone_payload_type_get_mime_type)!
    }
    
    /// The number of channels.
    public var channels: Int {
        
        get { return Int(linphone_payload_type_get_channels(rawPointer)) }
    }
    
    /// Check whether the payload is usable according the bandwidth targets set in the `Core`.
    public var isUsable: Bool {
        
        get { return linphone_payload_type_is_usable(rawPointer).boolValue }
    }
    
    /// Whether the specified payload type represents a variable bitrate codec.
    public var isVariableBitrate: Bool {
        
        get { return linphone_payload_type_is_vbr(rawPointer).boolValue }
    }
}

extension PayloadType: CustomStringConvertible { }

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
