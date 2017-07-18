//
//  SipTransports.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/18/17.
//
//

import CLinPhone

/// SIP transport ports.
public struct SipTransports {
    
    public var udp: Port
    
    public var tcp: Port
    
    public var dtls: Port
    
    public var tls: Port
}

// MARK: - Equatable

extension SipTransports: Equatable {
    
    public static func == (lhs: SipTransports, rhs: SipTransports) -> Bool {
        
        return lhs.udp == rhs.udp
            && lhs.tcp == rhs.tcp
            && lhs.dtls == rhs.dtls
            && lhs.tls == rhs.tls
    }
}

// MARK: - Supporting Types

public extension SipTransports {
    
    public typealias Port = Int32
    
    /// Disable a sip transport.
    public static var disabled: Port { return LC_SIP_TRANSPORT_DISABLED }
    
    /// Randomly chose a sip port for this transport.
    public static var random: Port { return LC_SIP_TRANSPORT_RANDOM }
    
    /// Don't create any server socket for this transport (e.i. don't bind on any port).
    public static var noBind: Port { return LC_SIP_TRANSPORT_DONTBIND }
}

// MARK: - LinPhone

internal extension SipTransports {
    
    typealias LinPhoneType = LinphoneSipTransports
    
    init(_ linPhoneType: LinPhoneType) {
        
        self.udp = linPhoneType.udp_port
        self.tcp = linPhoneType.tcp_port
        self.dtls = linPhoneType.dtls_port
        self.tls = linPhoneType.tls_port
    }
    
    var linPhoneType: LinPhoneType {
        
        return LinPhoneType(udp_port: udp,
                            tcp_port: tcp,
                            dtls_port: dtls,
                            tls_port: tls)
    }
}
