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
internal final class ManagedPointer <InternalPointer> {
    
    let internalPointer: InternalPointer
    
    let retain: (InternalPointer?) -> ()
    
    let release: (InternalPointer?) -> ()
    
    deinit {
        
        release(internalPointer)
    }
    
    init(_ internalPointer: InternalPointer,
         _ retain: @escaping (InternalPointer?) -> (),
         _ release: @escaping (InternalPointer?) -> (),
         shouldRetain: Bool = false) {
        
        self.internalPointer = internalPointer
        self.retain = retain
        self.release = release
        
        if shouldRetain {
            
            retain(internalPointer)
        }
    }
}

// MARK: - Protocols

internal protocol Handle {
    
    associatedtype InternalPointer
    
    var managedPointer: ManagedPointer<InternalPointer> { get }
    
    init(managedPointer: ManagedPointer<InternalPointer>)
}

internal extension InternalHandle {
    
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

internal protocol UserDataHandle {
    
    let handle: Handle
    
    let userDataGetFunction: (_ internalPointer: Handle.InternalPointer?) -> UnsafeMutableRawPointer?
    
    let userDataSetFunction: (_ internalPointer: Handle.InternalPointer?, _ userdata: UnsafeMutableRawPointer?) -> ()
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
