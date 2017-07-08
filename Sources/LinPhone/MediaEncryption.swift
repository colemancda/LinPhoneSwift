//
//  MediaEncryption.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/8/17.
//
//

import CLinPhone

/// Enum describing type of media encryption types.
public enum MediaEncryption: UInt32, LinPhoneEnumeration {
    
    public typealias LinPhoneType = LinphoneMediaEncryption
    
    /// No media encryption is used
    case none
    
    /// Use SRTP media encryption
    case srtp
    
    /// Use ZRTP media encryption
    case zrtp
    
    /// Use DTLS media encryption
    case dtls
}

extension MediaEncryption: CustomStringConvertible {
    
    public var description: String {
        
        return String(lpCString: linphone_media_encryption_to_string(linPhoneType)) ?? ""
    }
}
