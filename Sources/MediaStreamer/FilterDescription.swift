//
//  FilterDescription.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 8/12/17.
//
//

#if os(macOS) || os(iOS)
    import Darwin.C.stdlib
#elseif os(Linux)
    import Glibc
#endif

import CMediaStreamer2.filter

public extension Filter {
    
    /// To make custom filters.
    public struct Description /* Equatable */ {
        
        // MARK: - Properties
        
        @_versioned // private(set) in Swift 4
        internal fileprivate(set) var internalReference: CopyOnWrite<Reference>
        
        // MARK: - Initialization
        
        internal init(_ internalReference: CopyOnWrite<Reference>) {
            
            self.internalReference = internalReference
        }
        
        public init() {
            
            /// Initialize backed by new reference instance.
            self.init(referencing: Reference())
        }
        
        // MARK: - Accessors
        
        public var identifier: MSFilterId {
            
            get { return internalReference.reference.identifier }
            
            set { internalReference.mutatingReference.identifier = newValue }
        }
        
        /// The filter name
        public var name: String {
            
            get { return internalReference.reference.name }
            
            set { internalReference.mutatingReference.name = newValue }
        }
        
        /// Short text describing the filter's function
        public var text: String {
            
            get { return internalReference.reference.text }
            
            set { internalReference.mutatingReference.name = newValue }
        }
        
        /// Filter's category
        public var category: Filter.Category {
            
            get { return internalReference.reference.category }
            
            set { internalReference.mutatingReference.category = newValue }
        }
        
        /// Sub-mime of the format, must be set if category is `.encoder` or `.decoder`.
        public var encodingFormat: String  {
            
            get { return internalReference.reference.encodingFormat }
            
            set { internalReference.mutatingReference.encodingFormat = newValue }
        }
        
        /// number of inputs
        public var inputCount: Int {
            
            get { return internalReference.reference.inputCount }
            
            set { internalReference.mutatingReference.inputCount = newValue }
        }
        
        /// number of outputs
        public var outputCount: Int {
            
            get { return internalReference.reference.outputCount }
            
            set { internalReference.mutatingReference.outputCount = newValue }
        }
        
        /*
         public var initialization: () {
         
         didSet { MSFilterFunc internalData.init = MSFIl }
         }*/
        
        // MARK: - Methods
        
        /// Whether a filter implements a given interface, based on the filter's descriptor.
        public func implements(interface: Filter.Interface) -> Bool {
            
            return internalReference.reference.implements(interface: interface)
        }
    }
}

// MARK: - ReferenceConvertible

extension Filter.Description: ReferenceConvertible {
    
    /// Backing reference type of `Filter.Description`.
    internal final class Reference: CopyableHandle {
        
        typealias RawPointer = UnsafeMutablePointer<MSFilterDesc>
        
        // MARK: - Properties
        
        @_versioned
        internal let rawPointer: RawPointer
        
        // MARK: - Initialization
        
        deinit {
            
            // free string buffers
            [self.rawPointer.pointee.name,
             self.rawPointer.pointee.text,
             self.rawPointer.pointee.enc_fmt]
                .flatMap({ $0 })
                .map({ UnsafeMutableRawPointer(mutating: $0) })
                .forEach { free($0) }
            
            // free raw pointer
            self.rawPointer.deallocate(capacity: 1)
        }
        
        public init() {
            
            self.rawPointer = RawPointer.allocate(capacity: 1)
        }
        
        public var copy: Filter.Description.Reference? {
            
            let copy = Reference()
            
            // copy values
            copy.rawPointer.pointee = rawPointer.pointee
            
            // replace pointers and retained reference types
            copy.name = name
            copy.text = text
            copy.encodingFormat = encodingFormat
            
            return copy
        }
        
        // MARK: - Accessors
        
        public var identifier: MSFilterId {
            
            get { return rawPointer.pointee.id }
            
            set { rawPointer.pointee.id = newValue }
        }
        
        /// The filter name
        public var name: String = "" {
            
            willSet { setString(newValue, &rawPointer.pointee.name) }
        }
        
        /// Short text describing the filter's function
        public var text: String = "" {
            
            willSet { setString(newValue, &rawPointer.pointee.text) }
        }
        
        /// Filter's category
        public var category: Filter.Category {
            
            get { return Filter.Category(rawPointer.pointee.category) }
            
            set { rawPointer.pointee.category = newValue.mediaStreamerType }
        }
        
        /// Sub-mime of the format, must be set if category is `.encoder` or `.decoder`.
        public var encodingFormat: String = ""  {
            
            willSet { setString(newValue, &rawPointer.pointee.enc_fmt) }
        }
        
        /// number of inputs
        public var inputCount: Int {
            
            get { return Int(rawPointer.pointee.ninputs) }
            
            set { rawPointer.pointee.ninputs = Int32(newValue) }
        }
        
        /// number of outputs
        public var outputCount: Int {
            
            get { return Int(rawPointer.pointee.noutputs) }
            
            set { rawPointer.pointee.noutputs = Int32(newValue) }
        }
        
        /*
         public var initialization: () {
         
         didSet { MSFilterFunc internalData.init = MSFIl }
         }*/
        
        // MARK: - Methods
        
        /// Whether a filter implements a given interface, based on the filter's descriptor.
        public func implements(interface: Filter.Interface) -> Bool {
            
            return ms_filter_desc_implements_interface(rawPointer, interface.mediaStreamerType).boolValue
        }
        
        // MARK: - Private Methods
        
        private func setString(_ newValue: String, _ pointer: inout UnsafePointer<Int8>!) {
            
            if let oldPointer = pointer {
                
                free(UnsafeMutableRawPointer(mutating: oldPointer))
            }
            
            // create new string buffer
            pointer = UnsafePointer(name.withCString({ strdup($0) }))
        }
    }
}
