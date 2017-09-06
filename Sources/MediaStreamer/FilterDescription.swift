//
//  FilterDescription.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 8/12/17.
//
//

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
            
            /// Initialize value backed by new reference instance.
            self.init(referencing: Reference())
        }
        
        // MARK: - Accessors
        
        public var identifier: Filter.Identifier {
            
            get { return internalReference.reference.identifier }
            
            set { internalReference.mutatingReference.identifier = newValue }
        }
        
        /// The filter name
        public var name: String? {
            
            get { return internalReference.reference.name.string }
            
            set { internalReference.mutatingReference.name.string = newValue }
        }
        
        /// Short text describing the filter's function
        public var text: String? {
            
            get { return internalReference.reference.text.string }
            
            set { internalReference.mutatingReference.text.string = newValue }
        }
        
        /// Sub-mime of the format, must be set if category is `.encoder` or `.decoder`.
        public var encodingFormat: String?  {
            
            get { return internalReference.reference.encodingFormat.string }
            
            set { internalReference.mutatingReference.encodingFormat.string = newValue }
        }
        
        /// Filter's category
        public var category: Filter.Category {
            
            get { return internalReference.reference.category }
            
            set { internalReference.mutatingReference.category = newValue }
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
        
        typealias CString = UnsafePointer<Int8>!
        
        // MARK: - Properties
        
        @_versioned
        internal let rawPointer: RawPointer
        
        // MARK: - Initialization
        
        deinit {
            
            // free raw pointer
            self.rawPointer.deallocate(capacity: 1)
        }
        
        public init() {
            
            // alloc raw pointer
            self.rawPointer = RawPointer.allocate(capacity: 1)
        }
        
        public var copy: Filter.Description.Reference? {
            
            let copy = Reference()
            
            // copy values
            copy.rawPointer.pointee = rawPointer.pointee
            
            // replace pointers and retained reference types
            copy.name.string = name.string
            copy.text.string = text.string
            copy.encodingFormat.string = encodingFormat.string
            
            return copy
        }
        
        // MARK: - Accessors
        
        public var identifier: Filter.Identifier {
            
            get { return rawPointer.pointee.id }
            
            set { rawPointer.pointee.id = newValue }
        }
        
        /// The filter name
        public lazy var name: ManagedCString<CString> = ManagedCString(didChange: { [weak self] in self?.rawPointer.pointee.name = $0 })
        
        /// Short text describing the filter's function
        public lazy var text: ManagedCString<CString> = ManagedCString(didChange: { [weak self] in self?.rawPointer.pointee.text = $0 })
        
        /// Sub-mime of the format, must be set if category is `.encoder` or `.decoder`.
        public lazy var encodingFormat: ManagedCString<CString> = ManagedCString(didChange: { [weak self] in self?.rawPointer.pointee.enc_fmt = $0 })
        
        /// Filter's category
        public var category: Filter.Category {
            
            get { return Filter.Category(rawPointer.pointee.category) }
            
            set { rawPointer.pointee.category = newValue.mediaStreamerType }
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
    }
}
