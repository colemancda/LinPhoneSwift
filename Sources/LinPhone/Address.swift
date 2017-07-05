//
//  Address.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/4/17.
//
//

import CLinPhone

/// LinPhone Address class.
public struct Address: RawRepresentable {
    
    // MARK: - Properties
    
    @_versioned // private(set) in Swift 4
    internal fileprivate(set) var internalReference: CopyOnWrite<Reference>
    
    // MARK: - Initialization
    
    @inline(__always)
    internal init(_ internalReference: Reference, externalRetain: Bool = false) {
        
        self.internalReference = CopyOnWrite(internalReference, externalRetain: externalRetain)
    }
    
    /// Initialize an address from a string.
    public init?(rawValue: String) {
        
        guard let reference = Reference(string: rawValue)
            else { return nil }
        
        self.init(reference)
    }
    
    // MARK: - Accessors
    
    public var rawValue: String {
        
        @inline(__always)
        get { return internalReference.reference.stringValue }
    }
    
    /// Whether address is a routable SIP address.
    public var isSIP: Bool {
        
        @inline(__always)
        get { return linphone_address_is_sip(internalReference.reference.rawPointer).boolValue }
    }
    
    /// Port number as an integer value.
    public var port: Int32 {
        
        @inline(__always)
        get { return linphone_address_get_port(internalReference.reference.rawPointer) }
        
        @inline(__always)
        mutating set { linphone_address_set_port(internalReference.mutatingReference.rawPointer, newValue) }
    }
    
    /// The address scheme, normally "sip".
    public var scheme: String? {
        
        @inline(__always)
        get { return internalReference.reference.getString(linphone_address_get_scheme) }
    }
    
    /// The display name.
    public var displayName: String? {
        
        @inline(__always)
        get { return internalReference.reference.getString(linphone_address_get_display_name) }
    }
    
    /// Sets the display name.
    @inline(__always)
    public mutating func setDisplayName(_ newValue: String?) -> Bool {
        
        return internalReference.mutatingReference.setString(linphone_address_set_display_name, newValue) == .success
    }
}

// MARK: - Equatable

extension Address: Equatable {
    
    public static func == (lhs: Address, rhs: Address) -> Bool {
        
        // same as `linphone_address_equal`, `linphone_address_weak_equal`, 
        // compares all properties, not sure which one is more efficient and accurate
        return lhs.rawValue == rhs.rawValue
    }
}

// MARK: - Hashable

extension Address: Hashable {
    
    public var hashValue: Int {
        
        @inline(__always)
        get { return rawValue.hashValue }
    }
}

// MARK: - CustomStringConvertible

extension Address: CustomStringConvertible {
    
    public var description: String {
        
        @inline(__always)
        get { return rawValue }
    }
}

// MARK: - ReferenceConvertible

extension Address: ReferenceConvertible {
    
    internal final class Reference: CopyableHandle {
        
        // MARK: - Properties
        
        @_versioned
        internal let managedPointer: ManagedPointer<UnmanagedPointer>
        
        // MARK: - Initialization
        
        internal init(_ managedPointer: ManagedPointer<UnmanagedPointer>) {
            
            self.managedPointer = managedPointer
        }
        
        convenience init?(string: String) {
         
            guard let rawPointer = linphone_address_new(string)
                else { return nil }
            
            self.init(ManagedPointer(UnmanagedPointer(rawPointer)))
        }
        
        var copy: Address.Reference? {
            
            guard let rawPointer = linphone_address_clone(self.rawPointer)
                else { return nil }
            
            let copy = Address.Reference(ManagedPointer(UnmanagedPointer(rawPointer)))
            
            return copy
        }
        
        // MARK: - Accessors
        
        internal var stringValue: String {
            
            @inline(__always)
            get { return getString(linphone_address_as_string) ?? "" }
        }
    }
}

// MARK: - ManagedHandle

extension Address.Reference: ManagedHandle {
    
    typealias RawPointer = Address.UnmanagedPointer.RawPointer
}

extension Address {
    
    struct UnmanagedPointer: LinPhone.UnmanagedPointer {
        
        let rawPointer: OpaquePointer
        
        @inline(__always)
        init(_ rawPointer: UnmanagedPointer.RawPointer) {
            self.rawPointer = rawPointer
        }
        
        @inline(__always)
        func retain() {
            linphone_address_ref(rawPointer)
        }
        
        @inline(__always)
        func release() {
            linphone_address_unref(rawPointer)
        }
    }
}
