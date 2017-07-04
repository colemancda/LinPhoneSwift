//
//  Handle.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/2/17.
//
//

#if os(macOS)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

/// A Swift class wrapper for a C object.
internal protocol Handle: class {
    
    associatedtype RawPointer
    
    var rawPointer: RawPointer { get }
}

extension Handle {
    
    @inline(__always)
    func getString(_ function: (_ internalPointer: RawPointer?) -> (UnsafePointer<Int8>?)) -> String? {
        
        guard let cString = function(self.rawPointer)
            else { return nil }
        
        //defer { free(cString) }
        
        return String(cString: cString)
    }
    
    @inline(__always)
    func setString<Result>(_ function: (_ internalPointer: RawPointer?, _ cString: UnsafePointer<Int8>?) -> Result, _ newValue: String?) -> Result {
        
        return function(self.rawPointer, newValue)
    }
}
