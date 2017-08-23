//
//  Tunnel.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/11/17.
//
//

import CLinPhone.tunnel
import CBelledonneToolbox.port

public final class Tunnel {
    
    // MARK: - Properties
    
    @_versioned
    internal let managedPointer: ManagedPointer<BelledonneUnmanagedObject>
    
    // MARK: - Initialization
    
    internal init(_ managedPointer: ManagedPointer<BelledonneUnmanagedObject>) {
        
        self.managedPointer = managedPointer
    }
    
    // MARK: - Accessors
    
    public var mode: Mode {
        
        get { return Mode(linphone_tunnel_get_mode(rawPointer)) }
        
        set { linphone_tunnel_set_mode(rawPointer, mode.linPhoneType) }
    }
    
    /// A boolean value telling whether SIP packets shall pass through the tunnel.
    public var isSIPEnabled: Bool {
        
        get { return linphone_tunnel_sip_enabled(rawPointer).boolValue }
        
        set { linphone_tunnel_enable_sip(rawPointer, bool_t(newValue)) }
    }
    
    /// Check whether the tunnel is connected.
    public var isConnected: Bool {
        
        return linphone_tunnel_connected(rawPointer).boolValue
    }
    
    /// Returns whether the tunnel is activated. 
    /// If mode is set to auto, this gives indication whether the automatic detection 
    /// determined that tunnel was necessary or not.
    public var isActivated: Bool {
        
        return linphone_tunnel_get_activated(rawPointer).boolValue
    }
    
    // MARK: - Methods
    
    /// Force reconnection to the tunnel server. 
    /// 
    /// This method is useful when the device switches from wifi to Edge/3G or vice versa. 
    /// In most cases the tunnel client socket won't be notified promptly that its connection is now zombie, 
    /// so it is recommended to call this method that will cause the lost connection to be closed 
    /// and new connection to be issued.
    public func reconnect() {
        
        linphone_tunnel_reconnect(rawPointer)
    }
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

extension Tunnel: BelledonneObjectHandle {
    
    internal typealias UnmanagedPointer = BelledonneUnmanagedObject
    
    internal typealias RawPointer = UnmanagedPointer.RawPointer
}

extension Tunnel.Configuration: ManagedHandle {
    
    typealias RawPointer = UnmanagedPointer.RawPointer
    
    struct UnmanagedPointer: LinPhoneSwift.UnmanagedPointer {
        
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

