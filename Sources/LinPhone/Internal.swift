//
//  Internal.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/1/17.
//
//

import CLinPhone

// MARK: - Classes

/// Generic class for using C objects with manual reference count.
internal final class ManagedPointer <Pointer: InternalPointer> {
    
    let internalPointer: Pointer
    
    deinit {
        
        Pointer.release(internalPointer.rawPointer)
    }
    
    init(_ internalPointer: Pointer,
         shouldRetain: Bool = false) {
        
        self.internalPointer = internalPointer
        
        if shouldRetain {
            
            Pointer.retain(internalPointer.rawPointer)
        }
    }
}

// MARK: - Protocols

/// Struct that holds static information for how to manage a pointer.
internal protocol InternalPointer {
    
    associatedtype RawPointer
    
    static var retain: (RawPointer?) -> () { get }
    
    static var release: (RawPointer?) -> () { get }
    
    init(_ rawPointer: RawPointer)
    
    var rawPointer: RawPointer { get }
}

extension InternalPointer {
    
    func retain() {
        
        Self.retain(rawPointer)
    }
    
    func release() {
        
        Self.release(rawPointer)
    }
}

internal protocol Handle: class {
    
    associatedtype InternalPointer
    
    var managedPointer: ManagedPointer<InternalPointer> { get }
    
    init(managedPointer: ManagedPointer<InternalPointer>)
}

internal extension Handle {
    
    var internalPointer: InternalPointer {
        
        @inline(__always)
        get { return managedPointer.internalPointer }
    }
    
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

internal protocol UserDataHandle: Handle {
    
    static var userDataGetFunction: (_ internalPointer: InternalPointer?) -> UnsafeMutableRawPointer? { get }
    
    static var userDataSetFunction: (_ internalPointer: InternalPointer?, _ userdata: UnsafeMutableRawPointer?) -> () { get }
}

internal extension UserDataHandle {
    
    static func from(internalPointer: InternalPointer) -> Self? {
        
        guard let userData = Self.userDataGetFunction(internalPointer)
            else { return nil }
        
        return from(userData: userData)
    }
    
    static func from(userData: UnsafeMutableRawPointer) -> Self {
        
        let unmanaged = Unmanaged<Self>.fromOpaque(userData)
        
        let context = unmanaged.takeUnretainedValue()
        
        return context
    }
    
    func setUserData() {
        
        Self.userDataSetFunction(internalPointer, userData)
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
