//
//  Address.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/4/17.
//
//

import CLinPhone
import struct BelledonneSIP.URI

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
    
    /// Initialize an `Address` from a string.
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
    
    /// Returns the SIP URI only as a string, that is display name is removed.
    private var uriString: String? {
        
        @inline(__always)
        get { return internalReference.reference.getString(linphone_address_as_string_uri_only) }
    }
    
    /// Returns the SIP URI only, that is display name is removed.
    private var sip: URI? {
        
        @inline(__always)
        get { return URI(rawValue: uriString ?? "") }
    }
    
    /// Whether address is a routable SIP address.
    public var isSIP: Bool {
        
        @inline(__always)
        get { return linphone_address_is_sip(internalReference.reference.rawPointer).boolValue }
    }
    
    /// Whether the address refers to a secure location (sips).
    public var isSecure: Bool {
        
        @inline(__always)
        get { return linphone_address_get_secure(internalReference.reference.rawPointer).boolValue }
        
        @inline(__always)
        mutating set { linphone_address_set_secure(internalReference.reference.rawPointer, bool_t(newValue)) }
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
        
        @inline(__always)
        mutating set { internalReference.mutatingReference.setString(linphone_address_set_display_name, newValue).lpAssert() }
    }
    
    /// The username.
    public var username: String? {
        
        @inline(__always)
        get { return internalReference.reference.getString(linphone_address_get_username) }
        
        @inline(__always)
        mutating set { internalReference.mutatingReference.setString(linphone_address_set_username, newValue).lpAssert() }
    }
    
    /// The password encoded in the address. 
    /// 
    /// - Note: It is used for basic authentication (not recommended).
    public var password: String? {
        
        @inline(__always)
        get { return internalReference.reference.getString(linphone_address_get_password) }
        
        @inline(__always)
        mutating set { internalReference.mutatingReference.setString(linphone_address_set_password, newValue) }
    }
    
    /// The domain name.
    public var domain: String? {
        
        @inline(__always)
        get { return internalReference.reference.getString(linphone_address_get_domain) }
        
        @inline(__always)
        mutating set { internalReference.mutatingReference.setString(linphone_address_set_domain, newValue).lpAssert() }
    }
    
    /// The transport.
    public var transportType: TransportType {
        
        @inline(__always)
        get { return TransportType(linphone_address_get_transport(internalReference.reference.rawPointer)) }
        
        @inline(__always)
        mutating set { linphone_address_set_transport(internalReference.mutatingReference.rawPointer, newValue.linPhoneType).lpAssert() }
    }
    
    /// the value of the method parameter.
    public var method: String? {
        
        @inline(__always)
        get { return internalReference.reference.getString(linphone_address_get_method_param) }
        
        @inline(__always)
        mutating set { internalReference.mutatingReference.setString(linphone_address_set_method_param, newValue) }
    }
    
    // MARK: - Methods
    
    /// Removes address's tags and uri headers so that it is displayable to the user.
    @inline(__always)
    public mutating func clean() {
        
        linphone_address_clean(internalReference.mutatingReference.rawPointer)
    }
    /*
    /// Get the header encoded in the address.
    @inline(__always)
    public func header(_ name: String) -> String? {
        
        return internalReference.reference.getString { linphone_address_get_header($0, name) }
    }*/
    
    /// Set a header into the address. 
    ///
    /// Headers appear in the URI with '?', such as `<sip:test.org?SomeHeader=SomeValue>`.
    @inline(__always)
    public mutating func setHeader(_ name: String, value: String?) {
        
        internalReference.mutatingReference.setString({ linphone_address_set_header($0, name, $1) }, value)
    }
    
    /// Whether the address contains the parameter.
    @inline(__always)
    public func hasParameter(_ name: String) -> Bool {
        
        return linphone_address_has_param(internalReference.reference.rawPointer, name).boolValue
    }
    
    /// Get the parameter encoded in the address.
    @inline(__always)
    public func parameter(_ name: String) -> String? {
        
        return internalReference.reference.getString { linphone_address_get_param($0, name) }
    }
    
    /// Set a parameter into the address.
    @inline(__always)
    public mutating func setParameter(_ name: String, value: String?) {
        
        internalReference.mutatingReference.setString({ linphone_address_set_param($0, name, $1) }, value)
    }
    
    /// Whether the address contains the parameter.
    @inline(__always)
    public func hasURIParameter(_ name: String) -> Bool {
        
        return linphone_address_has_uri_param(internalReference.reference.rawPointer, name).boolValue
    }
    
    /// Get the parameter encoded in the address.
    @inline(__always)
    public func uriParameter(_ name: String) -> String? {
        
        return internalReference.reference.getString { linphone_address_get_uri_param($0, name) }
    }
    
    /// Set a parameter into the address.
    @inline(__always)
    public mutating func setURIParameter(_ name: String, value: String?) {
        
        internalReference.mutatingReference.setString({ linphone_address_set_uri_param($0, name, $1) }, value)
    }
    
    // MARK: - Subscripting
    /*
    public subscript (header name: String) -> String? {
        
        @inline(__always)
        get { return header(name) }
        
        @inline(__always)
        mutating set { setHeader(name, value: newValue) }
    }*/
    
    public subscript (parameter name: String) -> String? {
        
        @inline(__always)
        get { return parameter(name) }
        
        @inline(__always)
        mutating set { setParameter(name, value: newValue) }
    }
    
    public subscript (uriParameter name: String) -> String? {
        
        @inline(__always)
        get { return uriParameter(name) }
        
        @inline(__always)
        mutating set { setURIParameter(name, value: newValue) }
    }
}

// MARK: - Equatable

extension Address: Equatable {
    
    @inline(__always)
    public static func == (lhs: Address, rhs: Address) -> Bool {
        
        // same as `linphone_address_equal`. The function `linphone_address_weak_equal`
        // compares all properties, but not sure which one is more efficient and accurate.
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

// MARK: - Supporting Types

public extension Address {
    
    /// Enum describing transport type for `Linphone.Address`.
    public enum TransportType: UInt32, LinPhoneEnumeration {
        
        public typealias LinPhoneType = LinphoneTransportType
        
        case udp
        case tcp
        case tls
        case dtls
    }
}

// MARK: - ReferenceConvertible

extension Address: ReferenceConvertible {
    
    internal final class Reference: CopyableHandle {
        
        // MARK: - Properties
        
        @_versioned
        internal let managedPointer: ManagedPointer<UnmanagedPointer>
        
        // MARK: - Initialization
        
        @inline(__always)
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
