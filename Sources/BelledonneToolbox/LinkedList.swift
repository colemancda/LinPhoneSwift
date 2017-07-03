//
//  LinkedList.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/2/17.
//
//

import CBelledonneToolbox.list
import struct Foundation.Data
import class Foundation.NSMutableData

public struct LinkedList {
    
    // MARK: - Properties
    
    @_versioned
    internal private(set) var internalReference: CopyOnWrite<Reference>
    
    // MARK: - Initialization
    
    internal init(_ internalReference: Reference) {
        
        self.internalReference = CopyOnWrite(internalReference)
    }
    
    /// Initialize linked list from data.
    public init(data: Data) {
        
        self.init(Reference(data: data))
    }
    
    /// Initialize linked list from string.
    public init(string: String) {
        
        self.init(Reference(string: string))
    }
    
    // MARK: - Accessors
    
    /// Get the value as a string.
    public var string: String {
        
        return String(cString: internalReference.reference.data.mutableBytes.assumingMemoryBound(to: UInt8.self))
    }
    
    /// Get the linked list node's data.
    public var data: Data {
        
        return Data(referencing: internalReference.reference.data)
    }
    
    // MARK: - Methods
    
    /// Access the underlying C structure instance.
    public mutating func withUnsafeMutableRawPointer <Result> (_ body: (UnsafeMutablePointer<bctbx_list_t>) throws -> Result) rethrows -> Result {
        
        let rawPointer = internalReference.mutatingReference.rawPointer
        
        return try body(rawPointer)
    }
    
    /// Access the underlying C structure instance.
    public func withUnsafeRawPointer <Result> (_ body: (UnsafePointer<bctbx_list_t>) throws -> Result) rethrows -> Result {
        
        let rawPointer = UnsafePointer(internalReference.reference.rawPointer)
        
        return try body(rawPointer)
    }
}

// MARK: - Reference

extension LinkedList: ReferenceConvertible {
    
    internal final class Reference: CopyableHandle {
        
        typealias RawPointer = UnsafeMutablePointer<bctbx_list_t>
        
        // MARK: - Properties
        
        internal let rawPointer: RawPointer
        
        /// Keep reference for ARC. `bctbx_list_t` only manages memory of list structure, not the attached data. WTF?
        internal let data: NSMutableData // data.mutableBytes == rawPointer.pointee.data
        
        // MARK: - Initialization
        
        @inline(__always)
        private init(rawPointer: RawPointer, data: NSMutableData) {
            
            self.rawPointer = rawPointer
            self.data = data
            
            assert(data.mutableBytes == rawPointer.pointee.data, "Invalid data pointer")
        }
        
        internal var copy: LinkedList.Reference? {
            
            guard let copyRawPointer = bctbx_list_copy(self.rawPointer)
                else { return nil }
            
            let dataCopy = self.data.copy() as! NSMutableData
            
            let copy = LinkedList.Reference(rawPointer: copyRawPointer, data: dataCopy)
            
            return copy
        }
        
        private init(data: NSMutableData) {
            
            guard let rawPointer = bctbx_list_new(data.mutableBytes)
                else { fatalError("Could not allocate instance") }
            
            self.rawPointer = rawPointer
            self.data = data
        }
        
        public convenience init(data: Data) {
            
            let mutableCopy = NSMutableData(data: data)
            
            self.init(data: mutableCopy)
        }
        
        public convenience init(string: String) {
            
            // copy null terminated string buffer
            let data = string.withCString { NSMutableData(bytes: $0, length: Int(strlen($0)) + 1) }
            
            guard let rawPointer = bctbx_list_new(data.mutableBytes)
                else { fatalError("Could not allocate instance") }
            
            self.init(rawPointer: rawPointer, data: data)
        }
        
        // MARK: - Accessors
        
        
    }
}

// MARK: - Collection

