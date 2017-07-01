//
//  Internal.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/1/17.
//
//

import CLinPhone

// MARK: - Protocols

/// The Swift class is a wrapper for a `Linphone` opaque type.
internal protocol Handle: class {
    
    associatedtype InternalPointer
    
    var internalPointer: InternalPointer! { get }
    
    static var userDataFunction: (get: (_ internalPointer: InternalPointer?) -> UnsafeMutableRawPointer?, set: (_ internalPointer: InternalPointer?, _ userdata: UnsafeMutableRawPointer?) -> ())  { get }
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

internal extension Handle {
    
    static func from(internalPointer: InternalPointer) -> Self? {
        
        guard let userData = Self.userDataFunction.get(internalPointer)
            else { return nil }
        
        return from(userData: userData)
    }
    
    static func from(userData: UnsafeMutableRawPointer) -> Self {
        
        let unmanaged = Unmanaged<Self>.fromOpaque(userData)
        
        let context = unmanaged.takeUnretainedValue()
        
        return context
    }
    
    func setUserData() {
        
        Self.userDataFunction.set(internalPointer, userData)
    }
    
    var userData: UnsafeMutableRawPointer {
        
        let unmanaged = Unmanaged<Self>.passUnretained(self)
        
        let objectPointer = unmanaged.toOpaque()
        
        return objectPointer
    }
}

// MARK: - Value Types

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
