//
//  StreamType.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 6/30/17.
//
//

import CLinPhone

/// Enum describing the Linphone stream types.
public enum StreamType: UInt32, LinPhoneEnumeration {
    
    public typealias LinPhoneType = LinphoneStreamType
    
    case audio
    case video
    case text
    case unknown
}

extension StreamType: CustomStringConvertible {
    
    public var description: String {
        
        return String(cString: linphone_stream_type_to_string(self.linPhoneType))
    }
}
