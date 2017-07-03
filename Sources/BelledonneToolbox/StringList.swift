//
//  StringList.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/2/17.
//
//

import CBelledonneToolbox.list

public struct LinkedList {
    
    // MARK: - Properties
    
    internal let internalReference: Reference
    
    // MARK: - Initialization
    
    
    
}

// MARK: - Reference

extension LinkedList: ReferenceConvertible {
    
    internal final class Reference: Handle {
        
        // MARK: - Properties
        
        internal let rawPointer: OpaquePointer
        
        // MARK: - Initialization
        
        internal init(rawPointer: OpaquePointer)
        
        
    }
}

// MARK: - Collection

