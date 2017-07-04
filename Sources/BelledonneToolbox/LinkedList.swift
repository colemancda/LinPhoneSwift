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
            
            internalReference.mutatingReference.previous = previous?.internalReference.mutatingReference
        }
    }
    
    public var first: LinkedList? {
        
        @inline(__always)
        get {
            
            guard let reference = internalReference.reference.first
                else { return nil }
            
            return LinkedList(reference)
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
    
    @inline(__always)
    public func forEach(_ body: (LinkedList) throws -> ()) rethrows {
        
        try internalReference.reference.forEach { try body(LinkedList($0)) }
    }
    
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

// MARK: - Equatable

extension LinkedList: Equatable {
    
    public static func == (lhs: LinkedList, rhs: LinkedList) -> Bool {
        
        return lhs.data == rhs.data
    }
}

// MARK: - Hashable

extension LinkedList: Hashable {
    
    public var hashValue: Int {
        
        return data.hashValue
    }
}

extension LinkedList: CustomStringConvertible {
    
    public var description: String {
        
        var stringValues = [String]()
        
        self.forEach { stringValues.append($0.string) }
        
        /// Print just like an array would
        return "\(stringValues)"
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
        
        /// List is linked in Swift by ARC, and we update the underlying C structures to reflect
        /// current state.
        internal var previous: LinkedList.Reference? {
            
            get { return _previous }
            
            set {
                
                let oldValue = _previous
                
                // reset old value
                oldValue?.next = nil
                
                // set internal pointer
                self.rawPointer.pointee.prev = newValue?.rawPointer
                newValue?.rawPointer.pointee.next = self.rawPointer
                
                /// keep reference for ARC
                newValue?._next = self
                self._previous = newValue
            }
        }
        
        /// Keep reference for ARC.
        private var _previous: LinkedList.Reference?
        
        /// List is linked in Swift by ARC, and we update the underlying C structures to reflect
        /// current state.
        internal var next: LinkedList.Reference? {
            
            get { return _next }
            
            set {
                
                let oldValue = _next
                
                // reset old value
                oldValue?.previous = nil
                
                // set internal pointer
                self.rawPointer.pointee.next = newValue?.rawPointer
                newValue?.rawPointer.pointee.prev = self.rawPointer
                
                /// keep reference for ARC
                newValue?._previous = self
                self._next = newValue
            }
        }
        
        /// Keep reference for ARC.
        private var _next: LinkedList.Reference?
        
        // MARK: - Initialization
        
        @inline(__always)
        private init(rawPointer: RawPointer, data: NSMutableData) {
            
            self.rawPointer = rawPointer
            self.data = data
            
            assert(data.mutableBytes == rawPointer.pointee.data, "Invalid data pointer")
        }
        
        internal var copy: LinkedList.Reference? {
            
            let copy = LinkedList.Reference(data: Data(referencing: self.data))
            
            var node = copy
            var more = true
            
            repeat {
                
                if let next = node.next {
                    
                    let newNode = LinkedList.Reference(data: Data(referencing: next.data))
                    node.next = newNode
                    
                    node = next
                    
                } else {
                    
                    more = false
                }
                
            } while more
            
            return node
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
                
                if let previous = node.previous {
                    
                    node = previous
                    
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
        
        @inline(__always)
        public func forEach(_ body: (LinkedList.Reference) throws -> ()) rethrows {
            
            var node = self
            var more = true
            
            repeat {
                
                try body(node)
                
                if let next = node.next {
                    
                    node = next
                    
                } else {
                    
                    more = false
                }
                
            } while more
        }
    }
}
