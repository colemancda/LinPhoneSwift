//
//  Bool.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/8/17.
//
//

import CBelledonneToolbox

internal extension CBelledonneToolbox.bool_t {
    
    @inline(__always)
    init(_ bool: Bool) {
        
        self = bool ? 1 : 0
    }
    
    var boolValue: Bool {
        
        @inline(__always)
        get { return self > 0 }
    }
}
