//
//  StreamType.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 6/30/17.
//
//

import CLinPhone

/// Enum describing the Linphone stream types.
public enum StreamType {
    
    case audio
    case video
}

extension StreamType: LinPhoneEnumeration {
    
    public typealias LinPhoneType = LinphoneStreamType
    public typealias RawValue = LinPhoneType.RawValue
    
    @inline(__always)
    public init?(_ linPhoneType: LinPhoneType) {
        
        switch linPhoneType {
        case LinphoneStreamTypeAudio: self = .audio
        case LinphoneStreamTypeVideo: self = .video
        default: return nil
        }
    }
    
    public var linPhoneType: LinPhoneType {
        
        switch self {
        case .audio: return LinphoneStreamTypeAudio
        case .video: return LinphoneStreamTypeVideo
        }
    }
}

extension StreamType: CustomStringConvertible {
    
    public var description: String {
        
        return String(cString: linphone_stream_type_to_string(linPhoneType))
    }
}
