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

/// Linked List structure
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
    
    // MARK: - Accessors
    
    public var next: LinkedList? {
        
        @inline(__always)
        get {
            
            guard let reference = internalReference.reference.next
                else { return nil }
            
            return LinkedList(reference)
        }
        
        @inline(__always)
        mutating set {
            
            internalReference.mutatingReference.next = next?.internalReference.mutatingReference
        }
    }
    
    public var previous: LinkedList? {
        
        @inline(__always)
        get {
            
            guard let reference = internalReference.reference.previous
                else { return nil }
            
            return LinkedList(reference)
        }
        
        @inline(__always)
        mutating set {
            
            internalReference.mutatingReference.next = next?.internalReference.mutatingReference
        }
    }
    
    public var last: LinkedList? {
        
        @inline(__always)
        get {
            
            guard let reference = internalReference.reference.last
                else { return nil }
            
            return LinkedList(reference)
        }
    }
    
    // MARK: - Methods
    
    /// Append an element to the end of the linked list.
    @inline(__always)
    public mutating func append(_ element: inout LinkedList) {
        
        internalReference.mutatingReference.append(element.internalReference.mutatingReference)
    }
    
    /// Prepends an element to the beginning of the list.
    @inline(__always)
    public mutating func prepend(_ element: inout LinkedList) {
        
         internalReference.mutatingReference.prepend(element.internalReference.mutatingReference)
    }
    
    // MARK: - Methods
    
    /// Access the underlying C structure instance.
    ///
    /// - Note: The pointer is only guarenteed to be valid for the lifetime of the closure.
    public mutating func withUnsafeMutableRawPointer <Result> (_ body: (UnsafeMutablePointer<bctbx_list_t>) throws -> Result) rethrows -> Result {
        
        let rawPointer = internalReference.mutatingReference.rawPointer
        
        return try body(rawPointer)
    }
    
    /// Access the underlying C structure instance.
    ///
    /// - Note: The pointer is only guarenteed to be valid for the lifetime of the closure.
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
        
        /// Underlying `bctbx_list_t` pointer
        internal let rawPointer: RawPointer
        
        /// Keep reference for ARC. `bctbx_list_t` only manages memory of list structure, not the attached data. WTF?
        internal let data: NSMutableData // data.mutableBytes == rawPointer.pointee.data
        
        /// Keep reference for ARC. List is linked in Swift by ARC, and we update the underlying C structures to reflect
        /// current state.
        internal var previous: LinkedList.Reference? {
            
            didSet {
                
                // remove self from old value
                oldValue?.rawPointer.pointee.next = nil
                
                // set internal pointer
                self.rawPointer.pointee.prev = previous?.rawPointer
                previous?.rawPointer.pointee.next = self.rawPointer
            }
        }
        
        /// Keep reference for ARC. List is linked in Swift by ARC, and we update the underlying C structures to reflect
        /// current state.
        internal var next: LinkedList.Reference? {
            
            didSet {
                
                // remove self from old value
                oldValue?.rawPointer.pointee.prev = nil
                
                // same as `bctbx_list_next()`
                self.rawPointer.pointee.next = next?.rawPointer
                next?.rawPointer.pointee.prev = self.rawPointer
            }
        }
        
        // MARK: - Initialization
        
        @inline(__always)
        private init(rawPointer: RawPointer, data: NSMutableData) {
            
            self.rawPointer = rawPointer
            self.data = data
            
            assert(data.mutableBytes == rawPointer.pointee.data, "Invalid data pointer")
        }
        
        internal var copy: LinkedList.Reference? {
            
            // copy linked list struct
            guard let copyRawPointer = bctbx_list_copy(self.rawPointer)
                else { return nil }
            
            // copy data and assign to new list
            let dataCopy = self.data.copy() as! NSMutableData
            copyRawPointer.pointee.data = dataCopy.mutableBytes
            
            // create object
            let copy = LinkedList.Reference(rawPointer: copyRawPointer, data: dataCopy)
            copy.previous = self.previous
            copy.
            
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
        
        public var first: LinkedList.Reference? {
            
            var node = self
            var more = true
            
            repeat {
                
                if let first = node.first {
                    
                    node = first
                    
                } else {
                    
                    more = false
                }
                
            } while more
            
            return node
        }
        
        public var last: LinkedList.Reference? {
            
            var node = self
            var more = true
            
            repeat {
                
                if let next = node.next {
                    
                    node = next
                    
                } else {
                    
                    more = false
                }
                
            } while more
            
            return node
        }
        
        // MARK: - Methods
        
        /// Appends an element to the end of the list.
        @inline(__always)
        public func append(_ element: LinkedList.Reference) {
            
            self.last?.next = element
        }
        
        /// Prepends an element to the beginning of the list.
        @inline(__always)
        public func prepend(_ element: LinkedList.Reference) {
            
            self.first?.previous = element
        }
    }
}

// MARK: - CustomStringConvertible

extension LinkedList: CustomStringConvertible {
    
    public var description: String {
        
        var stringValues = [String]()
        
        /// Print just like an array would
        return "\(Array(self))"
    }
}
