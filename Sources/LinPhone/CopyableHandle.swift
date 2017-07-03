//
//  CopyableHandle.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/2/17.
//
//

/// A handle object that can be duplicated.
internal protocol CopyableHandle: Handle {
    
    var copy: Self? { get }
}
