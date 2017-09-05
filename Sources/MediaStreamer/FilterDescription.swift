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
    public struct Description {
        
        // MARK: - Properties
        
        @_versioned
        internal private(set) var internalData = MSFilterDesc()
        
        // MARK: - Initialization
        
        public init() {
            
            
        }
        
        // MARK: - Accessors
        
        public var identifier: MSFilterId {
            
            get { return internalData.id }
            
            mutating set { internalData.id = newValue }
        }
        
        /// The filter name
        public var name: String = "" {
            
            willSet { setString(newValue, &internalData.name) }
        }
        
        /// Short text describing the filter's function
        public var text: String = "" {
            
            willSet { setString(newValue, &internalData.text) }
        }
        
        /// Filter's category
        public var category: Category {
            
            get { return Category(internalData.category) }
            
            mutating set { internalData.category = newValue.mediaStreamerType }
        }
        
        /// Sub-mime of the format, must be set if category is `.encoder` or `.decoder`.
        public var encodingFormat: String = ""  {
            
            willSet { setString(newValue, &internalData.enc_fmt) }
        }
        
        /// number of inputs
        public var inputCount: Int {
            
            get { return Int(internalData.ninputs) }
            
            mutating set { internalData.ninputs = Int32(newValue) }
        }
        
        /// number of outputs
        public var outputCount: Int {
            
            get { return Int(internalData.noutputs) }
            
            mutating set { internalData.noutputs = Int32(newValue) }
        }
        
        /*
        public var initialization: () {
            
            didSet { MSFilterFunc internalData.init = MSFIl }
        }*/
        
        // MARK: - Methods
        
        /// Whether a filter implements a given interface, based on the filter's descriptor.
        public mutating func implements(interface: Filter.Interface) -> Bool {
            
            return ms_filter_desc_implements_interface(&internalData, interface.mediaStreamerType).boolValue
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
