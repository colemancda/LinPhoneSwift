//
//  Tunnel.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/11/17.
//
//

import CLinPhone.tunnel

public final class Tunnel {
    
    // MARK: - Properties
    
    @_versioned
    internal let managedPointer: ManagedPointer<UnmanagedPointer>
    
    // MARK: - Initialization
    
    internal init(_ managedPointer: ManagedPointer<UnmanagedPointer>) {
        
        self.managedPointer = managedPointer
    }
    
    // MARK: - Accessors
    
    public var mode: Mode {
        
        @inline(__always)
        get { return Mode(linphone_tunnel_get_mode(rawPointer)) }
        
        @inline(__always)
        set { linphone_tunnel_set_mode(rawPointer, mode.linPhoneType) }
    }
    
    /*
    public var enabled: Bool {
        
        @inline(__always)
        get { return linphone_tunnel_enabled(rawPointer).boolValue }
        
        @inline(__always)
        set { linphone_tunnel_enable(rawPointer, bool_t(newValue)) }
    }*/
    
    
    
    // MARK: - Methods
}

public extension Tunnel {
    
    public final class Configuration {
        
        // MARK: - Properties
        
        @_versioned
        internal let managedPointer: ManagedPointer<UnmanagedPointer>
        
        // MARK: - Initialization
        
        internal init(_ managedPointer: ManagedPointer<UnmanagedPointer>) {
            
            self.managedPointer = managedPointer
        }
        
        /// Create a new tunnel configuration.
        public convenience init() {
            
            guard let rawPointer = linphone_tunnel_config_new()
                else { fatalError("Could not allocate instance") }
            
            self.init(ManagedPointer(UnmanagedPointer(rawPointer)))
        }
        
        // MARK: - Accessors
        
        
        
        // MARK: - Methods
    }
}

// MARK: - Supporting Types

public extension Tunnel {
    
    public enum Mode: UInt32, LinPhoneEnumeration {
        
        public typealias LinPhoneType = LinphoneTunnelMode
        
        /// The tunnel is disabled.
        case disable
        
        /// The tunnel is enabled.
        case enable
        
        /// The tunnel is enabled automatically if it is required. 
        case auto
        
        /// Convert a string into `Linphone.Tunnel.Mode` enum.
        public init(string: String) {
            
            self.init(linphone_tunnel_mode_from_string(string))
        }
        
        /// Convert a tunnel mode enum into string.
        public var stringValue: String {
            
            return String(lpCString: linphone_tunnel_mode_to_string(linPhoneType))!
        }
    }
}

extension Tunnel.Mode: CustomStringConvertible {
    
    public var description: String {
        
        @inline(__always)
        get { return stringValue }
    }
}

extension Tunnel: ManagedHandle {
    
    typealias RawPointer = UnmanagedPointer.RawPointer
    
    struct UnmanagedPointer: LinPhone.UnmanagedPointer {
        
        let rawPointer: OpaquePointer
        
        @inline(__always)
        init(_ rawPointer: UnmanagedPointer.RawPointer) {
            self.rawPointer = rawPointer
        }
        
        @inline(__always)
        func retain() {
            linphone_tunnel_ref(rawPointer)
        }
        
        @inline(__always)
        func release() {
            linphone_tunnel_unref(rawPointer)
        }
    }
}

extension Tunnel.Configuration: ManagedHandle {
    
    typealias RawPointer = UnmanagedPointer.RawPointer
    
    struct UnmanagedPointer: LinPhone.UnmanagedPointer {
        
        let rawPointer: OpaquePointer
        
        @inline(__always)
        init(_ rawPointer: UnmanagedPointer.RawPointer) {
            self.rawPointer = rawPointer
        }
        
        @inline(__always)
        func retain() {
            linphone_tunnel_config_ref(rawPointer)
        }
        
        @inline(__always)
        func release() {
            linphone_tunnel_config_unref(rawPointer)
        }
    }
}

