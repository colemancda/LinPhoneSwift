//
//  UnmanagedPointer.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/2/17.
//
//

/// A type for propagating an unmanaged C object reference.
/// When you use this type, you become partially responsible for keeping the object alive.
internal protocol UnmanagedPointer {
    
    associatedtype RawPointer
    
    init(_ rawPointer: RawPointer)
    
    var rawPointer: RawPointer { get }
    
    func retain()
    
    func release()
}
