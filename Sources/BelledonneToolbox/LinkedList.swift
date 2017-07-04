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
    internal let internalReference: Reference
    
    // MARK: - Initialization
    
    internal init(_ internalReference: Reference) {
        
        self.internalReference = internalReference
    }
    
    /// Initialize linked list from a data array.
    public init?(data: [Data]) {
        
        let mutableData = data.map { NSMutableData(data: $0) }
        
        guard let reference = Reference(mutableData: mutableData)
            else { return nil }
        
        self.init(reference)
    }
    
    /// Initialize linked list from a string array.
    public init?(strings: [String]) {
        
        // convert strings to data
        
        let data = strings.map { $0.cStringData }
        
        guard let reference = Reference(mutableData: data)
            else { return nil }
        
        self.init(reference)
    }
    
    // MARK: - Accessors
    
    /// Get the value as a string.
    public var strings: [String] {
        
        return internalReference.data.map { String(cStringData: $0) }
    }
    
    /// Get the linked list data.
    public var data: [Data] {
        
        return  internalReference.data.map { Data(referencing: $0) }
    }
    
    // MARK: - Accessors
    
    /// Access the underlying C structure instance.
    ///
    /// - Note: The pointer is only guarenteed to be valid for the lifetime of the closure.
    public func withUnsafeRawPointer <Result> (_ body: (UnsafePointer<bctbx_list_t>) throws -> Result) rethrows -> Result {
        
        let rawPointer = UnsafePointer(internalReference.rawPointer)
        
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
        
        return description.hashValue
    }
}

extension LinkedList: CustomStringConvertible {
    
    public var description: String {
        
        /// Print just like an array would
        return "\(strings)"
    }
}

// MARK: - Reference

extension LinkedList {
    
    internal final class Reference: Handle {
        
        typealias RawPointer = UnsafeMutablePointer<bctbx_list_t>
        
        // MARK: - Properties
        
        /// Underlying `bctbx_list_t` pointer. Always the first element.
        internal let rawPointer: RawPointer
        
        /// Keep reference for ARC. `bctbx_list_t` only manages memory of list structure, not the attached data. WTF?
        internal let data: [NSMutableData]
        
        // MARK: - Initialization
        
        deinit {
            
            bctbx_list_free(rawPointer)
        }
        
        fileprivate init?(mutableData: [NSMutableData]) {
            
            guard let firstData = mutableData.first,
                let rawPointer = bctbx_list_new(firstData.mutableBytes)
                else { return nil }
            
            /// append other data.
            for data in mutableData.suffix(from: 1) {
                
                bctbx_list_append(rawPointer, data.mutableBytes)
            }
            
            self.rawPointer = rawPointer
            self.data = mutableData
        }
    }
}

fileprivate extension String {
    
    var cStringData: NSMutableData {
        
        return self.withCString { NSMutableData(bytes: $0, length: Int(strlen($0)) + 1) }
    }
    
    init(cStringData data: NSMutableData) {
        
        self.init(cString: data.mutableBytes.assumingMemoryBound(to: UInt8.self))
    }
}
