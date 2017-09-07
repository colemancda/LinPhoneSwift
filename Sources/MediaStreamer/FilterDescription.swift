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
        
        public typealias RawPointer = UnsafeMutablePointer<MSFilterDesc>
        
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
        
        public var initialization: MSFilterFunc? {
            
            get { return internalReference.reference.initialization }
            
            set { internalReference.mutatingReference.initialization = newValue }
        }
        
        public var preprocess: Function {
            
            get { return internalReference.reference.preprocess }
            
            set { internalReference.mutatingReference.preprocess = newValue }
        }
        
        public var process: Function {
            
            get { return internalReference.reference.process }
            
            set { internalReference.mutatingReference.process = newValue }
        }
        
        public var postprocess: Function {
            
            get { return internalReference.reference.postprocess }
            
            set { internalReference.mutatingReference.postprocess = newValue }
        }
        
        public var uninitialization: Function {
            
            get { return internalReference.reference.uninitialization }
            
            set { internalReference.mutatingReference.uninitialization = newValue }
        }
        
        public var flags: Set<Filter.Flag> {
            
            get { return internalReference.reference.flags }
            
            set { internalReference.mutatingReference.flags = newValue }
        }
        
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
        
        typealias RawPointer = Filter.Description.RawPointer
        
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
            
            // initialize pointer (to avoid random values)
            self.rawPointer.initialize(to: MSFilterDesc())
        }
        
        public var copy: Filter.Description.Reference? {
            
            let copy = Reference()
            
            // copy values
            copy.rawPointer.pointee = rawPointer.pointee
            
            // replace pointers and retained reference types
            copy.name.string = name.string
            copy.text.string = text.string
            copy.encodingFormat.string = encodingFormat.string
            copy.initialization = initialization
            copy.preprocess = preprocess
            copy.process = process
            copy.postprocess = postprocess
            copy.uninitialization = uninitialization
            
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
        
        public var initialization: MSFilterFunc? {
            
            get { return _MSFilterDescSwift.from(rawPointer).pointee.cInit }
            
            set { _MSFilterDescSwift.from(rawPointer).pointee.cInit = newValue }
        }
        
        public var preprocess: Function = { _ in } {
            
            didSet {
                
                rawPointer.pointee.preprocess = {
                    
                    // get filter object
                    guard let rawPointer = $0,
                        let filter = Filter.from(rawPointer: rawPointer)
                        else { return }
                    
                    // call handler
                    filter.description?.internalReference.reference.preprocess(filter)
                }
            }
        }
        
        public var process: Function = { _ in } {
            
            didSet {
                
                rawPointer.pointee.process = {
                    
                    // get filter object
                    guard let rawPointer = $0,
                        let filter = Filter.from(rawPointer: rawPointer)
                        else { return }
                    
                    // call handler
                    filter.description?.internalReference.reference.process(filter)
                }
            }
        }
        
        public var postprocess: Function = { _ in } {
            
            didSet {
                
                rawPointer.pointee.postprocess = {
                    
                    // get filter object
                    guard let rawPointer = $0,
                        let filter = Filter.from(rawPointer: rawPointer)
                        else { return }
                    
                    // call handler
                    filter.description?.internalReference.reference.postprocess(filter)
                }
            }
        }
        
        public var uninitialization: Function = { _ in } {
            
            didSet {
                
                rawPointer.pointee.uninit = {
                    
                    // get filter object
                    guard let rawPointer = $0,
                        let filter = Filter.from(rawPointer: rawPointer)
                        else { return }
                    
                    // call handler
                    filter.description?.internalReference.reference.uninitialization(filter)
                }
            }
        }
        
        public var flags: Set<Filter.Flag> {
            
            get { return Filter.Flag.from(flags: Int32(rawPointer.pointee.flags)) }
            
            set { rawPointer.pointee.flags = UInt32(newValue.flags) }
        }
        
        // MARK: - Methods
        
        /// Whether a filter implements a given interface, based on the filter's descriptor.
        public func implements(interface: Filter.Interface) -> Bool {
            
            return ms_filter_desc_implements_interface(rawPointer, interface.mediaStreamerType).boolValue
        }
    }
}

// MARK: - Supporting Types

public extension Filter.Description {
    
    public typealias Initialization = () -> ()
    
    public typealias Function = (Filter) -> ()
}

// MARK: - BelledonneObject

extension Filter.Description /* : BelledonneObject */ {
    
    public mutating func withUnsafeMutableRawPointer <Result> (_ body: (UnsafeMutablePointer<MSFilterDesc>) throws -> Result) rethrows -> Result {
        
        let rawPointer = internalReference.mutatingReference.rawPointer
        
        return try body(rawPointer)
    }
    
    public func withUnsafeRawPointer <Result> (_ body: (UnsafePointer<MSFilterDesc>) throws -> Result) rethrows -> Result {
        
        let rawPointer = internalReference.reference.rawPointer
        
        return try body(rawPointer)
    }
}

// MARK: - Private

/// Renamed struct (because of `init` property.
private struct _MSFilterDescSwift {
    
    /**< the id declared in allfilters.h */
    public var id: MSFilterId
    
    /**< the filter name*/
    public var name: UnsafePointer<Int8>
    
    /**< short text describing the filter's function*/
    public var text: UnsafePointer<Int8>
    
    /**< filter's category*/
    public var category: MSFilterCategory
    
    /**< sub-mime of the format, must be set if category is MS_FILTER_ENCODER or MS_FILTER_DECODER */
    public var enc_fmt: UnsafePointer<Int8>
    
    /**< number of inputs */
    public var ninputs: Int32
    
    /**< number of outputs */
    public var noutputs: Int32
    
    /**< Filter's init function*/
    public var cInit: CMediaStreamer2.MSFilterFunc?
    
    /**< Filter's preprocess function, called one time before starting to process*/
    public var preprocess: CMediaStreamer2.MSFilterFunc
    
    /**< Filter's process function, called every tick by the MSTicker to do the filter's job*/
    public var process: CMediaStreamer2.MSFilterFunc
    
    /**< Filter's postprocess function, called once after processing (the filter is no longer called in process() after)*/
    public var postprocess: CMediaStreamer2.MSFilterFunc
    
    /**< Filter's uninit function, used to deallocate internal structures*/
    public var uninit: CMediaStreamer2.MSFilterFunc
    
    /**<Filter's method table*/
    public var methods: UnsafeMutablePointer<MSFilterMethod>
    
    /**<Filter's special flags, from the MSFilterFlags enum.*/
    public var flags: UInt32
    
    @inline(__always)
    static func from(_ rawPointer: UnsafeMutablePointer<MSFilterDesc>) -> UnsafeMutablePointer<_MSFilterDescSwift> {
        
        typealias MutableSwiftRawPointer = UnsafeMutablePointer<_MSFilterDescSwift>
        
        assert(MemoryLayout<UnsafeMutablePointer<MSFilterDesc>>.size == MemoryLayout<MutableSwiftRawPointer>.size)
        
        let opaquePointer = OpaquePointer(rawPointer)
        
        return MutableSwiftRawPointer(opaquePointer)
    }
}
