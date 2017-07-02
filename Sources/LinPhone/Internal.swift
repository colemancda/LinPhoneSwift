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
        
        internalPointer.release()
    }
    
    init(_ internalPointer: Pointer) {
        
        self.internalPointer = internalPointer
    }
}

// MARK: - Protocols

/// Struct that holds static information for how to manage a pointer.
internal protocol InternalPointer {
    
    associatedtype RawPointer
    
    init(_ rawPointer: RawPointer)
    
    var rawPointer: RawPointer { get }
    
    func retain()
    
    func release()
}

internal protocol Handle: class {
    
    associatedtype RawPointer
    
    var rawPointer: RawPointer { get }
}

// For Swift 4
// internal protocol ManagedHandle: Handle where RawPointer == InternalPointer.RawPointer {

internal protocol ManagedHandle: Handle {
    
    associatedtype InternalPointer: LinPhoneSwift.InternalPointer
    
    var managedPointer: ManagedPointer<InternalPointer> { get }
    
    init(_ managedPointer: ManagedPointer<InternalPointer>)
}

internal extension ManagedHandle where RawPointer == InternalPointer.RawPointer  {
    
    var internalPointer: InternalPointer {
        
        @inline(__always)
        get { return managedPointer.internalPointer }
    }
    
    var rawPointer: RawPointer {
        
        @inline(__always)
        get { return internalPointer.rawPointer }
    }
    
    @inline(__always)
    func getString(_ function: (_ internalPointer: InternalPointer.RawPointer?) -> (UnsafePointer<Int8>?)) -> String? {
        
        guard let cString = function(self.rawPointer)
            else { return nil }
        
        return String(cString: cString)
    }
    
    @inline(__always)
    func setString<Result>(_ function: (_ internalPointer: InternalPointer.RawPointer?, _ cString: UnsafePointer<Int8>?) -> Result, _ newValue: String?) -> Result {
        
        return function(self.rawPointer, newValue)
    }
}

internal protocol UserDataHandle: Handle {
    
    static var userDataGetFunction: (_ internalPointer: RawPointer?) -> UnsafeMutableRawPointer? { get }
    
    static var userDataSetFunction: (_ internalPointer: RawPointer?, _ userdata: UnsafeMutableRawPointer?) -> () { get }
}

internal extension UserDataHandle {
    
    static func from(rawPointer: RawPointer) -> Self? {
        
        guard let userData = Self.userDataGetFunction(rawPointer)
            else { return nil }
        
        return from(userData: userData)
    }
    
    static func from(userData: UnsafeMutableRawPointer) -> Self {
        
        let unmanaged = Unmanaged<Self>.fromOpaque(userData)
        
        let context = unmanaged.takeUnretainedValue()
        
        return context
    }
    
    func setUserData() {
        
        Self.userDataSetFunction(rawPointer, userData)
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
