//
//  Core.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 6/30/17.
//
//

import CLinPhone

/// LinPhone Core class
public final class Core {
    
    internal var internalPointer: OpaquePointer
    
    internal init(_ internalPointer: OpaquePointer) {
        
        self.internalPointer = internalPointer
    }
    
    public static var version: String {
        
        return String(cString: linphone_core_get_version())
    }
}


