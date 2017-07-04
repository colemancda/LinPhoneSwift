//
//  Internal.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/1/17.
//
//

import typealias CLinPhone.bool_t
import typealias CLinPhone.LinphoneStatus

internal extension CLinPhone.bool_t {
    
    @inline(__always)
    init(_ bool: Bool) {
        
        self = bool ? 1 : 0
    }
    
    var boolValue: Bool {
        
        @inline(__always)
        get { return self > 0 }
    }
}

internal extension LinphoneStatus {
    
    static var success: LinphoneStatus { return 0 }
    
    static var error: LinphoneStatus { return -1 }
}
