//
//  Address.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/4/17.
//
//

import CLinPhone
import CBelledonneToolbox.port
import struct BelledonneSIP.URI
import class Foundation.NSString

/// LinPhone Address class.
public struct Address: RawRepresentable {
    
    // MARK: - Properties
    
    @_versioned // private(set) in Swift 4
    internal fileprivate(set) var internalReference: CopyOnWrite<Reference>
    
    // MARK: - Initialization
    
    internal init(_ internalReference: CopyOnWrite<Reference>) {
        
        self.internalReference = internalReference
    }
    
    /// Initialize an `Address` from a string.
    public init?(rawValue: String) {
        
        guard let reference = Reference(string: rawValue)
            else { return nil }
        
        self.init(referencing: reference)
    }
    
    // MARK: - Accessors
    
    public var rawValue: String {
        
        get { return internalReference.reference.stringValue }
    }
    
    /// Returns the SIP URI only as a string, that is display name is removed.
    private var uriString: String? {
        
        get { return internalReference.reference.getString(linphone_address_as_string_uri_only) }
    }
    
    /// Returns the SIP URI only, that is display name is removed.
    private var sip: URI? {
        
        get { return URI(rawValue: uriString ?? "") }
    }
    
    /// Whether address is a routable SIP address.
    public var isSIP: Bool {
        
        get { return linphone_address_is_sip(internalReference.reference.rawPointer).boolValue }
    }
    
    /// Whether the address refers to a secure location (sips).
    public var isSecure: Bool {
        
        get { return linphone_address_get_secure(internalReference.reference.rawPointer).boolValue }
        
        mutating set { linphone_address_set_secure(internalReference.mutatingReference.rawPointer, bool_t(newValue)) }
    }
    
    /// Port number as an integer value.
    public var port: Int32 {
        
        get { return linphone_address_get_port(internalReference.reference.rawPointer) }
        
        mutating set { linphone_address_set_port(internalReference.mutatingReference.rawPointer, newValue) }
    }
    
    /// The address scheme, normally "sip".
    public var scheme: String? {
        
        get { return internalReference.reference.getString(linphone_address_get_scheme) }
    }
    
    /// The display name.
    public var displayName: String? {
        
        get { return internalReference.reference.getString(linphone_address_get_display_name) }
        
        mutating set { internalReference.mutatingReference.setString(linphone_address_set_display_name, newValue).lpAssert() }
    }
    
    /// The username.
    public var username: String? {
        
        get { return internalReference.reference.getString(linphone_address_get_username) }
        
        mutating set { internalReference.mutatingReference.setString(linphone_address_set_username, newValue).lpAssert() }
    }
    
    /// The password encoded in the address. 
    /// 
    /// - Note: It is used for basic authentication (not recommended).
    public var password: String? {
        
        get { return internalReference.reference.getString(linphone_address_get_password) }
        
        mutating set { internalReference.mutatingReference.setString(linphone_address_set_password, newValue) }
    }
    
    /// The domain name.
    public var domain: String? {
        
        get { return internalReference.reference.getString(linphone_address_get_domain) }
        
        mutating set { internalReference.mutatingReference.setString(linphone_address_set_domain, newValue).lpAssert() }
    }
    
    /// The transport.
    public var transportType: TransportType {
        
        get { return TransportType(linphone_address_get_transport(internalReference.reference.rawPointer)) }
        
        mutating set { linphone_address_set_transport(internalReference.mutatingReference.rawPointer, newValue.linPhoneType).lpAssert() }
    }
    
    /// The value of the method parameter.
    public var method: String? {
        
        get { return internalReference.reference.getString(linphone_address_get_method_param) }
        
        mutating set { internalReference.mutatingReference.setString(linphone_address_set_method_param, newValue) }
    }
    
    // MARK: - Methods
    
    /// Removes address's tags and uri headers so that it is displayable to the user.
    public mutating func clean() {
        
        linphone_address_clean(internalReference.mutatingReference.rawPointer)
    }
    
    /// Get the header encoded in the address.
    public func header(_ name: String) -> String? {
        
        return internalReference.reference.getString { linphone_address_get_header($0, name) }
    }
    
    /// Set a header into the address. 
    ///
    /// Headers appear in the URI with '?', such as `<sip:test.org?SomeHeader=SomeValue>`.
    public mutating func setHeader(_ name: String, value: String?) {
        
        internalReference.mutatingReference.setString({ linphone_address_set_header($0, name, $1) }, value)
    }
    
    /// Whether the address contains the parameter.
    public func hasParameter(_ name: String) -> Bool {
        
        return linphone_address_has_param(internalReference.reference.rawPointer, name).boolValue
    }
    
    /// Get the parameter encoded in the address.
    public func parameter(_ name: String) -> String? {
        
        return internalReference.reference.getString { linphone_address_get_param($0, name) }
    }
    
    /// Set a parameter into the address.
    public mutating func setParameter(_ name: String, value: String?) {
        
        internalReference.mutatingReference.setString({ linphone_address_set_param($0, name, $1) }, value)
    }
    
    /// Whether the address contains the parameter.
    public func hasURIParameter(_ name: String) -> Bool {
        
        return linphone_address_has_uri_param(internalReference.reference.rawPointer, name).boolValue
    }
    
    /// Get the parameter encoded in the address.
    public func uriParameter(_ name: String) -> String? {
        
        return internalReference.reference.getString { linphone_address_get_uri_param($0, name) }
    }
    
    /// Set a parameter into the address.
    public mutating func setURIParameter(_ name: String, value: String?) {
        
        internalReference.mutatingReference.setString({ linphone_address_set_uri_param($0, name, $1) }, value)
    }
    
    // MARK: - Subscripting
    
    public subscript (header name: String) -> String? {
        
        get { return header(name) }
        
        mutating set { setHeader(name, value: newValue) }
    }
    
    public subscript (parameter name: String) -> String? {
        
        get { return parameter(name) }
        
        mutating set { setParameter(name, value: newValue) }
    }
    
    public subscript (uriParameter name: String) -> String? {
        
        get { return uriParameter(name) }
        
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
        
        internal init(_ managedPointer: ManagedPointer<UnmanagedPointer>) {
            
            self.managedPointer = managedPointer
        }
        
        convenience init?(string: String) {
            
            let cString = string.lpCString
            
            guard let rawPointer = linphone_address_new(cString)
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
            
                get { return getString(linphone_address_as_string) ?? "" }
        }
    }
}

// MARK: - ManagedHandle

extension Address.Reference: ManagedHandle {
    
    typealias RawPointer = Address.UnmanagedPointer.RawPointer
}

extension Address {
    
    struct UnmanagedPointer: LinPhoneSwift.UnmanagedPointer {
        
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
