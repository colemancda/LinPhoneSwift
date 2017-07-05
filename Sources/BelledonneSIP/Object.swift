//
//  Object.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/4/17.
//
//

import CBelledonneSIP

/// It is the base protocol for all BelleSIP non-trivial objects. Can be class or struct.
public protocol BelledonneObject {
    
    associatedtype RawPointer
    
    /// Access the underlying C structure instance.
    ///
    /// - Note: The pointer is only guarenteed to be valid for the lifetime of the closure.
    mutating func withUnsafeMutableRawPointer <Result> (_ body: (RawPointer) throws -> Result) rethrows -> Result
    
    /// Access the underlying C structure instance.
    ///
    /// - Note: The pointer is only guarenteed to be valid for the lifetime of the closure.
    func withUnsafeRawPointer <Result> (_ body: (RawPointer) throws -> Result) rethrows -> Result
}
