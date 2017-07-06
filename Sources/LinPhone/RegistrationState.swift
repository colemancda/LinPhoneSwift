//
//  RegistrationState.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/6/17.
//
//

import CLinPhone

/// `Linphone.RegistrationState` describes proxy registration states.
public enum RegistrationState: UInt32, LinPhoneEnumeration {
    
    public typealias LinPhoneType = LinphoneRegistrationState
    
    /// Initial state for registrations
    case none
    
    /// Registration is in progress
    case progress
    
    /// Registration is successful
    case successful // LinphoneRegistrationOk
    
    /// Unregistration succeeded
    case cleared
    
    /// Registration failed
    case failed
}

extension RegistrationState: CustomStringConvertible {
    
    public var description: String {
        
        return String(lpCString: linphone_registration_state_to_string(linPhoneType)) ?? ""
    }
}
