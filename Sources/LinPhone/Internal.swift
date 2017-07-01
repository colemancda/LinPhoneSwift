//
//  Internal.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/1/17.
//
//

import CLinPhone

// MARK: - Protocols

internal protocol Handle {
    
    associatedtype InternalPointer
    
    var internalPointer: InternalPointer { get }
}

internal extension Handle {
    
    @inline(__always)
    func getString(_ function: (_ internalPointer: InternalPointer?) -> (UnsafePointer<Int8>?)) -> String? {
        
        guard let cString = function(self.internalPointer)
            else { return nil }
        
        return String(cString: cString)
    }
    
    @inline(__always)
    func setString<Result>(_ function: (_ internalPointer: InternalPointer?, _ cString: UnsafePointer<Int8>?) -> Result, _ newValue: String?) -> Result {
        
        return function(self.internalPointer, newValue)
    }
}

// MARK: - Value Types

internal extension CLinPhone.bool_t {
    
    init(_ bool: Bool) {
        
        self = bool ? 1 : 0
    }
    
    var boolValue: Bool {
        
        return self > 0
    }
}
