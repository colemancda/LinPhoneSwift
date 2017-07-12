//
//  VideoPolicy.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/12/17.
//
//

import CLinPhone

/// Structure describing policy regarding video streams establishments.
public struct VideoPolicy {
    
    public typealias LinPhoneType = LinphoneVideoPolicy
    
    /// Video shall be initiated by default for outgoing calls.
    public var automaticallyAccept: Bool = false
    
    /// Video shall be accepter by default for incoming calls. 
    public var automaticallyStart: Bool = false
}

public extension VideoPolicy {
    
    init(_ linPhoneType: LinPhoneType) {
        
        self.automaticallyAccept = linPhoneType.automatically_accept.boolValue
        self.automaticallyStart = linPhoneType.automatically_initiate.boolValue
    }
    
    var linPhoneType: LinPhoneType {
        
        var linPhoneType = LinPhoneType()
        
        linPhoneType.automatically_accept = bool_t(automaticallyAccept)
        linPhoneType.automatically_initiate = bool_t(automaticallyStart)
        
        return linPhoneType
    }
}
